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

# We need to mount the instance store drive manually to use the ssd
# Custom will be to create os-data in root
#mkfs -t xfs /dev/nvme1n1
mkdir  -p -m 777 /os-data
mkdir  -p -m 777 /tmp/share-data
mkdir  -p -m 777 /tmp/share-data/logs

#mount /dev/nvme1n1 /os-data

# Add docker compose
DOCKER_CONFIG=${DOCKER_CONFIG:-/root/.docker}
mkdir -p $DOCKER_CONFIG/cli-plugins
curl -SL https://github.com/docker/compose/releases/download/v2.27.0/docker-compose-linux-aarch64 -o $DOCKER_CONFIG/cli-plugins/docker-compose
chmod +x $DOCKER_CONFIG/cli-plugins/docker-compose

echo "LANG=en_US.UTF-8" >> /etc/environment
echo "LC_ALL=en_US.UTF-8" >> /etc/environment

# Execute the tests
git clone https://github.com/shatejas/opensearch-knn-single-node-experiments.git
cd opensearch-knn-single-node-experiments