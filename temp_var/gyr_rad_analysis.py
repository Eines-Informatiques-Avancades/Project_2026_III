import numpy as np
import matplotlib.pyplot as plt
import glob
import os

# Temperature list
temps = [1000.0, 1300.0, 1600.0, 1900.0, 2200.0, 2500.0]
means = []
fluctuations = []

#Calculate mean and standard deviation of gyration radius for each temperature
for t in temps:
    ruta = f"T_{t}/gyr_rad.txt" 
    if os.path.exists(ruta):
        
        # We take equilibrium data (second half of the simulation)
        data = np.loadtxt(ruta, usecols = 1)
        
        means.append(np.mean(equilibrium_data))
        fluctuations.append(np.std(equilibrium_data))

# Plot Gyration Radius vs Temperatura
plt.errorbar(temps, means, yerr=fluctuations, fmt='o-', capsize=5)
plt.xlabel('Temperature (K)')
plt.ylabel('Mean Squared Gyration Radius in Equilibrium (Å**2)')
plt.savefig('Gyration_Radius_vs_Temperature.png')