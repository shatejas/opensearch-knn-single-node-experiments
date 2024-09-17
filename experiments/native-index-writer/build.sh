#!/bin/bash

set -xe

no_cache=$1
shift
service_names=$@



EXPERIMENT_ROOT="experiments"
EXPERIMENT_PATH="experiments/native-index-writer"
OSB_PARAMS_PATH="osb/custom/params"
PARAMS_PATH="experiments/native-index-writer/osb-params"
ENV_PATH="${EXPERIMENT_PATH}/test.env"
TMP_ENV_DIR="${EXPERIMENT_PATH}/tmp"
TMP_ENV_NAME="test.env"
TMP_ENV_PATH="${EXPERIMENT_PATH}/${TMP_ENV_NAME}"

source ${EXPERIMENT_ROOT}/functions.sh

cp ${PARAMS_PATH}/faiss-hnsw.json ${OSB_PARAMS_PATH}

setup_environment ${TMP_ENV_DIR} ${TMP_ENV_NAME} "rewrite-off" faiss-hnsw.json "no-train-test" true


docker_build_command="docker compose --env-file ${ENV_PATH} --env-file ${TMP_ENV_PATH} -f compose.yaml build"
if [[ "${no_cache,,}" == "true" ]]; then
    docker_build_command+=" --no-cache"
fi

if [ -n "$service_names" ]; then
  docker_build_command+=" $service_names"
fi

echo "Building with command $docker_build_command]"
eval "$docker_build_command"

wait_for_container_stop osb

echo "Finished experiment"