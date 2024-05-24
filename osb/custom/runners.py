# SPDX-License-Identifier: Apache-2.0
#
# The OpenSearch Contributors require contributions made to
# this file be licensed under the Apache-2.0 license or a
# compatible open source license.
import time

from osbenchmark.client import RequestContextHolder
from osbenchmark.utils.parse import parse_string_parameter, parse_int_parameter
from osbenchmark.worker_coordinator.runner import Retry, Runner


def register(registry):
    # Warm up api is idempotent, so we can safely retry until complete. This is required
    # so that search can perform without any initial load penalties
    registry.register_runner(
        WarmupIndicesRunner.RUNNER_NAME, Retry(WarmupIndicesRunner(), retry_until_success=True), async_runner=True
    )

    registry.register_runner(
        TrainModelRunner.RUNNER_NAME, TrainModelRunner(), async_runner=True
    )
    registry.register_runner(
        DeleteModelRunner.RUNNER_NAME, DeleteModelRunner(), async_runner=True
    )


request_context_holder = RequestContextHolder()


class WarmupIndicesRunner(Runner):
    """
    WarmupIndicesRunner loads all the native library files for all of the
    shards (primaries and replicas) of all the indexes.
    """
    RUNNER_NAME = "warmup-knn-indices"

    async def __call__(self, opensearch, params):
        index = parse_string_parameter("index", params)
        method = "GET"
        warmup_url = "/_plugins/_knn/warmup/{}".format(index)
        result = {'success': False}
        request_context_holder.on_client_request_start()
        response = await opensearch.transport.perform_request(method, warmup_url)
        request_context_holder.on_client_request_end()
        if response is None or response['_shards'] is None:
            return result
        status = response['_shards']['failed'] == 0
        result['success'] = status
        return result

    def __repr__(self, *args, **kwargs):
        return self.RUNNER_NAME


class TrainModelRunner:
    RUNNER_NAME = "train-model"

    async def __call__(self, opensearch, params):
        # Train a model and wait for it training to complete
        body = params["body"]
        timeout = parse_int_parameter("timeout", params)
        model_id = parse_string_parameter("model_id", params)

        method = "POST"
        model_uri = "/_plugins/_knn/models/{}".format(model_id)
        request_context_holder.on_client_request_start()
        await opensearch.transport.perform_request(method, "{}/_train".format(model_uri), body=body)
        request_context_holder.on_client_request_end()

        start_time = time.time()
        while time.time() < start_time + timeout:
            time.sleep(1)
            request_context_holder.on_client_request_start()
            model_response = await opensearch.transport.perform_request("GET", model_uri)
            request_context_holder.on_client_request_end()

            if 'state' not in model_response.keys():
                continue

            if model_response['state'] == 'created':
                #TODO: Return model size as well
                return 1, "models_trained"

            if model_response['state'] == 'failed':
                raise Exception("Failed to create model: {}".format(model_response))

        raise Exception('Failed to create model: {} within timeout {} seconds'
                        .format(model_id, timeout))

    def __repr__(self, *args, **kwargs):
        return self.RUNNER_NAME


class DeleteModelRunner:
    RUNNER_NAME = "delete-model"

    async def __call__(self, opensearch, params):
        # Delete model provided by model id
        method = "DELETE"
        model_id = parse_string_parameter("model_id", params)
        uri = "/_plugins/_knn/models/{}".format(model_id)

        # Ignore if model doesnt exist
        request_context_holder.on_client_request_start()
        await opensearch.transport.perform_request(method, uri, params={"ignore": [400, 404]})
        request_context_holder.on_client_request_end()


    def __repr__(self, *args, **kwargs):
        return self.RUNNER_NAME
