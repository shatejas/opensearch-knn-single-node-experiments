from typing import List, Dict, Any

import numpy as np
from osbenchmark.utils.dataset import Context
from osbenchmark.utils.parse import parse_string_parameter, parse_int_parameter
from osbenchmark.workload.params import VectorDataSetPartitionParamSource

"""
Custom parameter sources so that we can use rescore k-NN functionality in order to 
get the top k nearest neighbors. 
"""


def register(registry):
    registry.register_param_source(
        "bulk-vector-delete", BulkDeleteVectorsFromDataSetParamSource
    )


class BulkDeleteVectorsFromDataSetParamSource(VectorDataSetPartitionParamSource):
    DEFAULT_RETRIES = 10
    PARAMS_NAME_ID_FIELD_NAME = "id-field-name"
    DEFAULT_ID_FIELD_NAME = "_id"

    def __init__(self, workload, params, **kwargs):
        super().__init__(workload, params, Context.DELETE, **kwargs)
        print("\ndata_set_path: ", self.data_set_path)
        self.bulk_size: int = parse_int_parameter("bulk_size", params)
        self.retries: int = parse_int_parameter("retries", params,
                                                self.DEFAULT_RETRIES)
        self.index_name: str = parse_string_parameter("index", params)
        self.id_field_name: str = parse_string_parameter(
            self.PARAMS_NAME_ID_FIELD_NAME, params, self.DEFAULT_ID_FIELD_NAME)

    def bulk_transform(self, partition: np.ndarray, action) -> List[Dict[str, Any]]:
        """Partitions and transforms a list of vectors into OpenSearch's bulk
        injection format.
        Args:
            offset: to start counting from
            partition: An array of vectors to transform.
            action: Bulk API action.
        Returns:
            An array of transformed vectors in bulk format.
        """
        actions = []
        for item in partition:
            results = action(self.id_field_name, item)
            actions.extend([results])

        return actions