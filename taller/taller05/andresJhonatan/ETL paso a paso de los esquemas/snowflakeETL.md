# Documento: Explicación del ETL Paso a Paso para el Data Warehouse de Análisis de Ventas (Esquema Copo de Nieve)

## 1. **Extracción (Extract)**  
- **Objetivo:** Obtener los datos relevantes de la base de datos transaccional `dvdRental` para alimentar el Data Warehouse con el esquema copo de nieve.  
- **Pasos:**  
  1. **Identificación de Datos Relevantes:**  
     - **Dimensiones:**  
       - `dim_customer`: Información de clientes (customer_key, customer_id, first_name, last_name, email, customer_status, registration_date, location_key).  
       - `dim_film`: Detalles de películas (film_key, film_id, title, description, release_year, rating, length, rental_duration, rental_rate, language_key, category_key).  
       - `dim_store`: Datos de tiendas (store_key, store_id, manager_first_name, manager_last_name, location_key).  
       - `dim_staff`: Información de empleados (staff_key, staff_id, first_name, last_name, email, active, store_key).  
       - `dim_category`: Categorías de películas (category_key, category_id, category_name).  
       - `dim_language`: Idiomas (language_key, language_id, language_name).  
       - `dim_location`: Ubicación (location_key, address_id, address, postal_code, city_key).  
       - `dim_city`: Ciudades (city_key, city_id, city_name, district, country_key).  
       - `dim_country`: Países (country_key, country_id, country_name).  
       - `dim_time`: Dimension temporal (time_key, full_date, year, quarter, month_name, day).  
     - **Hechos:**  
       - `fact_sales`: Datos de transacciones (sales_key, customer_key, store_key, time_key, film_key, staff_key, payment_id, payment_amount, rental_days, rental_count, return_date, payment_date).  
  2. **Consultas SQL de Extracción:**  
     - Ejemplo para `dim_customer`: `SELECT customer_id AS customer_key, first_name, last_name, email, active AS customer_status, registration_date FROM customer;`  
     - Ejemplo para `fact_sales`: `SELECT payment_id AS payment_id, customer_id AS customer_key, staff_id AS staff_key, rental_id AS rental_id, amount AS payment_amount, payment_date, rental.return_date, DATEDIF(day, rental.rental_date, rental.return_date) AS rental_days FROM payment JOIN rental ON payment.rental_id = rental.rental_id;`  
     - Extraer datos de `dim_location`, `dim_city`, y `dim_country` descomponiendo `address`, `district`, `city`, `country`, y `postal_code`.  
  3. **Almacenamiento Temporal:** Guardar datos extraídos en archivos temporales (CSV o tablas staging) para transformación.

## 2. **Transformación (Transform)**  
- **Objetivo:** Limpiar, enriquecer y estructurar los datos para el esquema copo de nieve.  
- **Pasos:**  
  1. **Limpieza de Datos:**  
     - Eliminar duplicados y manejar valores nulos (e.g., rellenar `rental_rate` con promedio).  
     - Normalizar texto (e.g., estandarizar `city_name`, `country_name`).  
  2. **Enriquecimiento:**  
     - Generar claves surrogate (e.g., `city_key`, `country_key`) para normalización.  
     - Calcular `rental_days` en `fact_sales`.  
  3. **Desnormalización y Filtrado:**  
     - Descomponer `dim_location` en `dim_city` y `dim_country`.  
     - Filtrar datos históricos (e.g., últimos 5 años).  
  4. **Script de Transformación (Ejemplo en SQL):**  
     ```sql
     INSERT INTO dim_city (city_key, city_name, district, country_key)
     SELECT ROW_NUMBER() OVER (ORDER BY city) AS city_key, city, district, 
            (SELECT country_key FROM dim_country WHERE country_name = c.country) AS country_key
     FROM (SELECT DISTINCT city, district, country FROM dim_location) c
     ON CONFLICT DO NOTHING;

     UPDATE dim_location
     SET city_key = (SELECT city_key FROM dim_city WHERE dim_city.city_name = dim_location.city)
     WHERE city_key IS NULL;
     ```  
  5. **Validación:** Asegurar coherencia de claves foráneas entre tablas normalizadas.

## 3. **Carga (Load)**  
- **Objetivo:** Cargar los datos transformados en el esquema copo de nieve del Data Warehouse.  
- **Pasos:**  
  1. **Creación de Tablas en PostgreSQL:**  
     - Ejemplo para `dim_city`:  
       ```sql
       CREATE TABLE dim_city (
           city_key SERIAL PRIMARY KEY,
           city_name VARCHAR(50),
           district VARCHAR(50),
           country_key INT REFERENCES dim_country(country_key)
       );
       ```  
     - Crear tablas para `dim_country`, `dim_location`, y actualizar `dim_store`, `dim_customer` con `city_key`.  
  2. **Carga de Datos:**  
     - Usar `COPY` o `INSERT INTO` desde staging.  
     - Ejemplo:  
       ```sql
       INSERT INTO dim_city (city_name, district, country_key)
       SELECT city, district, (SELECT country_key FROM dim_country WHERE country_name = c.country)
       FROM staging_location c;
       ```  
  3. **Índices:** Añadir índices en claves foráneas (e.g., `country_key`, `city_key`).  
  4. **Validación Post-Carga:** Verificar relaciones jerárquicas (e.g., `dim_country` → `dim_city` → `dim_location`).

## 4. **Validación del Esquema Copo de Nieve**  
- **Objetivo:** Asegurar la integridad del esquema normalizado.  
- **Pasos:**  
  1. **Revisión de Relaciones:** Confirmar que `dim_store` y `dim_customer` usen `city_key` correctamente.  
  2. **Pruebas de Consultas:** Validar consultas como ventas por país/mes usando uniones entre `dim_country`, `dim_city`, y `fact_sales`.  
  3. **Ajustes:** Corregir cualquier inconsistencia en datos o relaciones.

## 5. **Resultados Esperados**  
- **Scripts SQL:** Sentencias de creación y carga para el esquema copo de nieve.  
- **Diseño de Esquemas:** Diagrama proporcionado con tablas y relaciones normalizadas.  
- **Documentación ETL:** Este documento detalla cada fase.  
- **Capturas:** Imágenes de tablas cargadas en PostgreSQL (e.g., `\dt`, `SELECT * LIMIT 10`).

Este proceso asegura un Data Warehouse con esquema copo de nieve optimizado para análisis detallados.