#!/bin/bash

set -xe

EXPERIMENT_PATH="experiments/query-latency-debug"
OSB_PARAMS_PATH="osb/custom/params"
PARAMS_PATH="experiments/query-latency-debug/osb-params"
ENV_PATH="${EXPERIMENT_PATH}/test.env"
TMP_ENV_DIR="${EXPERIMENT_PATH}/tmp"
TMP_ENV_NAME="test.env"
TMP_ENV_PATH="${EXPERIMENT_PATH}/${TMP_ENV_NAME}"

source ${EXPERIMENT_PATH}/functions.sh

cp ${PARAMS_PATH}/faiss-hnsw.json ${OSB_PARAMS_PATH}

setup_environment ${TMP_ENV_DIR} ${TMP_ENV_NAME} "rewrite-off" faiss-hnsw.json "no-train-test" true
docker compose --env-file ${ENV_PATH} --env-file ${TMP_ENV_PATH} -f compose.yaml build --no-cache

wait_for_container_stop osb

echo "Finished experiment"