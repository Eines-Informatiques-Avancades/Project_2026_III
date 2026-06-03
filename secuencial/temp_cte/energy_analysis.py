import numpy as np
import matplotlib.pyplot as plt
import glob
import os

# Temperature list
temps = [200.0, 300.0, 400.0, 500.0, 600.0, 700.0]
energy_means = []
energy_fluctuations = []

#Calculate mean and standard deviation of energy for each temperature
for t in temps:
    ruta = f"PARALEL_RESULTS/T_{t}/energy.txt" 
    if os.path.exists(ruta):
        data = np.loadtxt(ruta, usecols = 0)

        eq_index = (len(data) * 6 // 10)

        # We take equilibrium data (second half of the simulation)
    
        equilibrium_data = data[eq_index:] 
        
        energy_means.append(np.mean(equilibrium_data))
        energy_fluctuations.append(np.std(equilibrium_data))

# Plotear Energía vs Temperatura
plt.errorbar(temps, energy_means, yerr=energy_fluctuations, fmt='o-', capsize=5)
plt.xlabel('Temperature (K)')
plt.ylabel('Mean Total Energy in Equilibrium (kJ/mol)')

#Saving the plot in the directory GENERAL_PLOTS
working_dir = os.getcwd()
output_dir = os.path.join(working_dir, "PARALEL_RESULTS", "GENERAL_PLOTS")
os.makedirs(output_dir, exist_ok=True)  # Crea GENERAL_PLOTS si no existe
output_path = os.path.join(
    output_dir, "1_Energy_vs_Temperature.png"
)

plt.savefig(output_path)