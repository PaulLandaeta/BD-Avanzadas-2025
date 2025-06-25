Proceso ETL para el Data Warehouse de Análisis de Ventas (Esquema Estrella)

1. Extracción (Extract)

Objetivo: Recolectar datos clave de la base de datos transaccional dvdrental para construir un Data Warehouse optimizado para análisis, utilizando un esquema Estrella.

Pasos:





Identificación de Datos:





Dimensiones:





dim\_customer: Datos de clientes (customer\_key, customer\_id, first\_name, last\_name, email, customer\_status, registration\_date, location\_key).



dim\_film: Información de películas (film\_key, film\_id, title, description, release\_year, rating, length, rental\_duration, rental\_rate, language\_key, category\_key).



dim\_store: Detalles de tiendas (store\_key, store\_id, manager\_first\_name, manager\_last\_name, location\_key).



dim\_staff: Información del personal (staff\_key, staff\_id, first\_name, last\_name, email, active, store\_key).



dim\_category: Categorías de películas (category\_key, category\_id, category\_name).



dim\_language: Idiomas (language\_key, language\_id, language\_name).



dim\_location: Ubicaciones (location\_key, address\_id, address, postal\_code, city\_key).



dim\_city: Ciudades (city\_key, city\_id, city\_name, district, country\_key).



dim\_country: Países (country\_key, country\_id, country\_name).



dim\_time: Dimensión temporal (time\_key, full\_date, year, quarter, month\_name, day).



Hechos:





fact\_sales: Transacciones (sales\_key, customer\_key, store\_key, time\_key, film\_key, staff\_key, payment\_id, payment\_amount, rental\_days, rental\_count, return\_date, payment\_date).



Consultas SQL:





Para dim\_customer:

SELECT customer\_id AS customer\_key, first\_name, last\_name, email, active AS customer\_status, create\_date AS registration\_date, address\_id AS location\_key

FROM customer;



Para fact\_sales:

SELECT p.payment\_id, p.customer\_id AS customer\_key, p.staff\_id AS staff\_key, p.rental\_id, p.amount AS payment\_amount, p.payment\_date,

r.return\_date, EXTRACT(DAY FROM (r.return\_date - r.rental\_date)) AS rental\_days

FROM payment p

JOIN rental r ON p.rental\_id = r.rental\_id;



Similarmente, extraer datos para otras dimensiones desde address, city, country, film, language, category, y store.



Almacenamiento Temporal: Exportar datos a tablas temporales en la base de datos o archivos CSV para su transformación posterior.

1. Transformación (Transform)

Objetivo: Procesar y enriquecer los datos extraídos para cumplir con los requisitos del esquema Estrella.

Pasos:





Limpieza:





Eliminar registros duplicados en dimensiones (e.g., clientes únicos por customer\_id).



Rellenar valores nulos (e.g., asignar Unknown a email vacíos en dim\_customer).



Estandarizar formatos (e.g., convertir nombres a mayúsculas iniciales en dim\_customer.first\_name).



Enriquecimiento:





Crear claves surrogate para cada dimensión (e.g., customer\_key, film\_key) usando secuencias automáticas.



Generar campos derivados, como rental\_days en fact\_sales con EXTRACT(DAY FROM (return\_date - rental\_date)).



Agregar indicadores, como is\_late en fact\_sales (1 si rental\_days > rental\_duration, 0 si no).



Estructuración:





Mantener un esquema Estrella con dimensiones denormalizadas (e.g., dim\_location incluye city, district, country sin dividir en tablas separadas como en Copo de Nieve).



Asegurar que las claves foráneas en fact\_sales (e.g., customer\_key, time\_key) coincidan con las claves primarias de las dimensiones.



Script de Transformación (Ejemplo):

INSERT INTO dim\_time (time\_key, full\_date, year, quarter, month\_name, day)

