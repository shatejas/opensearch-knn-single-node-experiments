#!/bin/bash

set -xe

no_cache=$1

EXPERIMENT_ROOT="experiments"
EXPERIMENT_PATH="experiments/concurrent-segment-search"
OSB_PARAMS_PATH="osb/custom/params"
PARAMS_PATH="experiments/concurrent-segment-search/osb-params"
ENV_PATH="${EXPERIMENT_PATH}/test.env"
TMP_ENV_DIR="${EXPERIMENT_PATH}/tmp"
TMP_ENV_NAME="test.env"
TMP_ENV_PATH="${EXPERIMENT_PATH}/${TMP_ENV_NAME}"

source ${EXPERIMENT_ROOT}/functions.sh

cp ${PARAMS_PATH}/faiss-hnsw.json ${OSB_PARAMS_PATH}

setup_environment ${TMP_ENV_DIR} ${TMP_ENV_NAME} "concurrent-segment-search" faiss-hnsw.json "no-train-test"

if [[ "${no_cache,,}" == "true" ]]; then
    docker compose --env-file ${ENV_PATH} --env-file ${TMP_ENV_PATH} -f compose.yaml build --no-cache
else
    docker compose --env-file ${ENV_PATH} --env-file ${TMP_ENV_PATH} -f compose.yaml build
fi

wait_for_container_stop osb

echo "Finished experiment"