#!/bin/bash

set -xe

EXPERIMENT_ROOT="experiments"
EXPERIMENT_PATH="experiments/efficient-filtering"
ENV_PATH="${EXPERIMENT_PATH}/test.env"
TMP_ENV_DIR="${EXPERIMENT_PATH}/tmp"
TMP_ENV_NAME="test.env"
TMP_ENV_PATH="${EXPERIMENT_PATH}/${TMP_ENV_NAME}"

source ${EXPERIMENT_ROOT}/functions.sh

setup_environment ${TMP_ENV_DIR} ${TMP_ENV_NAME} "1m_1" 1k_1.json "no-train-test" true
docker compose --env-file ${ENV_PATH} --env-file ${TMP_ENV_PATH} -f compose-os-metrics.yaml up -d

wait_for_container_stop osb

echo "Finished experiment"