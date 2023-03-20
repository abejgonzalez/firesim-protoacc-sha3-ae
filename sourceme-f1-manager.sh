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

export GEN_DIR="$RDIR/target-design/chipyard/generators/"
export SW_DIR="$RDIR/sw/proto-sha3-sw"
export CFG_DIR="$RDIR/deploy/ae-configs"
export BLT_DIR="$RDIR/deploy/built-hwdb-entries"

