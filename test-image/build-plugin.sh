#!/bin/bash

set -xe

export JAVA_HOME=/opt/java/openjdk-21
echo ${JAVA_HOME}
REPO_ENDPOINT=$1
REPO_BRANCH=$2
OPENSEARCH_VERSION=$3
git clone -b $REPO_BRANCH $REPO_ENDPOINT
#TODO Fix this to point to correct endpoint
cd k-NN

if [ "$ARCH" = "x86_64" ]; then
    ARCHITECTURE=x64
else
    ARCHITECTURE=arm64
fi

bash scripts/build.sh -v ${OPENSEARCH_VERSION} -s true -a ${ARCHITECTURE}
