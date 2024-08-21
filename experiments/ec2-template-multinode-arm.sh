#!/bin/bash

set -xe

# Set things up a little bit
sleep 100
yum update -y
sleep 100
yum install gcc-c++ tmux git docker -y
sysctl -w vm.max_map_count=262144
service docker start
usermod -a -G docker ec2-user
sudo sysctl kernel.perf_event_paranoid=1
sudo sysctl kernel.kptr_restrict=0


echo "LANG=en_US.UTF-8" >> /etc/environment
echo "LC_ALL=en_US.UTF-8" >> /etc/environment

# Install python (Optional) - System-wide installation
MINICONDA_INSTALL_DIR=/opt/miniconda3
mkdir -p $MINICONDA_INSTALL_DIR
wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-aarch64.sh -O $MINICONDA_INSTALL_DIR/miniconda.sh
bash $MINICONDA_INSTALL_DIR/miniconda.sh -b -u -p $MINICONDA_INSTALL_DIR
rm $MINICONDA_INSTALL_DIR/miniconda.sh

# Add Miniconda to system PATH
echo "export PATH=$MINICONDA_INSTALL_DIR/bin:$PATH" >> /etc/profile.d/conda.sh
# Make the changes effective immediately for the current session
source /etc/profile.d/conda.sh

source ~/.bashrc

conda install python=3.11 -y

# TODO: install opensearch-benchmark