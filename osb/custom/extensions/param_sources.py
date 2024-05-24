from osbenchmark.utils.parse import parse_string_parameter, parse_int_parameter
from osbenchmark.workload.params import VectorSearchPartitionParamSource, SearchParamSource
from osbenchmark import exceptions

"""
Custom parameter sources so that we can use rescore k-NN functionality in order to 
get the top k nearest neighbors. 
"""


def register(registry):
    registry.register_param_source(
        "knn-with-rescore-query", KNNQueryWithRescoreParamSource
    )


class KNNQueryWithRescoreParamSource(SearchParamSource):
    def __init__(self, workload, params, **kwargs):
        super().__init__(workload, params, **kwargs)
        self.delegate_param_source = KNNQueryWithRescoreQueryParamSource(workload, params, self.query_params, **kwargs)
        self.corpora = self.delegate_param_source.corpora

    def partition(self, partition_index, total_partitions):
        return self.delegate_param_source.partition(partition_index, total_partitions)

    def params(self):
        raise exceptions.WorkloadConfigError("Do not use a VectorSearchParamSource without partitioning")


class KNNQueryWithRescoreQueryParamSource(VectorSearchPartitionParamSource):

    PARAMS_NAME_RESCORE = "rescore"

    def __init__(self, workloads, params, query_params, **kwargs):
        super().__init__(workloads, params, query_params, **kwargs)
        self.space_type = parse_string_parameter("space_type", params, "l2")
        self.should_rescore = parse_string_parameter("should_rescore", params, "no")
        self.rescore_factor = parse_int_parameter("rescore_factor", params, 1)

    def _update_body_params(self, vector):
        # accept body params if passed from workload, else, create empty dictionary
        body_params = self.query_params.get(self.PARAMS_NAME_BODY) or dict()
        if self.PARAMS_NAME_SIZE not in body_params:
            body_params[self.PARAMS_NAME_SIZE] = self.k
        if self.PARAMS_NAME_QUERY in body_params:
            self.logger.warning(
                "[%s] param from body will be replaced with vector search query.", self.PARAMS_NAME_QUERY)
        # Potentially rescore based on full precision vectors
        if self.should_rescore == "yes":
            body_params[self.PARAMS_NAME_RESCORE] = {
                "window_size": self.k * self.rescore_factor,
                "query": {
                    "rescore_query": {
                        "script_score": {
                            "query": {
                                "match_all": {}
                            },
                            "script": {
                                "lang": "knn",
                                "source": "knn_score",
                                "params": {
                                    "field": self.field_name,
                                    "query_value": vector,
                                    "space_type": self.space_type
                                }
                            }
                        }
                    },
                    "query_weight": 0,
                    "rescore_query_weight": 1
                }
            }

        efficient_filter=self.query_params.get(self.PARAMS_NAME_FILTER)
        # override query params with vector search query
        body_params[self.PARAMS_NAME_QUERY] = self._build_vector_search_query_body(vector, efficient_filter)
        self.query_params.update({self.PARAMS_NAME_BODY: body_params})

    def _build_vector_search_query_body(self, vector, efficient_filter=None) -> dict:
        """Builds a k-NN request that can be used to execute an approximate nearest
        neighbor search against a k-NN plugin index
        Args:
            vector: vector used for query
        Returns:
            A dictionary containing the body used for search query
        """
        query = {
            "vector": vector,
            "k": self.k * self.rescore_factor,
        }
        if efficient_filter:
            query.update({
                "filter": efficient_filter,
            })
        return {
            "knn": {
                self.field_name: query,
            },
        }
