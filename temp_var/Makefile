# --- Compiler configuration ---
FC = gfortran

# DEPURE FLAGS (DEBUG)
# -g: información para GDB (líneas de código)
# -fcheck=all: comprueba índices de arrays, punteros, etc. en tiempo de ejecución
# -fbacktrace: imprime la línea del error si el programa muere
# -ffpe-trap=invalid,zero,overflow: para el programa si hay errores matemáticos (dividir por cero, etc.)
DBFLAGS = -g -fcheck=all -fbacktrace -ffpe-trap=invalid,zero,overflow

# OPTIMIZATION FLAGS (PRODUCTION)
PRODFLAGS = -O2

# PROFILING FLAGS
PROFFLAGS = -pg

# Common flags for both production and profiling builds
FFLAGS = $(PRODFLAGS) -Wall `pkg-config --cflags fgsl`
LDFLAGS = `pkg-config --libs fgsl`

# 'make DEBUG=1' to compile with debugging flags
ifeq ($(DEBUG), 1)
    FFLAGS = $(DBFLAGS) -Wall `pkg-config --cflags fgsl`
endif

# 'make PROF=1' to compile with profiling flags
ifeq ($(PROF), 1)
	FFLAGS += $(PROFFLAGS)
	LDFLAGS += $(PROFFLAGS)
endif

#Compilation rules
TARGET = programa_mc.exe
OBJ = m_constants.o m_init_conf.o m_rot_dihedral.o m_energy.o \
      m_write.o m_ran_gen.o m_MC_step.o m_tower.o main.o m_distances.o

all: $(TARGET)
	@echo "Compilation finished. Executing the program with default temperature..."
	./$(TARGET)

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


.PHONY: all

# --- Configuration of the simulation ---
TEMPS = 1000.0 1300.0 1600.0 1900.0 2200.0 2500.0

.PHONY: run_all
run_all: $(TARGET)
	@echo "Inicializing temperature loop..."
	@for t in $(TEMPS); do \
		mkdir -p T_$$t; \
		echo "Running T=$$t..."; \
		./$(TARGET) $$t > T_$$t/log.txt; \
		mv energy.txt distances.txt dihedral_angles.txt distances.txt trajectory.xyz T_$$t/ 2>/dev/null || true; \
	done
	@echo "Simulations finished. Executing global analysis..."
	python3 energy_analysis.py
	python3 gyr_rad_analysis.py
	python3 heatmap_dihedral.py

#Local plots for each temperature

ALL_PNGS = $(foreach t, $(TEMPS), T_$(t)/dih_dist.png T_$(t)/energy.png T_$(t)/distances.png)

.PHONY: plot_local

plot_local: $(ALL_PNGS)
	@echo "Local plots generated."

T_%/dih_dist.png: T_%/dihedral_angles.txt
	@echo "Generating dihedral angle distribution for T=$*..."
	gnuplot -e "INFILE='$<'; OUTFILE='$@'; TEMP='$*'" dihedral.gnu


T_%/energy.png: T_%/energy.txt
	@echo "Generating energy plot for T=$*..."
	gnuplot -e "INFILE='$<'; OUTFILE='$@'; TEMP='$*'" energy.gnu


T_%/distances.png: T_%/distances.txt
	@echo "Generating distance distribution for T=$*..."
	gnuplot -e "INFILE='$<'; OUTFILE='$@'; TEMP='$*'" distances.gnu
	
#Clean configuration for simulation outputs
DIRS = $(patsubst %, T_%, $(TEMPS))

# 'make clean' or 'make clean_results' to clean results of the simulations
.PHONY: clean clean_results

# Total clean: remove all generated files, including executables and object files
clean: clean_results
	@echo "Cleaning compilation files..."
	rm -f $(OBJ) *.mod $(TARGET) *.

# 'Make clean_results' only to cleaning directories of simulation
clean_results:
	@echo "Cleaning analysis files and directories..."
	rm -rf $(DIRS)
	rm -f *.png