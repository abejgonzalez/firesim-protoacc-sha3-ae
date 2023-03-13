#!/bin/bash

set -ex

# currently private so ssh is needed
#sudo rm -rf fs-setup
#git clone git@github.com:abejgonzalez/firesim-protoacc-sha3-ae.git fs-setup
#pushd fs-setup/scripts
#sudo ./machine-launch-script.sh
#popd

# logout of machine

NPROC=16

# currently private so ssh is needed
export FDIR=$(git rev-parse --show-toplevel)
cd $FDIR

# setup the repo
./scripts/first-clone-setup-fast.sh

source sourceme-f1-manager.sh

firesim managerinit # requires manual input

# build proto bmarks and code
pushd target-design/chipyard/generators/protoacc/firesim-workloads/

# build the modified protobuf library
pushd  ../microbenchmarks
./build-protobuf-all.sh
popd 

# re-gen ubmarks
pushd ../microbenchmarks
python gen-primitive-tests.py
rm -rf primitive-benchmarks/*.riscv
rm -rf primitive-benchmarks/*.x86
time make -f Makefile -j${NPROC} all

python gen-primitive-tests-serializer.py
rm -rf primitive-benchmarks-serializer/*.riscv
rm -rf primitive-benchmarks-serializer/*.x86
time make -f Makefile-serializer -j${NPROC} all
popd

pushd hyperproto/HyperProtoBench
bash ../buildall.sh
bash ../copy.sh $STARTDIR
popd

popd

# build marshal workload
SW_DIR=$FDIR/sw/proto-sha3-sw
pushd sw/proto-sha3-sw
export MAKEFLAGS=-j${NPROC}
marshal -v build isca23.json
marshal -v install isca23.json
# 2nd build needed for firemarshal race condition where imgs are not gen'ed properly
marshal -v build isca23.json
unset MAKEFLAGS # this version of firesim doesn't support make parallelism
popd

# run the workload
CFG_DIR="$FDIR/deploy/ae-configs"
ARGS="-c $CFG_DIR/config_runtime.ini -b $CFG_DIR/config_build.ini -r $CFG_DIR/config_build_recipes.ini -a $CFG_DIR/config_hwdb.ini"
firesim launchrunfarm $ARGS
firesim infrasetup $ARGS
firesim runworkload $ARGS
firesim terminaterunfarm -q $ARGS # should be unnecessary but double-check

# analyze the workloads
pushd deploy/results-workload/ 
LAST_DIR=$(ls | tail -n1)
if [ -d "$LAST_DIR" ]; then
	pushd $LAST_DIR

	echo "Printing Serial - CPU only"
	$SW_DIR/parse-serial.py isca23-ss-serial-all-cpu/uartlog

	echo "Printing Serial - Accels only"
	$SW_DIR/parse-serial.py isca23-ss-serial-all-accel/uartlog

	echo "Printing Chaining - Accels only"
	$SW_DIR/parse-chained.py isca23-ss-chained-all-accel/uartlog

	popd
else
	echo "Something went wrong"
	exit 1
fi

echo "Success"
