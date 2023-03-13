#!/bin/bash

set -ex
set -o pipefail

echo "machine launch script started" > /home/centos/machine-launchstatus

{
sudo yum groupinstall -y "Development tools"
sudo yum install -y gmp-devel mpfr-devel libmpc-devel zlib-devel vim git java java-devel
#curl https://bintray.com/sbt/rpm/rpm | sudo tee /etc/yum.repos.d/bintray-sbt-rpm.repo
sudo yum install -y texinfo gengetopt
sudo yum install -y expat-devel libusb1-devel ncurses-devel cmake "perl(ExtUtils::MakeMaker)"
# deps for poky
sudo yum install -y python36 patch diffstat texi2html texinfo subversion chrpath git wget
# deps for qemu
sudo yum install -y gtk3-devel
# deps for firesim-software (note that rsync is installed but too old)
sudo yum install -y python36-pip python36-devel rsync
# Install GNU make 4.x (needed to cross-compile glibc 2.28+)
sudo yum install -y centos-release-scl
sudo yum install -y devtoolset-8-make

# install DTC
sudo yum -y install dtc

## get a proper version of git
sudo yum -y remove git
sudo yum -y install epel-release
sudo yum -y install https://repo.ius.io/ius-release-el7.rpm
sudo yum -y install git236

# install verilator
git clone http://git.veripool.org/git/verilator
cd verilator/
git checkout v4.034
autoconf && ./configure && make -j4 && sudo make install
cd ..

# bash completion for manager
sudo yum -y install bash-completion

# graphviz for manager
sudo yum -y install graphviz python-devel

# used for CI
sudo yum -y install expect

sudo pip2 install argcomplete==1.9.3 \
                  awscli==1.15.76 \
                  Babel==0.9.6 \
                  backports.functools-lru-cache==1.6.4 \
                  backports.ssl-match-hostname==3.5.0.1 \
                  bcrypt==3.1.7 \
                  boto3==1.6.2 \
                  botocore==1.10.75 \
                  cffi==1.15.1 \
                  chardet==2.2.1 \
                  colorama==0.3.7 \
                  configobj==4.7.2 \
                  cryptography==3.3.2 \
                  cycler==0.10.0 \
                  decorator==3.4.0 \
                  docutils==0.14 \
                  enum34==1.1.10 \
                  Fabric==1.14.0 \
                  futures==3.2.0 \
                  graphviz==0.8.3 \
                  iniparse==0.4 \
                  ipaddress==1.0.16 \
                  IPy==0.75 \
                  javapackages==1.0.0 \
                  Jinja2==2.7.2 \
                  jmespath==0.9.3 \
                  jsonpatch==1.2 \
                  jsonpointer==1.9 \
                  kitchen==1.1.1 \
                  kiwisolver==1.1.0 \
                  lxml==3.2.1 \
                  MarkupSafe==0.11 \
                  matplotlib==2.2.2 \
                  numpy==1.16.6 \
                  pandas==0.22.0 \
                  paramiko==2.12.0 \
                  perf==0.1 \
                  Pillow==2.0.0 \
                  policycoreutils-default-encoding==0.1 \
                  prettytable==0.7.2 \
                  pyasn1==0.4.5 \
                  pycparser==2.21 \
                  pycurl==7.19.0 \
                  pygobject==3.22.0 \
                  pygpgme==0.3 \
                  pyliblzma==0.5.3 \
                  PyNaCl==1.4.0 \
                  pyparsing==2.4.7 \
                  pyserial==2.6 \
                  python-dateutil==2.6.1 \
                  python-linux-procfs==0.4.9 \
                  pytz==2022.6 \
                  pyudev==0.15 \
                  pyxattr==0.5.1 \
                  PyYAML==3.10 \
                  requests==2.6.0 \
                  rsa==3.4.2 \
                  s3transfer==0.1.13 \
                  schedutils==0.4 \
                  scipy==1.2.3 \
                  seobject==0.1 \
                  sepolicy==1.1 \
                  six==1.16.0 \
                  subprocess32==3.5.4 \
                  urlgrabber==3.10 \
                  urllib3==1.24.1 \
                  yum-metadata-parser==1.1.4

sudo activate-global-python-argcomplete

} 2>&1 | tee /home/centos/machine-launchstatus.log

# get a regular prompt
echo "PS1='\u@\H:\w\\$ '" >> /home/centos/.bashrc
echo "machine launch script completed" >> /home/centos/machine-launchstatus
