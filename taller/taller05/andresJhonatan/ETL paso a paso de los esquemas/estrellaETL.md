# Documento: Explicación del ETL Paso a Paso para el Data Warehouse de Análisis de Ventas

## 1. **Extracción (Extract)**  
- **Objetivo:** Obtener los datos relevantes de la base de datos transaccional `dvdRental` para alimentar el Data Warehouse.  
- **Pasos:**  
  1. **Identificación de Datos Relevantes:**  
     - **Dimensiones:**  
       - `dim_customer`: Información de clientes (customer_key, first_name, last_name, email, registration_date, status).  
       - `dim_film`: Detalles de películas (film_key, film_id, title, description, release_year, rating, length, rental_duration, rental_rate).  
       - `dim_store`: Datos de tiendas (store_key, store_id, manager_first_name, manager_last_name, store_city, store_country, store_postal_code).  
       - `dim_staff`: Información de empleados (staff_key, staff_id, first_name, last_name, email, store_id, active).  
       - `dim_category`: Categorías de películas (category_key, category_id, category_name).  
       - `dim_location`: Ubicación (location_key, address_id, address, district, city, country, postal_code).  
       - `dim_time`: Dimension temporal (time_key, full_date, year, quarter, month_name, day).  
     - **Hechos:**  
       - `fact_sales`: Datos de transacciones (sales_key, customer_key, store_key, time_key, location_key, category_key, staff_key, rental_id, payment_id, payment_amount, rental_days, rental_rate, return_date, payment_date).  
  2. **Consultas SQL de Extracción:**  
     - Ejemplo para `dim_customer`: `SELECT customer_id AS customer_key, first_name, last_name, email, registration_date, active AS status FROM customer;`  
     - Ejemplo para `fact_sales`: `SELECT payment_id AS payment_id, customer_id AS customer_key, staff_id AS staff_key, rental_id AS rental_id, amount AS payment_amount, payment_date, rental.return_date, DATEDIF(day, rental.rental_date, rental.return_date) AS rental_days FROM payment JOIN rental ON payment.rental_id = rental.rental_id;`  
     - Similarmente, se extraen datos de las demás tablas ajustando claves y campos relevantes.  
  3. **Almacenamiento Temporal:** Los datos extraídos se guardan en archivos temporales (CSV o tablas staging) para su posterior transformación.

## 2. **Transformación (Transform)**  
- **Objetivo:** Limpiar, enriquecer y estructurar los datos para el modelo estrella.  
- **Pasos:**  
  1. **Limpieza de Datos:**  
     - Eliminar duplicados y manejar valores nulos (e.g., rellenar `NULL` en `rental_rate` con un valor promedio).  
     - Normalizar texto (e.g., estandarizar nombres de ciudades y países en `dim_location`).  
  2. **Enriquecimiento:**  
     - Crear claves surrogate (e.g., `customer_key`, `time_key`) si no existen, asegurando unicidad.  
     - Calcular campos derivados como `rental_days` (diferencia entre `rental_date` y `return_date`) en `fact_sales`.  
  3. **Agregación y Filtrado:**  
     - Filtrar datos históricos relevantes (e.g., solo transacciones de los últimos 5 años).  
     - Agregar datos para dimensiones temporales (e.g., extraer `year`, `month_name` de `payment_date`).  
  4. **Script de Transformación (Ejemplo en SQL):**  
     ```sql
     UPDATE fact_sales
     SET rental_days = DATEDIF(day, rental_date, return_date)
     WHERE rental_date IS NOT NULL AND return_date IS NOT NULL;

     INSERT INTO dim_time (time_key, full_date, year, month_name)
     SELECT DISTINCT payment_date, EXTRACT(YEAR FROM payment_date), EXTRACT(MONTH FROM payment_date), TO_CHAR(payment_date, 'Month')
     FROM fact_sales
     ON CONFLICT DO NOTHING;
     ```  
  5. **Validación:** Verificar que las claves foráneas coincidan con las dimensiones correspondientes.

## 3. **Carga (Load)**  
- **Objetivo:** Cargar los datos transformados en el esquema estrella del Data Warehouse.  
- **Pasos:**  
  1. **Creación de Tablas en PostgreSQL:**  
     - Ejemplo para `dim_customer`:  
       ```sql
       CREATE TABLE dim_customer (
           customer_key SERIAL PRIMARY KEY,
           first_name VARCHAR(50),
           last_name VARCHAR(50),
           email VARCHAR(100),
           registration_date DATE,
           status BOOLEAN
       );
       ```  
     - Similarmente, crear tablas para `dim_film`, `dim_store`, `dim_staff`, `dim_category`, `dim_location`, `dim_time`, y `fact_sales` con claves primarias y foráneas.  
  2. **Carga de Datos:**  
     - Usar comandos `COPY` o `INSERT INTO` para cargar datos desde archivos temporales o tablas staging.  
     - Ejemplo:  
       ```sql
       INSERT INTO dim_customer (first_name, last_name, email, registration_date, status)
       SELECT first_name, last_name, email, registration_date, status
       FROM staging_customer;
       ```  
  3. **Índices:** Crear índices en claves foráneas y campos frecuentemente consultados (e.g., `customer_key`, `time_key`) para mejorar rendimiento.  
  4. **Validación Post-Carga:** Confirmar que las relaciones entre tablas sean consistentes y que no haya datos faltantes.

## 4. **Transformación a Esquema Copo de Nieve**  
- **Objetivo:** Convertir el esquema estrella en un esquema copo de nieve para mayor normalización.  
- **Pasos:**  
  1. **Descomposición de Dimensiones:**  
     - Dividir `dim_location` en `dim_city` (city, district) y `dim_country` (country, postal_code).  
     - Ajustar relaciones para que `dim_store` se conecte a `dim_city` y `dim_city` a `dim_country`.  
  2. **Actualización de Tablas:**  
     - Ejemplo para `dim_city`:  
       ```sql
       CREATE TABLE dim_city (
           city_key SERIAL PRIMARY KEY,
           city VARCHAR(50),
           district VARCHAR(50),
           country_key INT REFERENCES dim_country(country_key)
       );
       ```  
     - Actualizar `dim_store` para usar `city_key` en lugar de campos anidados.  
  3. **Carga de Datos en el Esquema Copo de Nieve:**  
     - Reprocesar datos de `dim_location` y redistribuirlos en las nuevas tablas usando `INSERT INTO`.  
  4. **Validación:** Asegurarse de que las relaciones jerárquicas entre `dim_country`, `dim_city`, y `dim_store` sean correctas.

## 5. **Resultados Esperados**  
- **Scripts SQL:** Archivos con las sentencias de creación (`CREATE TABLE`) y carga (`INSERT INTO`) para ambos esquemas.  
- **Diseño de Esquemas:** Diagramas (como el proporcionado) con tablas y relaciones para estrella y copo de nieve.  
- **Documentación ETL:** Este documento detalla cada fase.  
- **Capturas:** Imágenes de las tablas cargadas en PostgreSQL (e.g., usando `\dt` y `SELECT * LIMIT 10`).

Este proceso asegura un Data Warehouse funcional para analizar las consultas solicitadas (ventas por país/mes, películas rentables, etc.) con datos organizados y optimizados.