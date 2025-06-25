# Análisis de Extracción - Data Warehouse DVDRental

## Identificación de Dimensiones y Hechos

### Tabla de Hechos Principal: VENTAS (SALES)
La tabla de hechos contendrá las métricas de negocio principales:
- **payment_amount**: Monto del pago (métrica principal)
- **rental_duration**: Duración del alquiler
- **rental_date**: Fecha del alquiler
- **return_date**: fecha de devolución

### Dimensiones Identificadas:

#### 1. **Dimensión Tiempo (DIM_TIME)**
- Fecha del alquiler
- Año, mes, día, trimestre
- Día de la semana

#### 2. **Dimensión Cliente (DIM_CUSTOMER)**
- ID del cliente
- Nombre y apellido
- Email
- Estado activo

#### 3. **Dimensión Película (DIM_FILM)**
- ID de la película
- Título
- Descripción
- Año de lanzamiento
- Duración del alquiler
- Tarifa de alquiler
- Costo de reemplazo
- Rating (clasificación)

#### 4. **Dimensión Categoría (DIM_CATEGORY)**
- ID de categoría
- Nombre de la categoría

#### 5. **Dimensión Actor (DIM_ACTOR)**
- ID del actor
- Nombre y apellido del actor

#### 6. **Dimensión Tienda (DIM_STORE)**
- ID de la tienda
- ID del gerente

#### 7. **Dimensión Ubicación (DIM_LOCATION)**
- ID de la dirección
- Dirección completa
- Distrito
- Ciudad
- País
- Código postal

#### 8. **Dimensión Idioma (DIM_LANGUAGE)**
- ID del idioma
- Nombre del idioma

## Datos Relevantes para el DataMart de Análisis de Ventas

Para responder a las consultas de negocio requeridas, necesitamos extraer:

1. **Para "Total de ventas por país y mes":**
   - Fechas de los pagos/alquileres
   - Montos de los pagos
   - Información geográfica (país)

2. **Para "Películas más rentables por rating":**
   - Información de películas (título, rating)
   - Montos totales generados por película

3. **Para "Ventas promedio por tienda":**
   - Información de tiendas
   - Montos de ventas por tienda

4. **Para "Ventas totales por género":**
   - Categorías de películas
   - Montos de ventas por categoría

5. **Para "Promedio de gasto por cliente según tienda y ciudad":**
   - Información de clientes
   - Información de tiendas
   - Información geográfica
   - Montos de gastos por cliente

## Justificación de las Dimensiones

- **Tiempo**: Esencial para análisis temporal y tendencias
- **Cliente**: Permite análisis de comportamiento del cliente
- **Película**: Core del negocio, permite análisis de popularidad y rentabilidad
- **Categoría**: Permite análisis por género/tipo de película
- **Ubicación**: Permite análisis geográfico de ventas
- **Tienda**: Permite comparación de performance entre tiendas
- **Actor**: Permite análisis de popularidad de actores
- **Idioma**: Permite análisis por preferencias de idioma