SELECT DISTINCT ROW\_NUMBER() OVER () AS time\_key, payment\_date::DATE, EXTRACT(YEAR FROM payment\_date),

EXTRACT(QUARTER FROM payment\_date), TO\_CHAR(payment\_date, 'Month'), EXTRACT(DAY FROM payment\_date)

FROM payment

ON CONFLICT (full\_date) DO NOTHING;

UPDATE fact\_sales

SET is\_late = CASE WHEN rental\_days > (SELECT rental\_duration FROM dim\_film WHERE film\_key = fact\_sales.film\_key) THEN 1 ELSE 0 END

WHERE rental\_days IS NOT NULL;



Validación: Comprobar que no haya valores nulos en claves foráneas y que las fechas en dim\_time sean consistentes.

1. Carga (Load)

Objetivo: Poblar las tablas del esquema Estrella en el Data Warehouse (dvdrental\_snowflake).

Pasos:





Creación de Tablas:





Ejemplo para dim\_customer:

CREATE TABLE dim\_customer (

customer\_key SERIAL PRIMARY KEY,

customer\_id INT UNIQUE NOT NULL,

first\_name VARCHAR(45),

last\_name VARCHAR(45),

email VARCHAR(50),

customer\_status BOOLEAN,

registration\_date DATE,

location\_key INT REFERENCES dim\_location(location\_key)

);



Crear tablas similares para dim\_film, dim\_store, dim\_staff, dim\_category, dim\_language, dim\_location, dim\_city, dim\_country, dim\_time, y fact\_sales.



Carga de Datos:





Usar INSERT INTO desde tablas temporales o archivos CSV.



Ejemplo para dim\_customer:

INSERT INTO dim\_customer (customer\_id, first\_name, last\_name, email, customer\_status, registration\_date, location\_key)

SELECT customer\_id, first\_name, last\_name, email, active, create\_date, address\_id

FROM staging\_customer;



Índices:





Crear índices en columnas frecuentemente consultadas (e.g., customer\_key en fact\_sales, full\_date en dim\_time).



Ejemplo:

CREATE INDEX idx\_fact\_sales\_customer ON fact\_sales(customer\_key);



Validación Post-Carga:





Verificar conteos de registros:

SELECT COUNT(\*) FROM fact\_sales;

SELECT COUNT(\*) FROM dim\_customer;



Confirmar integridad de relaciones (e.g., fact\_sales.customer\_key existe en dim\_customer).

1. Validación del Esquema Estrella

Objetivo: Garantizar que el Data Warehouse funcione para análisis.

Pasos:





Pruebas de Consultas:





Ejecutar consultas analíticas (como las proporcionadas: ventas por país/mes, películas rentables, etc.) para verificar datos.



Ejemplo:

SELECT dt.year, dt.month, SUM(fs.payment\_amount) AS total\_ventas

FROM fact\_sales fs

JOIN dim\_time dt ON fs.payment\_date::DATE = dt.full\_date

GROUP BY dt.year, dt.month;



Revisión de Relaciones:





Asegurar que todas las claves foráneas en fact\_sales se alineen con las dimensiones.



Correcciones:





Ajustar datos si hay inconsistencias (e.g., rellenar valores nulos en dim\_location.city).

1. Resultados Esperados





Scripts SQL: Archivos con sentencias CREATE TABLE y INSERT INTO para todas las tablas del esquema Estrella.



Diagrama de Esquema: Representación visual del esquema Estrella con relaciones entre fact\_sales y dimensiones.



Documentación: Este documento explicando cada fase del ETL.



Pruebas: Capturas de consultas ejecutadas mostrando resultados (e.g., SELECT \* FROM dim\_customer LIMIT 10).



Rendimiento: Data Warehouse optimizado para consultas analíticas rápidas y efectivas.

Este proceso crea un Data Warehouse robusto con un esquema Estrella, ideal para análisis de ventas, clientes y películas, manteniendo simplicidad y eficiencia.
