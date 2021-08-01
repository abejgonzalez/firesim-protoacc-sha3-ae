# you should source this on your manager instance
# you can also source it in your bashrc, but you must cd to this directory
# first

unamestr=$(uname)
RDIR=$(pwd)
AWSFPGA=$RDIR/platforms/f1/aws-fpga
export CL_DIR=$AWSFPGA/hdk/cl/developer_designs/cl_firesim

# setup risc-v tools
source ./env.sh

# put the manager on the user path
export PATH=$PATH:$(pwd)/deploy

# setup ssh-agent
source deploy/ssh-setup.sh

# flag for scripts to check that this has been sourced
export FIRESIM_SOURCED=1

# this is a prefix added to run farm names. change this to isolate run farms
# if you have multiple copies of firesim
export FIRESIM_RUNFARM_PREFIX=""

# put FlameGraph/other fireperf utils on the user path
export PATH=$(pwd)/utils/fireperf:$(pwd)/utils/fireperf/FlameGraph:$PATH


PROTO_BASE_DIR="$RDIR/target-design/chipyard/generators/protoacc"
export PROTOACC_SRC="$PROTO_BASE_DIR/src/main/scala"
export PROTOACC_FSIM="$PROTO_BASE_DIR/firesim-workloads"
export UBENCH_RESULTS="$PROTO_BASE_DIR/firesim-workloads/dataprocess/ubmarks"
export HYPER_RESULTS="$PROTO_BASE_DIR/firesim-workloads/dataprocess/bmarks"
export BUILT_HWDB_ENTRIES="$RDIR/deploy/built-hwdb-entries"

