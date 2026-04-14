import numpy as np
import matplotlib.pyplot as plt
import seaborn as sns
import os

# Temperature list
temps = [1000.0, 1300.0, 1600.0, 1900.0, 2200.0, 2500.0]

data_dict = {}

for t in temps:
    ruta = f"T_{t}/dihedral_angles.txt" 
    if os.path.exists(ruta):
        data = np.loadtxt(ruta, usecols = 0)
        data_dict[t] = data

#Sort temperatures
sorted_temps = sorted(data_dict.keys())

#Creating one histogram per temperature
bins_angle = np.linspace(-180, 180, 181)

#Matrix to store the histograms
heatmap_matrix = []

for t in sorted_temps:
    hist, _ = np.histogram(data_dict[t], bins=bins_angle, density = True)
    heatmap_matrix.append(hist)

#Trasnpose the matrix to have temperatures in rows and angles in columns
heatmap_matrix = np.array(heatmap_matrix).T

#Plotting the heatmap
plt.figure(figsize=(12, 7))
sns.heatmap(heatmap_matrix,
            xticklabels=sorted_temps,
            yticklabels=np.int32(bins_angle[::10]),
            cmap="viridis",
            cbar_kws={'label': 'Density'})

#Adjusting Y axis to show angles from -180 to 180
plt.yticks(np.arange(0, 181, 10), np.int32(bins_angle[::10]))

plt.title('Temperature vs Dihedral Angles', fontsize=15)
plt.xlabel('Temperature (K)', fontsize=12)
plt.ylabel('Dihedral Angle (degrees)', fontsize=12)
plt.gca().invert_yaxis() 
plt.tight_layout()
plt.savefig('3_Heatmap_Dihedral_Angles_vs_Temperature.png')