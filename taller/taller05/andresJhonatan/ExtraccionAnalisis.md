# 📊 DataMart de Análisis de Ventas - DVDRental
## Identificación de Dimensiones y Hechos

---

## 🎯 **TABLA DE HECHOS PRINCIPAL: FACT_SALES**

La tabla de hechos es el corazón del DataMart y contiene las **métricas cuantificables** del negocio:

### 📈 **Métricas Principales (Measures)**
| Métrica | Descripción | Tipo | Uso en Análisis |
|---------|-------------|------|-----------------|
| `payment_amount` | Monto pagado por el alquiler | Numérico (DECIMAL) | Ingresos totales, promedios |
| `rental_rate` | Tarifa base del alquiler | Numérico (DECIMAL) | Análisis de precios |
| `rental_days` | Días reales de alquiler | Entero | Análisis de uso |
| `late_fee` | Recargo por retraso | Numérico (DECIMAL) | Ingresos adicionales |
| `profit_margin` | Margen de ganancia | Calculado | Rentabilidad |

### 🔑 **Claves Foráneas (Foreign Keys)**
- `time_key` → DIM_TIME
- `customer_key` → DIM_CUSTOMER  
- `film_key` → DIM_FILM
- `store_key` → DIM_STORE
- `location_key` → DIM_LOCATION
- `category_key` → DIM_CATEGORY

---

## 🏗️ **DIMENSIONES IDENTIFICADAS**

### 1. **📅 DIM_TIME (Dimensión Tiempo)**
**Propósito**: Análisis temporal de ventas por diferentes períodos

| Atributo | Descripción | Ejemplo |
|----------|-------------|---------|
| `time_key` | Clave primaria | 20240625 |
| `full_date` | Fecha completa | 2024-06-25 |
| `year` | Año | 2024 |
| `month` | Mes | 6 |
| `month_name` | Nombre del mes | Junio |
| `quarter` | Trimestre | Q2 |
| `day_of_week` | Día de la semana | Martes |
| `is_weekend` | Fin de semana | No |

**🎯 Relevancia**: Esencial para la consulta "Total de ventas por país y mes"

---

### 2. **👤 DIM_CUSTOMER (Dimensión Cliente)**
**Propósito**: Análisis del comportamiento y segmentación de clientes

| Atributo | Descripción | Uso Analítico |
|----------|-------------|---------------|
| `customer_key` | Clave primaria | Identificación única |
| `first_name`, `last_name` | Nombre completo | Personalización |
| `email` | Correo electrónico | Marketing directo |
| `customer_status` | Activo/Inactivo | Segmentación |
| `registration_date` | Fecha de registro | Análisis de retención |
| `customer_segment` | Segmento de cliente | VIP, Regular, Nuevo |
| `total_rentals` | Total de alquileres | Clasificación de fidelidad |

**🎯 Relevancia**: Fundamental para "Promedio de gasto por cliente según tienda y ciudad"

---

### 3. **🎬 DIM_FILM (Dimensión Película)**
**Propósito**: Análisis de popularidad y rentabilidad del catálogo

| Atributo | Descripción | Uso Analítico |
|----------|-------------|---------------|
| `film_key` | Clave primaria | Identificación única |
| `title` | Título de la película | Análisis de popularidad |
| `rating` | Clasificación (G, PG, R, etc.) | Segmentación por audiencia |
| `release_year` | Año de lanzamiento | Análisis temporal del catálogo |
| `rental_duration` | Duración estándar del alquiler | Análisis de políticas |
| `rental_rate` | Tarifa de alquiler | Análisis de precios |
| `length` | Duración en minutos | Preferencias de duración |
| `language` | Idioma | Análisis por idioma |
| `special_features` | Características especiales | Análisis de valor agregado |

**🎯 Relevancia**: Clave para "Películas más rentables por rating"

---

### 4. **🎭 DIM_CATEGORY (Dimensión Categoría/Género)**
**Propósito**: Análisis por tipo de contenido

| Atributo | Descripción | Uso Analítico |
|----------|-------------|---------------|
| `category_key` | Clave primaria | Identificación única |
| `category_name` | Nombre del género | Drama, Acción, Comedia |
| `category_group` | Agrupación de géneros | Familiar, Adulto, Acción |
| `target_audience` | Audiencia objetivo | Niños, Adolescentes, Adultos |

**🎯 Relevancia**: Esencial para "Ventas totales por género"

---

### 5. **🏪 DIM_STORE (Dimensión Tienda)**
**Propósito**: Análisis de performance por punto de venta

| Atributo | Descripción | Uso Analítico |
|----------|-------------|---------------|
| `store_key` | Clave primaria | Identificación única |
| `store_id` | ID original de la tienda | 1, 2 |
| `manager_name` | Nombre del gerente | Análisis de gestión |
| `store_address` | Dirección completa | Ubicación física |
| `store_city` | Ciudad de la tienda | Análisis geográfico |
| `store_country` | País de la tienda | Análisis internacional |
| `opening_date` | Fecha de apertura | Análisis temporal |
| `store_size` | Tamaño de la tienda | Pequeña, Mediana, Grande |

