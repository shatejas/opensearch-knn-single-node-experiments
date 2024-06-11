#!/bin/bash

OUTPUT_PATH=$1

# Collect io stats (https://www.man7.org/linux/man-pages/man1/iostat.1.html)
# Set the interval in seconds between iostat runs
interval=5

# Set the device to monitor
device="nvme0n1"
device_path="/dev/$device"

while true; do
    # Run iostat and capture the output
    iostat_output=$(iostat -d -k $device_path 1 1)
    tps=$(echo "$iostat_output" | grep "$device" | awk '{print $2}')
    kb_read_ps=$(echo "$iostat_output" | grep "$device" | awk '{print $3}')
    kb_write_ps=$(echo "$iostat_output" | grep "$device" | awk '{print $4}')
    echo "$tps,$kb_read_ps,$kb_write_ps" >> $OUTPUT_PATH
    sleep $interval
done
