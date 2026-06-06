
# Project_2026_III

## Participants
* **Javier Jorge Fernández**

## Brief Methodology
This program implements a **Monte Carlo simulation** designed to model a simplified polyethylene chain consisting of **500 monomers**. The methodology is based on the following key considerations:

* **United Atom Model:** Each methyl and methylene unit ($-CH_2$ and $-CH_3$) is treated as a single interaction sphere. This reduces the computational cost by decreasing the number of force centers while maintaining physical accuracy.
* **Lennard-Jones (LJ) Potential:** Non-bonded interactions are calculated using the $\sigma$ and $\epsilon$ parameters extracted directly from the referenced scientific article.
* **Versatility and Customization:** The code is highly adaptable. Global constants can be modified to simulate other types of polymers by adjusting the LJ parameters. Additionally, the working temperature and the total number of simulation steps can be configured to study various thermodynamic regimes.

## Scientific Reference
Dihedral energy function $E(\phi)$ in polyethylene chains and LJ parameters extracted from this article
[Read article here](https://www-sciencedirect-com.sire.ub.edu/science/article/pii/S2213138822001485)

## Prerequisites
This program was done to be executted in cerqt03.q node. Acces to this node is unique requisite

## Project Structure

The proyect `Project_2026_III` have the following files and directories organization:

```text
Project_2026_III/
├── Makefile
├── README.md
├── bin/
├── gen_plot_scripts/
│   ├── energy_analysis.py
│   ├── gyr_rad_analysis.py
│   └── heatmap_dihedral.py
├── local_plot_scripts/
│   ├── dihedral.gnu
│   ├── distances.gnu
│   └── energy.gnu
├── main/
│   ├── main_temp_cte_par.f90
│   ├── main_temp_var_par.f90
│   ├── main_temp_cte_sec.f90
│   └── main_temp_var_sec.f90
├── modules/
│   ├── m_MC_step.f90
│   ├── m_constants.f90
│   ├── m_distances.f90
│   ├── m_energy.f90
│   ├── m_init_conf.f90
│   ├── m_ran_gen.f90
│   ├── m_rot_dihedral.f90
│   ├── m_tower.f90
│   └── m_write.f90
├── omp_modules/
│   ├── m_MC_step_par.f90
│   ├── m_energy_par.f90
│   └── m_rot_dihedral_par.f90
├── paralel/
│   ├── temp_cte/
│   │   └── run.sh
│   └── temp_var/
│       └── run.sh
├── secuential/
│   ├── temp_cte/
│   │   └── run.sh
│   └── temp_var/
│       └── run.sh
└── paralel_analysis/
    ├── efficiency.png
    ├── speedup.png
    ├── plot_speedup_efficiency.py
    └── speedup_per_thread.txt
```

### Directory Contents

* **`bin/`**: Contains the pre-compiled standalone binary executable of Gnuplot, ensuring the plotting scripts can run seamlessly on any cluster node without depending on system-wide installations.
* **`gen_plot_scripts/`**: Includes Python scripts designed to generate plots comparing different physical magnitudes across multiple simulations at various temperatures.
* **`local_plot_scripts/`**: Contains Gnuplot scripts used to generate plots of different magnitudes for a single simulation at a specific reference temperature.
* **`modules/`**: Contains the core, non-parallelized Fortran modules containing the subroutines and functions for the simulation.
* **`omp_modules/`**: Contains the Fortran modules that have been parallelized using OpenMP (`omp`) to improve performance.
* **`main/`**: Holds the four main Fortran program files, separated according to the simulation parameters: constant vs. variable temperature, and sequential vs. parallel execution.
* **`paralel/` & `secuential/`**: Contain the `run.sh` bash scripts used to submit the simulation jobs to the cluster queue and gather the resulting data.
* **`paralel_analysis/`**: Contains the performance analysis of the OpenMP implementation. It includes two `.png` plots showing the efficiency and speedup as a function of the number of threads, a `.txt` file collecting the exact computation times for each thread configuration, and the Python script used to generate these visualizations.

## Execution Guide

Before starting, ensure that the entire project folder is uploaded to your personal directory on the cluster.

### 1. Running the Simulations

The first step is to execute the Fortran code to generate the simulation data. 

1.  **Choose your execution mode:** Navigate to either the `paralel/` directory (for OpenMP parallel execution) or the `secuencial/` directory (for single-thread execution).
2.  **Choose your temperature scheme:** * If you want to run simulations at 6 fixed temperatures (where the temperature remains constant during each simulation), navigate to the `temp_cte/` subdirectory.
    * If you want the temperature to vary during the simulation, navigate to the `temp_var/` subdirectory.
3.  **Submit the job:** Once inside the desired directory (`paralel/temp_cte/`, `secuencial/temp_var/`, etc.), submit the job to the queue using:
    ```bash
    qsub run.sh
    ```
    
**Output:** When the simulation finishes, a `RESULTS/` folder will be generated in the directory where you submitted the script. Inside `RESULTS/`, you will find 6 directories corresponding to the simulated temperatures (`T_200`, `T_300`, `T_400`, `T_500`, `T_600`, `T_700`). Each of these subdirectories contains the following output data:
* `dihedral_angles.txt`
* `distances.txt`
* `energy.txt`
* `trayectory.txt`

*(Note: If you ran the simulation in the `paralel/` directory, an additional file named `timing_data.txt` will be generated, containing the execution times).*

---

### 2. Generating General Plots

To generate plots that compare physical magnitudes across all simulated temperatures:

1.  **Move the results:** Copy the newly generated `RESULTS/` folder to the root directory of the project. You can do this from the directory where `run.sh` was executed:
    ```bash
    cp -r RESULTS/ ../../
    ```
2.  **Activate Python Environment:** The general plots are generated using Python scripts. You need to activate a Conda environment with the required libraries. *(Recommendation: If you don't have a Conda environment in your personal node, start an interactive session on `cerqt03` and run `conda activate cmm`)*.
3.  **Execute the plotting command:** From the root directory of the project, run:
    ```bash
    make plot_general
    ```

**Output:** Inside the root `RESULTS/` folder, a new directory named `GENERAL_PLOTS/` will be created containing 3 graphs:
* `1_Energy_vs_Temperature.png`
* `2_Gyration_Radius_vs_Temperature.png`
* `3_Heatmap_Dihedral_Angles_vs_Temperature.png`

---

### 3. Generating Local Plots

To generate specific plots for a single simulation at a specific reference temperature:

1.  Ensure the `RESULTS/` folder is located in the root directory of the project.
2.  From the root directory, execute:
    ```bash
    make plot_local
    ```

**Output:** A new directory named `LOCAL_PLOTS/` will be generated inside the root `RESULTS/` folder. This directory contains 6 subdirectories (one for each temperature). Inside each subdirectory, you will find 3 graphs specific to that temperature:
* `dih_dist.png`
* `energy.png`
* `distances.png`

---

### 4. Cleaning Up Results

To remove the output data generated by the simulations and maintain a clean workspace:

1.  From the root directory of the project, execute:
    ```bash
    make clean_results
    ```
    This command will search for and delete the `RESULTS/` folders located inside the `paralel/` and `secuencial/` subdirectories.
2.  **Note:** If you copied the `RESULTS/` folder to the root directory of the project (as instructed in Steps 2 and 3), the `make` command will not delete it automatically to prevent accidental data loss. To remove the root results folder, you must do it manually:
    ```bash
    rm -r RESULTS/
    ```