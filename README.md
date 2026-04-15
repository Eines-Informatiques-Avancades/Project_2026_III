
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
You must have the following tools installed:
* `fgsl`: Fortran interface for GSL.
* `gfortran`: GNU Compiler.
* `gnuplot`: Visualization tool.

## Project Structure
| Directory | Description |
| :--- | :--- |
| `temp_cte` | Monte Carlo simulations at constant temperature ($T = \text{const}$). |
| `temp_var` | Monte Carlo Simulations with variable initial temperatures ($T_0$). |

### Directory Contents
Each folder contains a self-contained environment with:
* **Automation**: A `Makefile` to manage compilation and execution.
* **Fortran Source**: 1 main program and 9 specialized modules (`.f90`).
* **Analysis Scripts**: 
  * 3 **Gnuplot** scripts for immediate visualization.
  * 3 **Python** scripts for advanced data processing.

# Execution Guide
Navigate to each directory (`temp_cte` or `temp_var`) and run the following `make` commands in order:

### 1. Main Simulations
* **`make run_all`**
  Runs simulations for **6 different temperatures**. It creates 6 directories with 5 files of data:
  * Distances.txt: it contains the squared radious of gyration and the squared end-to-end distance data during second half of simulation
  * Dihedral_angles.txt: it contains a list of all dihedral angles during second half of the simulation
  * Energy.txt: It contains total energy, LJ energy, dihedral energy and temperature (only in the simulation whixh temperature varies) of second half of the simulation
  * Trayectory.xyz: contains the coordinates of the molecule during siumlation
  * Log.txt: contains printed text during simulation
   
  and generates 3 summary files analyzing the evolution of:
  * Mean squared radius of gyration ($R_g^2$) vs T.
  * System energy vs T.
  * Dihedral angle distribution relative to temperature vs T.

* **`make all`**
  If you want to execute a **single simulation** at a predefined temperature.

### 2. Visualization
* **`make plot_local`**
  Generates graphs from the `.txt` files located within each temperature directory.

### 3. Cleanup
* **`make clean`**
  Removes all compiled files (`.mod`, `.o`), as well as the generated analysis directories and files.
  
* **`make clean_results`**
  Removes **only** the generated analysis directories and output files, keeping the compiled binaries intact.