#!/bin/bash

set -xe

S3_BASE_PATH=s3://shatejas-benchmarking-results

test_procedure=$1
run_id=$2

echo ${test_procedure}
echo ${run_id}

EXPERIMENT_PATH="experiments/query-latency-debug"
OSB_PARAMS_PATH="osb/custom/params"
PARAMS_PATH="experiments/query-latency-debug/osb-params"
ENV_PATH="${EXPERIMENT_PATH}/test.env"
TMP_ENV_DIR="${EXPERIMENT_PATH}/tmp"
TMP_ENV_NAME="test.env"
TMP_ENV_PATH="${EXPERIMENT_PATH}/${TMP_ENV_NAME}"

source ${EXPERIMENT_PATH}/functions.sh

cp ${PARAMS_PATH}/faiss-hnsw.json ${OSB_PARAMS_PATH}

setup_environment ${TMP_ENV_DIR} ${TMP_ENV_NAME} ${run_id} faiss-hnsw.json ${test_procedure} true
docker compose --env-file ${ENV_PATH} --env-file ${TMP_ENV_PATH} -f compose.yaml up -d --build

wait_for_container_stop osb

PATH_BUCKET=$S3_BASE_PATH/${RUN_ID}
aws s3 cp /tmp/share-data/profiles ${PATH_BUCKET}/profiles/ --recursive
aws s3 cp /tmp/share-data/results ${PATH_BUCKET}/results/ --recursive
aws s3 cp /tmp/share-data/telemetry ${PATH_BUCKET}/telemetry/ --recursive

echo "Finished experiment"