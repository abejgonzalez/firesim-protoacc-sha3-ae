#!/bin/bash

set -ex

NPROC=16

# currently private so ssh is needed
export FDIR=$(git rev-parse --show-toplevel)
cd $FDIR

# just in case ae forgot to source it
source sourceme-f1-manager.sh

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
make -C sim DESIGN=FireSim TARGET_CONFIG=DDR3FRFCFSLLCMaxSetb17MaxWayb1_FireSimISCAProtoShax3RocketConfig PLATFORM_CONFIG=BaseF1ConfigSingleMem_F45MHz f1
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

	#echo "Printing Non-Chained Non-Accel. Measurements"
	$SW_DIR/parse-serial-cpu.py isca23-ss-serial-all-cpu/uartlog > $FDIR/overall-results-psc.txt

	#echo "Printing Non-Chained Accel. Measurements"
	$SW_DIR/parse-serial-accel.py isca23-ss-serial-all-accel/uartlog > $FDIR/overall-results-psa.txt

	#echo "Printing Chained Accel. E2E Measurements"
	$SW_DIR/parse-chained.py isca23-ss-chained-all-accel/uartlog > $FDIR/overall-results-pc.txt

	popd

	cat $FDIR/overall-results-*.txt > $FDIR/overall-results.txt

	echo "--- Parsing paper results ---"
	cat $FDIR/overall-results.txt | tee $FDIR/final-overall-results.txt
	$SW_DIR/parse-overall.py $FDIR/overall-results.txt | tee -a $FDIR/final-overall-results.txt
	$FDIR/modelrun.py $FDIR/final-overall-results.txt | grep "t_prime_cpu" | tee $FDIR/final-ae-results.txt
	cat $FDIR/final-overall-results.txt >> $FDIR/final-ae-results.txt
else
	echo "Something went wrong"
	exit 1
fi

echo "Success"
