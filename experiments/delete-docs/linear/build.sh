#!/bin/bash

set -xe

EXPERIMENT_PATH="experiments/delete-docs/linear"
OSB_PARAMS_PATH="osb/custom/params"
PARAMS_PATH="experiments/delete-docs/osb-params"
ENV_PATH="${EXPERIMENT_PATH}/test.env"
TMP_ENV_DIR="${EXPERIMENT_PATH}/tmp"
TMP_ENV_NAME="test.env"
TMP_ENV_PATH="${EXPERIMENT_PATH}/${TMP_ENV_NAME}"

source ${EXPERIMENT_PATH}/functions.sh

cp ${PARAMS_PATH}/1k_1.json ${OSB_PARAMS_PATH}

# Initialize shared data folder for containers
mkdir -m 777 /tmp/share-data

setup_environment ${TMP_ENV_DIR} ${TMP_ENV_NAME} "1m_1" 1k_1.json "no-train-test" true
docker compose --env-file ${ENV_PATH} --env-file ${TMP_ENV_PATH} -f compose.yaml build

wait_for_container_stop osb

echo "Finished experiment"