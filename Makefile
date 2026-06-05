# --- Configuración del Compilador ---
FC = ifort
CC = icx

# FLAGS DE DEPURE (DEBUG)
# -g: información para GDB (líneas de código)
# -fcheck=all: comprueba índices de arrays, punteros, etc. en tiempo de ejecución
# -fbacktrace: imprime la línea del error si el programa muere
# -ffpe-trap=invalid,zero,overflow: para el programa si hay errores matemáticos (dividir por cero, etc.)
DBFLAGS = -g -fcheck=all -fbacktrace -ffpe-trap=invalid,zero,overflow

# OPTIMIZATION FLAGS (PRODUCTION)
PRODFLAGS = -O2 

#PARALELIZATION FLAGS
PARFLAGS = -qopenmp

#WARNING FLAGS
FFLAGS = $(PRODFLAGS) 

# 'make DEBUG=1' to compile with debugging flags
ifeq ($(DEBUG), 1)
    FFLAGS = $(DBFLAGS) 
endif

# 'make PARAL=1' to compile with OpenMP support
ifeq ($(PARAL), 1)
	FFLAGS += $(PARFLAGS)
	LDFLAGS += $(PARFLAGS)
endif


#Compilation rules
TARGET_PAR_CTE = programa_par_cte.exe
OBJ_PAR_CTE = m_constants.o m_init_conf.o m_rot_dihedral_par.o m_energy_par.o \
      m_write.o m_ran_gen.o m_MC_step_par.o m_tower.o main_temp_cte_par.o m_distances.o

TARGET_PAR_VAR = programa_par_var.exe
OBJ_PAR_VAR = m_constants.o m_init_conf.o m_rot_dihedral_par.o m_energy_par.o \
      m_write.o m_ran_gen.o m_MC_step_par.o m_tower.o main_temp_var_par.o m_distances.o

TARGET_SEC_CTE = programa_sec_cte.exe
OBJ_SEC_CTE = m_constants.o m_init_conf.o m_rot_dihedral.o m_energy.o \
	  m_write.o m_ran_gen.o m_MC_step.o m_tower.o main_temp_cte_sec.o m_distances.o

TARGET_SEC_VAR = programa_sec_var.exe
OBJ_SEC_VAR = m_constants.o m_init_conf.o m_rot_dihedral.o m_energy.o \
	  m_write.o m_ran_gen.o m_MC_step.o m_tower.o main_temp_var_sec.o m_distances.o

$(TARGET_PAR_CTE): $(OBJ_PAR_CTE)
	$(FC) $(FFLAGS) -o $(TARGET_PAR_CTE) $(OBJ_PAR_CTE) $(LDFLAGS)

$(TARGET_PAR_VAR): $(OBJ_PAR_VAR)
	$(FC) $(FFLAGS) -o $(TARGET_PAR_VAR) $(OBJ_PAR_VAR) $(LDFLAGS)

$(TARGET_SEC_CTE): $(OBJ_SEC_CTE)
	$(FC) $(FFLAGS) -o $(TARGET_SEC_CTE) $(OBJ_SEC_CTE) $(LDFLAGS)

$(TARGET_SEC_VAR): $(OBJ_SEC_VAR)
	$(FC) $(FFLAGS) -o $(TARGET_SEC_VAR) $(OBJ_SEC_VAR) $(LDFLAGS)

%.o: %.f90
	$(FC) $(FFLAGS) -c $<

m_init_conf.o: modules/m_init_conf.f90 m_constants.o
m_rot_dihedral.o: modules/m_rot_dihedral.f90 m_constants.o
m_energy.o: modules/m_energy.f90 m_constants.o m_rot_dihedral.o
m_write.o: modules/m_write.f90 m_constants.o
m_tower.o: modules/m_tower.f90 m_constants.o m_ran_gen.o
m_distances.o: modules/m_distances.f90 m_constants.o
m_ran_gen.o: modules/m_ran_gen.f90
m_MC_step.o: modules/m_MC_step.f90 m_constants.o m_energy.o m_rot_dihedral.o m_ran_gen.o m_tower.o
main_temp_cte_par.o: main/main_temp_cte_par.f90 m_MC_step_par.o m_write.o m_constants.o m_init_conf.o m_energy_par.o m_distances.o
main_temp_var_par.o: main/main_temp_var_par.f90 m_MC_step_par.o m_write.o m_constants.o m_init_conf.o m_energy_par.o m_distances.o

