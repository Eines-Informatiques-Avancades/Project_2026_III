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

# PROFILING$(PARFLAGS)
PROFFLAGS = -pg

#PARALELIZATION FLAGS
PARFLAGS = -qopenmp

#WARNING FLAGS
FFLAGS = $(PRODFLAGS) 

# 'make DEBUG=1' to compile with debugging flags
ifeq ($(DEBUG), 1)
    FFLAGS = $(DBFLAGS) 
endif

# 'make PROF=1' to compile with profiling flags
ifeq ($(PROF), 1)
	FFLAGS += $(PROFFLAGS)
	LDFLAGS += $(PROFFLAGS)
endif

# 'make PARAL=1' to compile with OpenMP support
ifeq ($(PARAL), 1)
	FFLAGS += $(PARFLAGS)
	LDFLAGS += $(PARFLAGS)
endif


#Compilation rules
TARGET = programa_mc.exe
OBJ = m_constants.o m_init_conf.o m_rot_dihedral.o m_energy.o \
      m_write.o m_ran_gen.o m_MC_step.o m_tower.o main.o m_distances.o

$(TARGET): $(OBJ)
	$(FC) $(FFLAGS) -o $(TARGET) $(OBJ) $(LDFLAGS)

%.o: %.f90
	$(FC) $(FFLAGS) -c $<

m_init_conf.o: m_init_conf.f90 m_constants.o
m_rot_dihedral.o: m_rot_dihedral.f90 m_constants.o
m_energy.o: m_energy.f90 m_constants.o m_rot_dihedral.o
m_write.o: m_write.f90 m_constants.o
m_tower.o: m_tower.f90 m_constants.o m_ran_gen.o
m_distances.o: m_distances.f90 m_constants.o
m_ran_gen.o: m_ran_gen.f90
m_MC_step.o: m_MC_step.f90 m_constants.o m_energy.o m_rot_dihedral.o m_ran_gen.o m_tower.o
main.o: main.f90 m_MC_step.o m_write.o m_constants.o m_init_conf.o m_energy.o m_distances.o


# --- Configuration of the simulation ---
TEMPS = 200.0 300.0 400.0 500.0 600.0 700.0

.PHONY: run_all
.PHONY: plot_general
run_all: $(TARGET)

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
