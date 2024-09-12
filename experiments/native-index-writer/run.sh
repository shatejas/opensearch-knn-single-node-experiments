#!/bin/bash

set -xe

S3_BASE_PATH=s3://shatejas-benchmarking-results

test_procedure=$1
run_id=$2

echo ${test_procedure}
echo ${run_id}

EXPERIMENT_ROOT="experiments"
EXPERIMENT_PATH="${EXPERIMENT_ROOT}/native-index-writer"
OSB_PARAMS_PATH="osb/custom/params"
PARAMS_PATH="${EXPERIMENT_ROOT}/native-index-writer/osb-params"
ENV_PATH="${EXPERIMENT_PATH}/test.env"
TMP_ENV_DIR="${EXPERIMENT_PATH}/tmp"
TMP_ENV_NAME="test.env"
TMP_ENV_PATH="${EXPERIMENT_PATH}/${TMP_ENV_NAME}"

source ${EXPERIMENT_ROOT}/functions.sh

rm -f /tmp/share-data/*/*

cp ${PARAMS_PATH}/faiss-hnsw.json ${OSB_PARAMS_PATH}
setup_environment ${TMP_ENV_DIR} ${TMP_ENV_NAME} ${run_id} faiss-hnsw.json ${test_procedure}
docker compose --env-file ${ENV_PATH} --env-file ${TMP_ENV_PATH} -f compose.yaml up -d

wait_for_container_stop osb

if [[ "${OSB_SHOULD_PROFILE,,}" == "true" ]]; then
  sleep 120 #sleeping to make sure flame graphs are generated before upload
fi

#Note make sure the box has access to account credentials via ada or some other method
PATH_BUCKET=$S3_BASE_PATH/native-index-writer/faiss/${run_id}
aws s3 cp /tmp/share-data/telemetry ${PATH_BUCKET}/telemetry/ --recursive
aws s3 cp /tmp/share-data/profiles ${PATH_BUCKET}/profiles/ --recursive
aws s3 cp /tmp/share-data/results ${PATH_BUCKET}/results/ --recursive


echo "Finished experiment"