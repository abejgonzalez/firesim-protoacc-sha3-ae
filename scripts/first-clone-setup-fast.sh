#!/usr/bin/env bash

set -e
set -o pipefail


STARTDIR=$(pwd)

# build setup
./build-setup.sh fast
source sourceme-f1-manager.sh

# build target software
cd sw/firesim-software
./init-submodules.sh
./marshal -v build br-base.json

cd $STARTDIR
cd target-design/chipyard/generators/protoacc/microbenchmarks
./first-setup.sh

cd $STARTDIR

echo "first-clone-setup-fast.sh complete."
