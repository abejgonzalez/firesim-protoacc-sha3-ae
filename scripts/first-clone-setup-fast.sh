#!/usr/bin/env bash

set -ex
set -o pipefail

get_and_setup() {
	NAME=$1
	URL=$2
	wget -O ${NAME}.zip ${URL}
	unzip ${NAME}.zip
	rm -rf ${NAME}.zip
}

clone_setup() {
	SED_URL=$1
	REPL_WITH=$2
	G_PATH=$3
	sed -i 's#'"$SED_URL"'#'"$REPL_WITH"'#g' .gitmodules
	git submodule update --init $G_PATH
}


STARTDIR=$(pwd)

cd ../

ZIPDIR=$(pwd)

# the following zenodo zips were created by the following procedure
# 1. manually cloning the git repository associated with it (to ensure that .git information was kept)
# 2. zipping the repositories with `zip --symlinks -r ZIPNAME FOLDERTOZIP`

#https://doi.org/10.5281/zenodo.7814222
get_and_setup chipyard-protoacc-sha3-ae                 https://zenodo.org/record/7814222/files/chipyard-protoacc-sha3-ae.zip
#https://doi.org/10.5281/zenodo.7814225
get_and_setup proto-sha3-sw                             https://zenodo.org/record/7814225/files/proto-sha3-sw.zip
#https://doi.org/10.5281/zenodo.7814235
get_and_setup profiling-data-processing-model-isca23-ae https://zenodo.org/record/7814235/files/profiling-data-processing-model-isca23-ae.zip
#https://doi.org/10.5281/zenodo.7814238
get_and_setup rocket-chip-protoacc-sha3-ae              https://zenodo.org/record/7814238/files/rocket-chip-protoacc-sha3-ae.zip
#https://doi.org/10.5281/zenodo.7814245
get_and_setup protoacc-protoacc-sha3-ae                 https://zenodo.org/record/7814245/files/protoacc-protoacc-sha3-ae.zip
#https://doi.org/10.5281/zenodo.7814260
get_and_setup firemarshal-protoacc-sha3-ae              https://zenodo.org/record/7814260/files/firemarshal-protoacc-sha3-ae.zip
#https://doi.org/10.5281/zenodo.7814265
get_and_setup riscv-torture-protoacc-sha3-ae            https://zenodo.org/record/7814265/files/riscv-torture-protoacc-sha3-ae.zip
#https://doi.org/10.5281/zenodo.7814266
get_and_setup riscv-linux-protoacc-sha3-ae              https://zenodo.org/record/7814266/files/riscv-linux-protoacc-sha3-ae.zip

cd $STARTDIR

clone_setup "https://github.com/abejgonzalez/chipyard-protoacc-sha3-ae" "$ZIPDIR/chipyard-protoacc-sha3-ae" target-design/chipyard
clone_setup "https://github.com/abejgonzalez/proto-sha3-sw.git" "$ZIPDIR/proto-sha3-sw" sw/proto-sha3-sw
clone_setup "https://github.com/abejgonzalez/profiling-data-processing-model-isca23-ae.git" "$ZIPDIR/profiling-data-processing-model-isca23-ae" profilingmodelpy

cd target-design/chipyard

clone_setup "https://github.com/abejgonzalez/rocket-chip-protoacc-sha3-ae.git" "$ZIPDIR/rocket-chip-protoacc-sha3-ae" generators/rocket-chip
clone_setup "https://github.com/abejgonzalez/firemarshal-protoacc-sha3-ae.git" "$ZIPDIR/firemarshal-protoacc-sha3-ae" software/firemarshal
clone_setup "https://github.com/abejgonzalez/protoacc-protoacc-sha3-ae.git" "$ZIPDIR/protoacc-protoacc-sha3-ae" generators/protoacc

cd generators/rocket-chip

clone_setup "https://github.com/abejgonzalez/riscv-torture-protoacc-sha3-ae.git" "$ZIPDIR/riscv-torture-protoacc-sha3-ae" torture

cd ../..

cd software/firemarshal

clone_setup "https://github.com/abejgonzalez/riscv-linux-protoacc-sha3-ae.git" "$ZIPDIR/riscv-linux-protoacc-sha3-ae" riscv-linux

cd $STARTDIR

# build setup
./build-setup.sh fast
source sourceme-f1-manager.sh

# build target software
cd sw/firesim-software
./init-submodules.sh
export MAKEFLAGS=-j16
./marshal -v build br-base.json
unset MAKEFLAGS

cd $STARTDIR
cd target-design/chipyard/generators/protoacc/microbenchmarks
./first-setup.sh

cd $STARTDIR

echo "first-clone-setup-fast.sh complete."
