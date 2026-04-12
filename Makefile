# --- Configuración del Compilador ---
FC = gfortran

# FLAGS DE DEPURE (DEBUG)
# -g: información para GDB (líneas de código)
# -fcheck=all: comprueba índices de arrays, punteros, etc. en tiempo de ejecución
# -fbacktrace: imprime la línea del error si el programa muere
# -ffpe-trap=invalid,zero,overflow: para el programa si hay errores matemáticos (dividir por cero, etc.)
DBFLAGS = -g -fcheck=all -fbacktrace -ffpe-trap=invalid,zero,overflow

# FLAGS DE OPTIMIZACIÓN (PRODUCCIÓN)
PRODFLAGS = -O2

# FLAGS DE PROFILING
PROFFLAGS = -pg

# Por defecto usamos producción, a menos que se diga lo contrario
FFLAGS = $(PRODFLAGS) -Wall `pkg-config --cflags fgsl`
LDFLAGS = `pkg-config --libs fgsl`

# 'make DEBUG=1' para compilar con depuración
ifeq ($(DEBUG), 1)
    FFLAGS = $(DBFLAGS) -Wall `pkg-config --cflags fgsl`
endif

# 'make PROF=1' para compilar con profiling
ifeq ($(PROF), 1)
	FFLAGS += $(PROFFLAGS)
	LDFLAGS += $(PROFFLAGS)
endif
#Reglas de compilación

TARGET = programa_mc.exe
OBJ = m_constants.o m_init_conf.o m_rot_dihedral.o m_energy.o \
      m_write.o m_ran_gen.o m_MC_step.o m_tower.o main.o

all: $(TARGET)

$(TARGET): $(OBJ)
	$(FC) $(FFLAGS) -o $(TARGET) $(OBJ) $(LDFLAGS)

%.o: %.f90
	$(FC) $(FFLAGS) -c $<

m_init_conf.o: m_init_conf.f90 m_constants.o
m_rot_dihedral.o: m_rot_dihedral.f90 m_constants.o
m_energy.o: m_energy.f90 m_constants.o m_rot_dihedral.o
m_write.o: m_write.f90 m_constants.o
m_tower.o: m_tower.f90 m_constants.o m_ran_gen.o
m_ran_gen.o: m_ran_gen.f90
m_MC_step.o: m_MC_step.f90 m_constants.o m_energy.o m_rot_dihedral.o m_ran_gen.o m_tower.o
main.o: main.f90 m_MC_step.o m_write.o m_constants.o m_init_conf.o

clean:
	rm -f $(OBJ) *.mod $(TARGET)

.PHONY: all clean