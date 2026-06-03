import os
import matplotlib.pyplot as plt
import numpy as np

# Temperature list
temps = [200.0, 300.0, 400.0, 500.0, 600.0, 700.0]

data_dict = {}

for t in temps:
    ruta = f"PARALEL_RESULTS/T_{t}/dihedral_angles.txt"
    if os.path.exists(ruta):
        data = np.loadtxt(ruta, usecols=0)
        data_dict[t] = data

# Sort temperatures
sorted_temps = sorted(data_dict.keys())

# Creating one histogram per temperature
bins_angle = np.linspace(-180, 180, 181)

# Matrix to store the histograms
heatmap_matrix = []

for t in sorted_temps:
    hist, _ = np.histogram(data_dict[t], bins=bins_angle, density=True)
    heatmap_matrix.append(hist)

# Transpose the matrix to have temperatures in rows and angles in columns
heatmap_matrix = np.array(heatmap_matrix).T

# Plotting the heatmap
plt.figure(figsize=(12, 7))

# Cambiado sns.heatmap por plt.imshow
# aspect='auto' es crucial para que el mapa de calor se estire y llene el gráfico
im = plt.imshow(heatmap_matrix, cmap="viridis", aspect="auto", origin="upper")

# Configurar eje X (Temperaturas)
plt.xticks(ticks=np.arange(len(sorted_temps)), labels=sorted_temps)

# Configurar eje Y (Ángulos cada 10 pasos)
# Usamos las mismas posiciones (0 a 180 de 10 en 10) que mapean con bins_angle[::10]
plt.yticks(ticks=np.arange(0, 181, 10), labels=np.int32(bins_angle[::10]))

# Añadir la barra de color (equivalente a cbar_kws de seaborn)
cbar = plt.colorbar(im)
cbar.set_label("Density", rotation=270, labelpad=15, fontsize=12)

plt.title("Temperature vs Dihedral Angles", fontsize=15)
plt.xlabel("Temperature (K)", fontsize=12)
plt.ylabel("Dihedral Angle (degrees)", fontsize=12)

# Mantiene tu inversión del eje Y
plt.gca().invert_yaxis()

#Saving the plot in the directory GENERAL_PLOTS
working_dir = os.getcwd()
output_dir = os.path.join(working_dir, "PARALEL_RESULTS", "GENERAL_PLOTS")
os.makedirs(output_dir, exist_ok=True)  # Crea GENERAL_PLOTS si no existe
output_path = os.path.join(
    output_dir, "3_Heatmap_Dihedral_Angles_vs_Temperature.png"
)

plt.savefig(output_path)
