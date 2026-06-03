# Paralelización de Simulaciones Monte Carlo con Temperatura Variable

## Resumen de Modificaciones Realizadas

### 1. **Eliminación de Ejecución Secuencial por Temperatura**
- **Archivo modificado**: `Makefile`
- **Cambio**: Removido bucle secuencial en `run_all` y reemplazado por ejecución paralela con OpenMP
- **Razón**: La ejecución secuencial no aprovecha los múltiples núcleos disponibles

### 2. **Implementación de Paralelización a Nivel de Temperatura con Annealing**
- **Archivo modificado**: `main.f90`
- **Cambio**: Implementado bucle paralelo sobre 6 temperaturas usando OpenMP
- **Características**:
  - Schedule estocástico (`schedule(runtime)`)
  - Cada thread maneja una temperatura independiente con annealing
  - Seeds diferentes para cada thread para reproducibilidad
  - Directorios separados para cada temperatura
  - Mantenimiento del esquema de temperatura variable (annealing)

### 3. **Corrección de Thread-Safety en Generador de Números Aleatorios**
- **Archivo modificado**: `m_ran_gen.f90`
- **Problema**: Variable `gen` compartida causaba condiciones de carrera
- **Solución**: Implementado `!$omp threadprivate(gen)` para que cada thread tenga su propio RNG

### 4. **Actualización del Makefile**
- **Añadido**: Soporte para compilación con OpenMP (`PARAL=1`)
- **Modificado**: `run_all` para ejecutar con 6 threads en paralelo
- **Eliminado**: Bucle secuencial de temperaturas

## Características Específicas de temp_var

### **Esquema de Temperatura Variable**
- **Temperatura inicial**: 2500 K para todas las simulaciones
- **Temperaturas objetivo**: 200, 300, 400, 500, 600, 700 K
- **Annealing**: Reducción gradual desde 2500 K hasta temperatura objetivo
- **Control**: Modificación entre 15% y 60% de los pasos totales
- **Factor alpha**: Calculado para cada temperatura objetivo

### **Estructura de Directorios**
```
PARALEL_RESULTS/
├── T_200.0/
├── T_300.0/
├── T_400.0/
├── T_500.0/
├── T_600.0/
└── T_700.0/
```

## Resultados de Rendimiento Esperados

### **Comparación con temp_cte**
- **Ventaja**: Mantiene el esquema de annealing para mejor exploración del espacio configuracional
- **Desventaja potencial**: Mayor tiempo de cómputo por simulación debido al annealing

### **Speedup Esperado**
- **Secuencial (1 temperatura)**: ~600-800 segundos (estimado)
- **Paralelo (6 temperaturas)**: ~1200-1600 segundos
- **Speedup**: 2.0-2.5x
- **Eficiencia**: 33-42% (2.0-2.5/6)

## Diferencias Clave con temp_cte

### **1. Esquema de Temperatura**
- **temp_cte**: Temperatura constante durante toda la simulación
- **temp_var**: Annealing desde 2500 K hasta temperatura objetivo

### **2. Tiempo de Ejecución**
- **temp_var**: Mayor tiempo por simulación debido al annealing
- **temp_cte**: Tiempo más constante y predecible

### **3. Exploración Configuracional**
- **temp_var**: Mejor exploración gracias al annealing
- **temp_cte**: Exploración limitada a temperatura fija

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

## Optimización Adicional: Nested Parallelism

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
    !$omp dir_name, filename, alpha, step_ini, step_end, step_size)
    do i = 1, 6
        tid = omp_get_thread_num()
        temp = temps(i)
        
        ! Configurar threads para nivel anidado
        call omp_set_num_threads(2)  ! Nivel 2: cálculo de ángulos
        
        ! ... resto del código existente ...
        
    end do
    !$omp end parallel do
```

### **Speedup Esperado con Nested Parallelism**
- **Speedup estimado**: 1.5-2.0x adicional sobre el rendimiento actual
- **Eficiencia total**: 50-66% (vs 33-42% actual)
- **Tiempo total estimado**: 600-800 segundos (vs 1200-1600 actual)

## Consideraciones de Implementación

### **Ventajas del Esquema temp_var Paralelizado**
- Mejor exploración del espacio configuracional
- Aprovechamiento eficiente de múltiples núcleos
- Resultados más robustos gracias al annealing

### **Desventajas**
- Mayor tiempo de ejecución total
- Mayor complejidad en el análisis de resultados
- Posible mayor consumo de memoria

### **Recomendaciones**
1. **Monitorear uso de CPU** para evitar sobre-subscription
2. **Probar diferentes schedules** (static vs dynamic)
3. **Considerar affinity** para asignar threads a núcleos específicos
4. **Analizar resultados** comparando con temp_cte para evaluar beneficios del annealing

Esta implementación paralelizada de temp_var combina los beneficios del annealing térmico con la eficiencia de la computación paralela.
