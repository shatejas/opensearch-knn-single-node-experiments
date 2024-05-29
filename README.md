# OpenSearch Single Node KNN Experiments

## Overview

This repo contains a simple framework for running single node OpenSearch experiments for the k-NN plugin, using 
[Docker compose](https://docs.docker.com/compose/) and [OpenSearch Benchmarks](https://opensearch.org/docs/latest/benchmark/).

The goal is to provide highly configurable, yet easy to run end-to-end performance tests against OpenSearch k-NN with 
extensive metric tracking.

## Architecture

![images/high-level-architecture.png](images/high-level-architecture.png)

## Usage

### 1. Setup OSB

In the [osb](osb/) directory, add the custom parameters and workloads you want to run. 

TODO: Smooth this section out more

### 2. Setup docker compose environment file
There are several environment variables that need to be configured in order to run the docker compose setup

| Key Name           | Description                                                   |
|--------------------|---------------------------------------------------------------|
| RUN_ID             | Run identifier. Will be used in file names                    |
| TEST_REPO          | Link to k-NN repo. Plugin will be built from source from here |
| TEST_BRANCH        | k-NN branch name. Plugin will be built from source from here  |
| TEST_JVM           | Amount of JVM to be used for test container (i.e. 32g)        |
| TEST_CPU_COUNT     | Number of CPUs test container will get.                       |
| TEST_MEM_SIZE      | Amount of total memory test container will be limited at.     |
| METRICS_JVM        | Amount of JVM to be used for metrics container (i.e. 1g)      |
| METRICS_CPU_COUNT  | Number of CPUs metrics container will get.                    |
| METRICS_MEM_SIZE   | Amount of total memory metrics container will be limited at.  |
| OSB_PROCEDURE      | OSB procedure to be run                                       |
| OSB_PARAMS         | OSB params to be used (include .json extension)               |
| OSB_SHOULD_PROFILE | Should profiling be triggered for this run                    |
| OSB_CPU_COUNT      | Number of CPUs OSB gets                                       |
| OSB_MEM_SIZE       | Amount of memory OSB gets                                     |

Create a file called `test.env` and set these values.

### 3. Run
```commandline
docker compose --env-file test.env -f compose.yaml up -d
```

### 4. Stop
```commandline
docker compose --env-file test.env -f compose.yaml down
```


