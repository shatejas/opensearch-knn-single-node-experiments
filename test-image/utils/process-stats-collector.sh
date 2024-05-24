#!/bin/bash

TELEMETRY_PATH=/share-data/telemetry
mkdir -p -m 777 ${TELEMETRY_PATH}

OS_PID=$1
RUN_ID=$2

# Check if the process exists
if ! ps -p $OS_PID &> /dev/null; then
    echo "Process $OS_PID does not exist."
    exit 1
fi

# Get the output file name
output_file="${TELEMETRY_PATH}/process-stats-${RUN_ID}.csv"

# Write the header row
echo "Timestamp,PID,CPU%,MEM(MB),MINOR_FAULTS,MAJOR_FAULTS,ANON_RSS(MB),ANON_FILE(MB)" > "$output_file"

# Run the script every 1 second and write the output to the file
while true; do
    # Get the current timestamp
    timestamp=$(date +"%Y-%m-%d %H:%M:%S")

    # Get page faults
    page_fault_info=$(ps -p $OS_PID -o minflt,majflt --no-headers)
    IFS=' ' read -ra page_fault_array <<< "$page_fault_info"
    minor_faults=${page_fault_array[0]}
    major_faults=${page_fault_array[1]}
    total_faults=$((minor_faults + major_faults))

    # Get anonymous memory usage
    anon_rss=$(grep "^RssAnon:" /proc/$OS_PID/status | awk '{print $2/1024}')
    anon_file=$(grep "^RssFile:" /proc/$OS_PID/status | awk '{print $2/1024}')

    # Get CPU usage
    cpu_usage=$(ps -p $OS_PID -o %cpu --no-headers)

    # Get memory usage
    mem_usage=$(ps -p $OS_PID -o rss --no-headers | awk '{print $1/1024}')

    # Write the data to the CSV file
    echo "$timestamp,$OS_PID,$cpu_usage%,$mem_usage,$minor_faults,$major_faults,$anon_rss,$anon_file" >> "$output_file"

    sleep 1
done
