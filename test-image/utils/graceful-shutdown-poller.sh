#!/bin/bash

# Check if profile needs to be taken. Expectation is that /share-data/profile.txt
# will contain args to execute
SET_STOP_PROCESS_FILE=/share-data/stop.txt

OS_PID=$1

while true; do
  if [ -f ${SET_STOP_PROCESS_FILE} ]; then
    rm ${SET_STOP_PROCESS_FILE}
    echo "Stopping process gracefully"
    kill ${OS_PID}
  fi
  sleep 1
done
