import matplotlib.pyplot as plt
import re

# Parse the data from the file
data = []
with open('speedup_per_thread.txt', 'r') as f:
    for line in f:
        # Extract thread count and time
        match = re.search(r'(\d+)\s+thread.*?(\d+\.?\d*)', line)
        if match:
            threads = int(match.group(1))
            time = float(match.group(2))
            data.append((threads, time))

# Sort by thread count
data.sort()

# Extract P and time values
P = [item[0] for item in data]
times = [item[1] for item in data]

# Get time for P=1 (sequential)
time_p1 = times[P.index(1)]

# Calculate speedup: speedup(P) = time(P=1)/time(P)
speedup = [time_p1 / t for t in times]

# Calculate efficiency: efficiency(P) = speedup(P)/P
efficiency = [s / p for s, p in zip(speedup, P)]

# Create speedup plot
plt.figure(figsize=(10, 6))
plt.plot(P, speedup, 'bo-', label='Actual', linewidth=2, markersize=8)
plt.plot(P, P, 'r--', label='Ideal', linewidth=2)
plt.xlabel('Number of threads (P)', fontsize=12)
plt.ylabel('Speedup(P)', fontsize=12)
plt.title('Speedup', fontsize=14, fontweight='bold')
plt.grid(True, alpha=0.3)
plt.legend(fontsize=12)
plt.xticks(P)
plt.savefig('speedup.png', dpi=300, bbox_inches='tight')
plt.close()

# Create efficiency plot
plt.figure(figsize=(10, 6))
plt.plot(P, efficiency, 'bo-', label='Actual', linewidth=2, markersize=8)
plt.plot([min(P), max(P)], [1, 1], 'r--', label='Ideal', linewidth=2)
plt.xlabel('Number of threads (P)', fontsize=12)
plt.ylabel('Efficiency(P)', fontsize=12)
plt.title('Efficiency', fontsize=14, fontweight='bold')
plt.grid(True, alpha=0.3)
plt.legend(fontsize=12)
plt.xticks(P)
plt.ylim(0, 1.1)
plt.savefig('efficiency.png', dpi=300, bbox_inches='tight')
plt.close()

print("Graphs created successfully!")
print(f"Speedup graph saved as: speedup.png")
print(f"Efficiency graph saved as: efficiency.png")
