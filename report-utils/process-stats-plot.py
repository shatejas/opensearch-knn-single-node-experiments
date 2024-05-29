import sys
import csv
import matplotlib.pyplot as plt

# Check if a CSV file path was provided as a command-line argument
if len(sys.argv) < 2:
    print("Usage: python process_stats.py <csv_file_path>")
    sys.exit(1)

# Get the CSV file path from the command-line argument
csv_file = sys.argv[1]
output = sys.argv[2]

# Initialize lists to store the metrics
timestamps = []
cpu_usage = []
memory_usage = []
minor_faults = []
major_faults = []
anon_rss = []
anon_file = []

# Read the CSV file
with open(csv_file, 'r') as file:
    reader = csv.DictReader(file)
    for row in reader:
        timestamps.append(row['Timestamp'])
        cpu_usage.append(float(row['CPU%'][:-1]))
        memory_usage.append(float(row['MEM(MB)']))
        minor_faults.append(float(row['MINOR_FAULTS']))
        major_faults.append(float(row['MAJOR_FAULTS']))
        anon_rss.append(float(row['ANON_RSS(MB)']))
        anon_file.append(float(row['ANON_FILE(MB)']))


max_ticks = 2
x_ticks = [timestamps[i] for i in range(0, len(timestamps), len(timestamps) // max_ticks)]

# Generate the graphs
plt.figure(figsize=(12, 8))

plt.subplot(3, 2, 1)
plt.plot(timestamps, cpu_usage)
plt.gca().set_xticks(x_ticks)
plt.title("CPU Usage")
plt.xlabel("Time")
plt.ylabel("CPU Usage (%)")

plt.subplot(3, 2, 2)
plt.plot(timestamps, memory_usage)
plt.gca().set_xticks(x_ticks)
plt.title("Memory Usage")
plt.xlabel("Time")
plt.ylabel("Memory (MB)")

plt.subplot(3, 2, 3)
plt.plot(timestamps, minor_faults)
plt.gca().set_xticks(x_ticks)
plt.title("Minor Page Faults")
plt.xlabel("Time")
plt.ylabel("Page Faults")

plt.subplot(3, 2, 4)
plt.plot(timestamps, major_faults)
plt.gca().set_xticks(x_ticks)
plt.title("Major Page Faults")
plt.xlabel("Time")
plt.ylabel("Page Faults")

plt.subplot(3, 2, 5)
plt.plot(timestamps, anon_rss)
plt.gca().set_xticks(x_ticks)
plt.title("Anonymous RSS")
plt.xlabel("Time")
plt.ylabel("Memory (MB)")

plt.subplot(3, 2, 6)
plt.plot(timestamps, anon_file)
plt.gca().set_xticks(x_ticks)
plt.title("Anonymous File")
plt.xlabel("Time")
plt.ylabel("Memory (MB)")

plt.tight_layout()
plt.savefig(output)
print("Graphs saved to {}".format(output))