**🎯 Relevancia**: Fundamental para "Ventas promedio por tienda"

---

### 6. **📍 DIM_LOCATION (Dimensión Ubicación)**
**Propósito**: Análisis geográfico detallado

| Atributo | Descripción | Uso Analítico |
|----------|-------------|---------------|
| `location_key` | Clave primaria | Identificación única |
| `address` | Dirección específica | Análisis de área |
| `district` | Distrito/Zona | Segmentación geográfica |
| `city` | Ciudad | Análisis urbano |
| `country` | País | Análisis internacional |
| `postal_code` | Código postal | Micro-segmentación |
| `region` | Región/Estado | Análisis regional |
| `timezone` | Zona horaria | Análisis temporal |

**🎯 Relevancia**: Esencial para "Total de ventas por país y mes" y análisis por ciudad

---

### 7. **🎪 DIM_ACTOR (Dimensión Actor)**
**Propósito**: Análisis de popularidad de actores

| Atributo | Descripción | Uso Analítico |
|----------|-------------|---------------|
| `actor_key` | Clave primaria | Identificación única |
| `actor_name` | Nombre completo | Análisis de popularidad |
| `film_count` | Número de películas | Productividad |
| `avg_rating` | Rating promedio | Calidad percibida |
| `total_revenue` | Ingresos generados | Valor comercial |

---

## 🔍 **ANÁLISIS DE RELEVANCIA POR CONSULTA DE NEGOCIO**

### 📊 **1. Total de ventas por país y mes**
**Dimensiones necesarias:**
- ✅ DIM_TIME (mes, año)
- ✅ DIM_LOCATION (país)
- ✅ FACT_SALES (payment_amount)

**Granularidad**: País-Mes

---

### 🏆 **2. Películas más rentables por rating**
**Dimensiones necesarias:**
- ✅ DIM_FILM (title, rating)
- ✅ FACT_SALES (payment_amount)

**Granularidad**: Rating-Película

---

### 🏪 **3. Ventas promedio por tienda**
**Dimensiones necesarias:**
- ✅ DIM_STORE (store_id, manager_name)
- ✅ FACT_SALES (payment_amount)

**Granularidad**: Tienda

---

### 🎭 **4. Ventas totales por género**
**Dimensiones necesarias:**
- ✅ DIM_CATEGORY (category_name)
- ✅ FACT_SALES (payment_amount)

**Granularidad**: Categoría/Género

---

### 👥 **5. Promedio de gasto por cliente según tienda y ciudad**
**Dimensiones necesarias:**
- ✅ DIM_CUSTOMER (customer_id)
- ✅ DIM_STORE (store_id, store_city)
- ✅ DIM_LOCATION (city)
- ✅ FACT_SALES (payment_amount)

**Granularidad**: Cliente-Tienda-Ciudad

---

## 💡 **JUSTIFICACIÓN DE DISEÑO**

### ⭐ **Ventajas del Esquema Estrella Propuesto:**

1. **📈 Performance Optimizada**
   - Consultas rápidas con menos JOINs
   - Índices optimizados en claves foráneas

2. **🔍 Análisis Flexible**
   - Drill-down y roll-up por cualquier dimensión
   - Agregaciones eficientes

3. **📊 Business Intelligence**
   - Compatible con herramientas de BI
   - Fácil creación de cubos OLAP

4. **🔧 Mantenimiento Simplificado**
   - Estructura clara y comprensible
   - Actualizaciones incrementales

---

## 📋 **MÉTRICAS CLAVE DEL DATAMART**

| KPI | Fórmula | Dimensiones Involucradas |
|-----|---------|-------------------------|
| **Ingresos Totales** | SUM(payment_amount) | Todas |
| **Ingresos Promedio** | AVG(payment_amount) | Cliente, Tienda |
| **Películas Top** | COUNT(rental_id) por film | Film, Category |
| **Crecimiento Mensual** | SUM(payment_amount) MoM | Time |
| **Performance por Tienda** | SUM(payment_amount) por store | Store, Location |
| **Preferencias por Género** | COUNT(*) por category | Category, Time |

---

## 🎯 **CONCLUSIÓN**

Este DataMart de análisis de ventas está diseñado específicamente para responder a las 5 consultas de negocio requeridas, proporcionando:

- ✅ **Flexibilidad analítica** para múltiples perspectivas
- ✅ **Performance optimizada** para consultas frecuentes  
- ✅ **Escalabilidad** para crecimiento futuro
- ✅ **Facilidad de uso** para usuarios de negocio
- ✅ **Integridad de datos** con claves bien definidas

La estructura propuesta permite análisis desde múltiples ángulos: temporal, geográfico, por producto, por cliente y por canal de venta, cumpliendo con todos los requerimientos del negocio de alquiler de películas.