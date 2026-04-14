import numpy as np
import matplotlib.pyplot as plt
import glob
import os

# Temperature list
temps = [1000.0, 1300.0, 1600.0, 1900.0, 2200.0, 2500.0]
energy_means = []
energy_fluctuations = []

#Calculate mean and standard deviation of energy for each temperature
for t in temps:
    ruta = f"T_{t}/energy.txt" 
    if os.path.exists(ruta):
        data = np.loadtxt(ruta, usecols = 0)

        half = len(data) // 2

        # We take equilibrium data (second half of the simulation)
    
        equilibrium_data = data[half:] 
        
        energy_means.append(np.mean(equilibrium_data))
        energy_fluctuations.append(np.std(equilibrium_data))

# Plotear Energía vs Temperatura
plt.errorbar(temps, energy_means, yerr=energy_fluctuations, fmt='o-', capsize=5)
plt.xlabel('Temperature (K)')
plt.ylabel('Mean Total Energy in Equilibrium (kJ/mol)')
plt.savefig('1_Total_Energy_vs_Temperature.png')