# SPDX-License-Identifier: Apache-2.0
#
# The OpenSearch Contributors require contributions made to
# this file be licensed under the Apache-2.0 license or a
# compatible open source license.
import time

from opensearchpy import ConnectionTimeout
from osbenchmark.client import RequestContextHolder
from osbenchmark.utils.parse import parse_string_parameter, parse_int_parameter
from osbenchmark.worker_coordinator.runner import Retry, Runner


def register(registry):
    registry.register_runner(
        BulkVectorDelete.RUNNER_NAME, BulkVectorDelete(), async_runner=True
    )

request_context_holder = RequestContextHolder()

class BulkVectorDelete(Runner):

    RUNNER_NAME = 'bulk_vector_delete'
    async def __call__(self, opensearch, params):
        size = parse_int_parameter("size", params)
        retries = parse_int_parameter("retries", params, 0) + 1

        for attempt in range(retries):
            try:
                request_context_holder.on_client_request_start()
                await opensearch.bulk(
                    body=params["body"]
                )
                request_context_holder.on_client_request_end()

                return size, "docs"
            except ConnectionTimeout:
                self.logger.warning("Bulk vector ingestion timed out. Retrying attempt: %d", attempt)

        raise TimeoutError("Failed to submit bulk request in specified number "
                           "of retries: {}".format(retries))

    def __repr__(self, *args, **kwargs):
        return RUNNER_NAME