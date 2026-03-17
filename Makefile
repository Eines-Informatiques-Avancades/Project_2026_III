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

# Por defecto usamos producción, a menos que se diga lo contrario
FFLAGS = $(PRODFLAGS) -Wall -I/usr/local/include/fgsl
LDFLAGS = `pkg-config --libs fgsl`

# --- Si escribes 'make DEBUG=1', se usarán los flags de depuración ---
ifeq ($(DEBUG), 1)
    FFLAGS = $(DBFLAGS) -Wall -I/usr/local/include/fgsl
endif

# ... (resto del Makefile igual: TARGET, OBJ, reglas de dependencia) ...

TARGET = programa_mc.exe
OBJ = m_constants.o m_init_conf.o m_rot_dihedral.o m_energy.o \
      m_write.o m_ran_gen.o m_MC_step.o main.o

all: $(TARGET)

$(TARGET): $(OBJ)
	$(FC) $(FFLAGS) -o $(TARGET) $(OBJ) $(LDFLAGS)

%.o: %.f90
	$(FC) $(FFLAGS) -c $<

m_init_conf.o: m_init_conf.f90 m_constants.o
m_rot_dihedral.o: m_rot_dihedral.f90 m_constants.o
m_energy.o: m_energy.f90 m_constants.o
m_write.o: m_write.f90 m_constants.o
m_ran_gen.o: m_ran_gen.f90
	$(FC) $(FFLAGS) `pkg-config --cflags fgsl` -c m_ran_gen.f90
m_MC_step.o: m_MC_step.f90 m_constants.o m_energy.o m_rot_dihedral.o m_ran_gen.o
main.o: main.f90 m_MC_step.o m_write.o m_constants.o m_init_conf.o

clean:
	rm -f $(OBJ) *.mod $(TARGET)

.PHONY: all clean