m_rot_dihedral_par.o: omp_modules/m_rot_dihedral_par.f90 m_constants.o
m_energy_par.o: omp_modules/m_energy_par.f90 m_constants.o m_rot_dihedral_par.o
m_MC_step_par.o: omp_modules/m_MC_step_par.f90 m_constants.o m_energy_par.o m_rot_dihedral_par.o m_ran_gen.o m_tower.o

main_temp_cte_par.o: main/main_temp_cte_par.f90 m_MC_step_par.o m_write.o m_constants.o m_init_conf.o m_energy_par.o m_distances.o
main_temp_var_par.o: main/main_temp_var_par.f90 m_MC_step_par.o m_write.o m_constants.o m_init_conf.o m_energy_par.o m_distances.o
main_temp_cte_sec.o: main/main_temp_cte_sec.f90 m_MC_step.o m_write.o m_constants.o m_init_conf.o m_energy.o m_distances.o
main_temp_var_sec.o: main/main_temp_var_sec.f90 m_MC_step.o m_write.o m_constants.o m_init_conf.o m_energy.o m_distances.o

# --- Configuration of the simulation ---
TEMPS = 200.0 300.0 400.0 500.0 600.0 700.0

.PHONY: run_all
.PHONY: plot_general
run_par_cte: $(TARGET_PAR_CTE)
run_par_var: $(TARGET_PAR_VAR)
run_sec_cte: $(TARGET_SEC_CTE)
run_sec_var: $(TARGET_SEC_VAR)

#General plots

plot_general:$(ALL_TXT)
	mkdir -p PARALEL_RESULTS/GENERAL_PLOTS/ 
	@echo "Generating general plots."
	python3 energy_analysis.py
	python3 gyr_rad_analysis.py
	python3 heatmap_dihedral.py	
	@echo "General plots generated."

#Local plots for each temperature

ALL_PNGS = $(foreach t, $(TEMPS), PARALEL_RESULTS/LOCAL_PLOTS/T_$(t)/dih_dist.png PARALEL_RESULTS/LOCAL_PLOTS/T_$(t)/energy.png PARALEL_RESULTS/LOCAL_PLOTS/T_$(t)/distances.png)
ALL_TXT =  $(foreach t, $(TEMPS), T_$(t)/dihedral_angles.txt T_$(t)/energy.txt T_$(t)/distances.txt)

.PHONY: plot_local

plot_local: $(ALL_PNGS)
	@echo "Local plots generated."

PARALEL_RESULTS/LOCAL_PLOTS/T_%/dih_dist.png: PARALEL_RESULTS/T_%/dihedral_angles.txt
	mkdir -p PARALEL_RESULTS/LOCAL_PLOTS/T_$*/
	@echo "Generating dihedral angle distribution for T=$*..."
	gnuplot -e "INFILE='PARALEL_RESULTS/T_$*/dihedral_angles.txt'; OUTFILE='$@'; TEMP='$*'" dihedral.gnu

PARALEL_RESULTS/LOCAL_PLOTS/T_%/energy.png: PARALEL_RESULTS/T_%/energy.txt
	@echo "Generating energy plot for T=$*..."
	gnuplot -e "INFILE='PARALEL_RESULTS/T_$*/energy.txt'; OUTFILE='$@'; TEMP='$*'" energy.gnu


PARALEL_RESULTS/LOCAL_PLOTS/T_%/distances.png: PARALEL_RESULTS/T_%/distances.txt
	@echo "Generating distance distribution for T=$*..."
	gnuplot -e "INFILE='PARALEL_RESULTS/T_$*/distances.txt'; OUTFILE='$@'; TEMP='$*'" distances.gnu



# 'make clean_tmpdir' or 'make clean_results' to clean results of the simulations
.PHONY: clean_tmpdir clean_results

# Cleaning tmpdir to clean tmpdir of cluster
clean_tmpdir:
	@echo "Cleaning tmpdir..."
	rm -rf *

# 'Make clean_results' only to cleaning directories of simulation
clean_results:
	@echo "Cleaning analysis files and directories..."
	rm -rf PARALEL_RESULTS/ *.err *.out 
