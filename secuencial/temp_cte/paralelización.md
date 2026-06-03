# Paralelización de Simulaciones Monte Carlo

## Resumen de Modificaciones Realizadas

### 1. **Eliminación de Paralelización Fina en `LJ_energy`**
- **Archivo modificado**: `m_energy.f90`
- **Cambio**: Removidos directivas OpenMP del bucle anidado en la función `LJ_energy`
- **Razón**: La paralelización a nivel de pares de átomos no proporcionaba mejora de rendimiento debido al overhead de sincronización

### 2. **Implementación de Paralelización a Nivel de Temperatura**
- **Archivo modificado**: `main.f90`
- **Cambio**: Implementado bucle paralelo sobre 6 temperaturas usando OpenMP
- **Características**:
  - Schedule estocástico (`schedule(runtime)`)
  - Cada thread maneja una temperatura independiente
  - Seeds diferentes para cada thread para reproducibilidad
  - Directorios separados para cada temperatura

### 3. **Corrección de Thread-Safety en Generador de Números Aleatorios**
- **Archivo modificado**: `m_ran_gen.f90`
- **Problema**: Variable `gen` compartida causaba condiciones de carrera
- **Solución**: Implementado `!$omp threadprivate(gen)` para que cada thread tenga su propio RNG

### 4. **Actualización del Makefile**
- **Eliminado**: `.PHONY: all` (ya no se puede ejecutar una sola temperatura)
- **Modificado**: `run_all` para compilar con OpenMP y ejecutar con 6 threads

## Resultados de Rendimiento

### **Mediciones Obtenidas**
- **Secuencial (1 temperatura)**: ~499 segundos
- **Paralelo (6 temperaturas)**: ~997 segundos
- **Speedup**: 2.0x
- **Eficiencia**: 33% (2.0/6)

### **Análisis de Rendimiento**

#### **Speedup Esperado vs Real**
- **Esperado teórico**: 6x (perfecto paralelismo)
- **Obtenido**: 2.0x
- **Eficiencia**: 33%

## Problemas que Reducen el Rendimiento Esperado

### 1. **Overhead de OpenMP**
- Creación y gestión de hilos
- Sincronización al inicio/final de regiones paralelas
- Barreras implícitas en `!$omp end parallel do`

### 2. **Contención de Recursos del Sistema**
- **Memoria Compartida**: Múltiples hilos accediendo a memoria cache
- **Ancho de Banda de Memoria**: Limitado por el hardware
- **Contención en el Bus del Sistema**

### 3. **Distribución de Carga Desigual**
- Las diferentes temperaturas pueden tener diferentes cargas computacionales
- Algunas temperaturas pueden requerir más iteraciones de convergencia

### 4. **Falsos Compartimientos (False Sharing)**
- Variables en las mismas líneas de cache modificadas por diferentes hilos
- Particularmente problemático en arrays compartidos

### 5. **Limitaciones del Hardware**
- **Núcleos Físicos**: Posiblemente menos de 6 núcleos físicos
- **Hyper-Threading**: Si se usa HT, el rendimiento es menor que con núcleos reales
- **Arquitectura de Cache**: Tamaño y asociatividad limitada

### 6. **Características del Algoritmo**
- **Dependencias de Datos**: Aunque las temperaturas son independientes, hay operaciones secuenciales dentro de cada simulación
- **Tamaño de Problema**: 500 átomos × 1,000,000 steps = carga computacional significativa por thread

## Propuesta de Optimización: Nested Parallelism

### **Concepto**
Activar paralelización anidada para aprovechar el código ya existente en `phi_lst` que calcula ángulos dihedrales en paralelo.

### **Implementación Propuesta**

#### 1. **Activar Nested Parallelism en main.f90**
```fortran
program main
    ! ... declaraciones existentes ...
    
    ! Activar paralelismo anidado
    call omp_set_nested(.true.)
    call omp_set_max_active_levels(2)
    
    ! Configurar número de threads para cada nivel
    call omp_set_num_threads(6)  ! Nivel 1: temperaturas
    
    start_time = omp_get_wtime()
    
    !$omp parallel do schedule(runtime) private(tid, temp, coord, phi_rot, E_LJ, E_dih, energy, &
    !$omp dihedral_lst, tower, seed, accepted_moves, accepted_moves_b, rejected_moves, j, step, &
    !$omp dir_name, filename)
    do i = 1, 6
        tid = omp_get_thread_num()
        temp = temps(i)
        
        ! Configurar threads para nivel anidado
        call omp_set_num_threads(2)  ! Nivel 2: cálculo de ángulos
        
        ! ... resto del código existente ...
        
    end do
    !$omp end parallel do
```

#### 2. **Modificar phi_lst para usar Nested Parallelism**
```fortran
function phi_lst(coord) result(lst)
    real(8), intent(in) :: coord(3, n_atoms)
    real(8) :: lst(n_atoms-3)
    integer :: i
    
    ! Solo usar paralelismo si estamos en una región anidada
    if (omp_get_level() > 0) then
        !$omp parallel do schedule(static)
        do i = 3, n_atoms-1
            lst(i-2) = calc_dihedral(coord, i)
        end do
        !$omp end parallel do
    else
        ! Versión secuencial para compatibilidad
        do i = 3, n_atoms-1
            lst(i-2) = calc_dihedral(coord, i)
        end do
    end if
    
end function phi_lst
```

#### 3. **Optimización Adicional en m_rot_dihedral.f90**
```fortran
! Añadir al principio del módulo
function phi_lst(coord) result(lst)
    real(8), intent(in) :: coord(3, n_atoms)
    real(8) :: lst(n_atoms-3)
    integer :: i
    
    ! Usar schedule dinámico para mejor balance de carga
    !$omp parallel do schedule(dynamic, 16) if(omp_get_level() > 0)
    do i = 3, n_atoms-1
        lst(i-2) = calc_dihedral(coord, i)
    end do
    !$omp end parallel do
    
end function phi_lst
```

### **Configuración del Makefile**
```makefile
# Añadir flags para nested parallelism
ifeq ($(PARAL), 1)
	FFLAGS += -fopenmp
	FFLAGS += -fopenmp-simd  # Para vectorización SIMD
endif

# Configuración de threads
THREADS = 6
NESTED_THREADS = 2
```

### **Speedup Esperado con Nested Parallelism**
- **Speedup estimado**: 1.5-2.0x adicional sobre el rendimiento actual
- **Eficiencia total**: 50-66% (vs 33% actual)
- **Tiempo total estimado**: 500-665 segundos (vs 997 actual)

### **Consideraciones de Implementación**

#### **Ventajas**
- Aprovecha código paralelo existente
- Mínimos cambios en la estructura
- Compatible con hardware multi-core

#### **Desventajas**
- Mayor complejidad de debugging
- Posible overhead si no hay suficientes núcleos
- Requiere ajuste fino de número de threads

#### **Recomendaciones**
1. **Empezar con 2 threads anidados** por cada thread principal
2. **Monitorizar uso de CPU** para evitar sobre-subscription
3. **Probar diferentes schedules** (static vs dynamic)
4. **Considerar affinity** para asignar threads a núcleos específicos

### **Pasos para Implementación**
1. Modificar `main.f90` para activar nested parallelism
2. Actualizar `phi_lst` con condicional para paralelismo anidado
3. Compilar con flags adicionales
4. Probar rendimiento con diferentes configuraciones de threads
5. Ajustar según resultados obtenidos

Esta optimización debería proporcionar una mejora significativa con cambios relativamente simples en el código existente.
