import numpy as np
import matplotlib.pyplot as plt
import glob
import os

# Temperature list
temps = [200.0, 300.0, 400.0, 500.0, 600.0, 700.0]
means = []
fluctuations = []

#Calculate mean and standard deviation of gyration radius for each temperature
for t in temps:
    ruta = f"RESULTS/T_{t}/distances.txt" 
    if os.path.exists(ruta):
        
        # We take equilibrium data (second half of the simulation)
        equilibrium_data = np.loadtxt(ruta, usecols = 1)
        
        means.append(np.mean(equilibrium_data))
        fluctuations.append(np.std(equilibrium_data))

# Plot Gyration Radius vs Temperatura
plt.errorbar(temps, means, yerr=fluctuations, fmt='o-', capsize=5)
plt.xlabel('Temperature (K)')
plt.ylabel('Mean Squared Gyration Radius in Equilibrium (Å**2)')


#Saving the plot in the directory GENERAL_PLOTS
working_dir = os.getcwd()
output_dir = os.path.join(working_dir, "RESULTS", "GENERAL_PLOTS")
os.makedirs(output_dir, exist_ok=True)  # Crea GENERAL_PLOTS si no existe
output_path = os.path.join(
    output_dir, "2_Gyration_Radius_vs_Temperature.png"
)

plt.savefig(output_path)