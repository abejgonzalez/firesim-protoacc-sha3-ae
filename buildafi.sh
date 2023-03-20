#!/bin/bash

set -ex

# currently private so ssh is needed
export FDIR=$(git rev-parse --show-toplevel)
cd $FDIR

# run the workload
CFG_DIR="$FDIR/deploy/ae-configs"
ARGS="-c $CFG_DIR/config_runtime.ini -b $CFG_DIR/config_build.ini -r $CFG_DIR/config_build_recipes.ini -a $CFG_DIR/config_hwdb.ini"
firesim buildafi $ARGS

echo "Success"
