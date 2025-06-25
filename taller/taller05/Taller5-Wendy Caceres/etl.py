import psycopg2
import pandas as pd
from datetime import datetime


SOURCE_CONFIG = {
    'host': 'localhost',
    'database': 'dvdrental',
    'user': 'nameUser',
    'password': 'passwordUser',
    'port': 5432
}

TARGET_CONFIG = {
    'host': 'localhost', 
    'database': 'dvdrental',
    'user': 'nameUser',
    'password': 'passwordUser',
    'port': 5432
}

print("🚀 Iniciando proceso ETL - ESQUEMA SNOWFLAKE")
print("=" * 60)

try:
    source_conn = psycopg2.connect(**SOURCE_CONFIG)
    target_conn = psycopg2.connect(**TARGET_CONFIG)
    print("✅ Conexiones a bases de datos establecidas")
except Exception as e:
    print(f"❌ Error en conexiones: {e}")
    exit(1)

print("\n📋 Creando esquema Snowflake del Data Warehouse...")

create_schema_sql = """
-- Crear esquema
CREATE SCHEMA IF NOT EXISTS dvdrental_snowflake;

-- Dimensión Tiempo (sin cambios)
DROP TABLE IF EXISTS dvdrental_snowflake.dim_time CASCADE;
CREATE TABLE dvdrental_snowflake.dim_time (
    time_key SERIAL PRIMARY KEY,
    full_date DATE UNIQUE NOT NULL,
    year INT NOT NULL,
    quarter INT NOT NULL,
    month INT NOT NULL,
    month_name VARCHAR(20) NOT NULL,
    day INT NOT NULL
);

-- Subdimensión País
DROP TABLE IF EXISTS dvdrental_snowflake.dim_country CASCADE;
CREATE TABLE dvdrental_snowflake.dim_country (
    country_key SERIAL PRIMARY KEY,
    country_id INT UNIQUE NOT NULL,
    country_name VARCHAR(50) NOT NULL
);

-- Subdimensión Ciudad
DROP TABLE IF EXISTS dvdrental_snowflake.dim_city CASCADE;
CREATE TABLE dvdrental_snowflake.dim_city (
    city_key SERIAL PRIMARY KEY,
    city_id INT UNIQUE NOT NULL,
    city_name VARCHAR(50) NOT NULL,
    country_key INT REFERENCES dvdrental_snowflake.dim_country(country_key)
);

-- Dimensión Ubicación (normalizada)
DROP TABLE IF EXISTS dvdrental_snowflake.dim_location CASCADE;
CREATE TABLE dvdrental_snowflake.dim_location (
    location_key SERIAL PRIMARY KEY,
    address_id INT UNIQUE NOT NULL,
    address VARCHAR(50),
    district VARCHAR(20),
    postal_code VARCHAR(10),
    city_key INT REFERENCES dvdrental_snowflake.dim_city(city_key)
);

-- Dimensión Cliente (normalizada)
DROP TABLE IF EXISTS dvdrental_snowflake.dim_customer CASCADE;
CREATE TABLE dvdrental_snowflake.dim_customer (
    customer_key SERIAL PRIMARY KEY,
    customer_id INT UNIQUE NOT NULL,
    first_name VARCHAR(45) NOT NULL,
    last_name VARCHAR(45) NOT NULL,
    email VARCHAR(50),
    customer_status BOOLEAN NOT NULL,
    registration_date DATE NOT NULL,
    location_key INT REFERENCES dvdrental_snowflake.dim_location(location_key)
);

-- Subdimensión Idioma
DROP TABLE IF EXISTS dvdrental_snowflake.dim_language CASCADE;
CREATE TABLE dvdrental_snowflake.dim_language (
    language_key SERIAL PRIMARY KEY,
    language_id INT UNIQUE NOT NULL,
    language_name VARCHAR(20) NOT NULL
);

-- Dimensión Categoría
DROP TABLE IF EXISTS dvdrental_snowflake.dim_category CASCADE;
CREATE TABLE dvdrental_snowflake.dim_category (
    category_key SERIAL PRIMARY KEY,
    category_id INT UNIQUE NOT NULL,
    category_name VARCHAR(25) NOT NULL
);

-- Dimensión Película (normalizada)
DROP TABLE IF EXISTS dvdrental_snowflake.dim_film CASCADE;
CREATE TABLE dvdrental_snowflake.dim_film (
    film_key SERIAL PRIMARY KEY,
    film_id INT UNIQUE NOT NULL,
    title VARCHAR(255) NOT NULL,
    description TEXT,
    release_year INT,
    rating VARCHAR(10),
    length INT,
    rental_duration INT NOT NULL,
    rental_rate DECIMAL(4,2) NOT NULL,
    language_key INT REFERENCES dvdrental_snowflake.dim_language(language_key),
    category_key INT REFERENCES dvdrental_snowflake.dim_category(category_key)
);

-- Dimensión Tienda (normalizada)
DROP TABLE IF EXISTS dvdrental_snowflake.dim_store CASCADE;
CREATE TABLE dvdrental_snowflake.dim_store (
    store_key SERIAL PRIMARY KEY,
    store_id INT UNIQUE NOT NULL,
    manager_first_name VARCHAR(45),
    manager_last_name VARCHAR(45),
    location_key INT REFERENCES dvdrental_snowflake.dim_location(location_key)
);

-- Dimensión Staff (normalizada)
DROP TABLE IF EXISTS dvdrental_snowflake.dim_staff CASCADE;
CREATE TABLE dvdrental_snowflake.dim_staff (
    staff_key SERIAL PRIMARY KEY,
    staff_id INT UNIQUE NOT NULL,
    first_name VARCHAR(45),
    last_name VARCHAR(45),
    email VARCHAR(50),
    active BOOLEAN,
    store_key INT REFERENCES dvdrental_snowflake.dim_store(store_key)
);

-- Tabla de Hechos (simplificada por normalización)
DROP TABLE IF EXISTS dvdrental_snowflake.fact_sales CASCADE;
CREATE TABLE dvdrental_snowflake.fact_sales (
    sales_key SERIAL PRIMARY KEY,
    customer_key INT REFERENCES dvdrental_snowflake.dim_customer(customer_key),
    film_key INT REFERENCES dvdrental_snowflake.dim_film(film_key),
    store_key INT REFERENCES dvdrental_snowflake.dim_store(store_key),
    time_key INT REFERENCES dvdrental_snowflake.dim_time(time_key),
    staff_key INT REFERENCES dvdrental_snowflake.dim_staff(staff_key),
    rental_id INT NOT NULL,
    payment_id INT NOT NULL,
    payment_amount DECIMAL(5,2) NOT NULL,
    rental_days INT,
    rental_count INT DEFAULT 1,
    rental_date DATE,
    return_date DATE,
    payment_date DATE
);
"""

try:
    with target_conn.cursor() as cursor:
        cursor.execute(create_schema_sql)
        target_conn.commit()
    print("✅ Esquema Snowflake del Data Warehouse creado exitosamente")
except Exception as e:
    print(f"❌ Error creando esquema: {e}")
    exit(1)

print("\n📅 Cargando dimensión TIEMPO...")

time_sql = """
INSERT INTO dvdrental_snowflake.dim_time (
    full_date, year, quarter, month, month_name, day
)
SELECT DISTINCT
    DATE(p.payment_date) as full_date,
    EXTRACT(YEAR FROM p.payment_date) as year,
    EXTRACT(QUARTER FROM p.payment_date) as quarter,
    EXTRACT(MONTH FROM p.payment_date) as month,
    TO_CHAR(p.payment_date, 'Month') as month_name,
    EXTRACT(DAY FROM p.payment_date) as day
FROM payment p
ORDER BY full_date;
"""

try:
    with target_conn.cursor() as cursor:
        cursor.execute(time_sql)
        target_conn.commit()
        cursor.execute("SELECT COUNT(*) FROM dvdrental_snowflake.dim_time")
        count = cursor.fetchone()[0]
    print(f"✅ Dimensión TIEMPO cargada: {count} registros")
except Exception as e:
    print(f"❌ Error cargando dimensión TIEMPO: {e}")

print("\n🌍 Cargando dimensión PAÍS...")

country_sql = """
INSERT INTO dvdrental_snowflake.dim_country (country_id, country_name)
SELECT country_id, country
FROM country
ORDER BY country_id;
"""

try:
    with target_conn.cursor() as cursor:
        cursor.execute(country_sql)
        target_conn.commit()
        cursor.execute("SELECT COUNT(*) FROM dvdrental_snowflake.dim_country")
        count = cursor.fetchone()[0]
    print(f"✅ Dimensión PAÍS cargada: {count} registros")
except Exception as e:
    print(f"❌ Error cargando dimensión PAÍS: {e}")

print("\n🏙️ Cargando dimensión CIUDAD...")

city_sql = """
INSERT INTO dvdrental_snowflake.dim_city (city_id, city_name, country_key)
SELECT 
    c.city_id,
    c.city,
    dc.country_key
FROM city c
JOIN country co ON c.country_id = co.country_id
JOIN dvdrental_snowflake.dim_country dc ON co.country_id = dc.country_id
ORDER BY c.city_id;
"""

try:
    with target_conn.cursor() as cursor:
        cursor.execute(city_sql)
        target_conn.commit()
        cursor.execute("SELECT COUNT(*) FROM dvdrental_snowflake.dim_city")
        count = cursor.fetchone()[0]
    print(f"✅ Dimensión CIUDAD cargada: {count} registros")
except Exception as e:
    print(f"❌ Error cargando dimensión CIUDAD: {e}")

print("\n📍 Cargando dimensión UBICACIÓN...")

location_sql = """
INSERT INTO dvdrental_snowflake.dim_location (
    address_id, address, district, postal_code, city_key
)
SELECT DISTINCT
    a.address_id,
    a.address,
    a.district,
    a.postal_code,
    dci.city_key
FROM address a
JOIN city c ON a.city_id = c.city_id
JOIN dvdrental_snowflake.dim_city dci ON c.city_id = dci.city_id
WHERE a.address_id IN (SELECT DISTINCT address_id FROM customer)
   OR a.address_id IN (SELECT DISTINCT address_id FROM store)
ORDER BY a.address_id;
"""

try:
    with target_conn.cursor() as cursor:
        cursor.execute(location_sql)
        target_conn.commit()
        cursor.execute("SELECT COUNT(*) FROM dvdrental_snowflake.dim_location")
        count = cursor.fetchone()[0]
    print(f"✅ Dimensión UBICACIÓN cargada: {count} registros")
except Exception as e:
    print(f"❌ Error cargando dimensión UBICACIÓN: {e}")

print("\n👤 Cargando dimensión CLIENTE...")

customer_sql = """
INSERT INTO dvdrental_snowflake.dim_customer (
    customer_id, first_name, last_name, email, customer_status, 
    registration_date, location_key
)
SELECT 
    c.customer_id,
    c.first_name,
    c.last_name,
    c.email,
    c.activebool,
    c.create_date,
    dl.location_key
FROM customer c
JOIN address a ON c.address_id = a.address_id
JOIN dvdrental_snowflake.dim_location dl ON a.address_id = dl.address_id
ORDER BY c.customer_id;
"""

try:
    with target_conn.cursor() as cursor:
        cursor.execute(customer_sql)
        target_conn.commit()
        cursor.execute("SELECT COUNT(*) FROM dvdrental_snowflake.dim_customer")
        count = cursor.fetchone()[0]
    print(f"✅ Dimensión CLIENTE cargada: {count} registros")
except Exception as e:
    print(f"❌ Error cargando dimensión CLIENTE: {e}")

print("\n🗣️ Cargando dimensión IDIOMA...")

language_sql = """
INSERT INTO dvdrental_snowflake.dim_language (language_id, language_name)
SELECT language_id, name
FROM language
ORDER BY language_id;
"""

try:
    with target_conn.cursor() as cursor:
        cursor.execute(language_sql)
        target_conn.commit()
        cursor.execute("SELECT COUNT(*) FROM dvdrental_snowflake.dim_language")
        count = cursor.fetchone()[0]
    print(f"✅ Dimensión IDIOMA cargada: {count} registros")
except Exception as e:
    print(f"❌ Error cargando dimensión IDIOMA: {e}")

print("\n🎭 Cargando dimensión CATEGORÍA...")

category_sql = """
INSERT INTO dvdrental_snowflake.dim_category (category_id, category_name)
SELECT category_id, name
FROM category
ORDER BY category_id;
"""

try:
    with target_conn.cursor() as cursor:
        cursor.execute(category_sql)
        target_conn.commit()
        cursor.execute("SELECT COUNT(*) FROM dvdrental_snowflake.dim_category")
        count = cursor.fetchone()[0]
    print(f"✅ Dimensión CATEGORÍA cargada: {count} registros")
except Exception as e:
    print(f"❌ Error cargando dimensión CATEGORÍA: {e}")

print("\n🎬 Cargando dimensión PELÍCULA...")

film_sql = """
INSERT INTO dvdrental_snowflake.dim_film (
    film_id, title, description, release_year, rating, 
    length, rental_duration, rental_rate, language_key, category_key
)
SELECT 
    f.film_id,
    f.title,
    f.description,
    f.release_year,
    f.rating,
    f.length,
    f.rental_duration,
    f.rental_rate,
    dl.language_key,
    dc.category_key
FROM film f
JOIN language l ON f.language_id = l.language_id
JOIN dvdrental_snowflake.dim_language dl ON l.language_id = dl.language_id
JOIN film_category fc ON f.film_id = fc.film_id
JOIN category c ON fc.category_id = c.category_id
JOIN dvdrental_snowflake.dim_category dc ON c.category_id = dc.category_id
ORDER BY f.film_id;
"""

try:
    with target_conn.cursor() as cursor:
        cursor.execute(film_sql)
        target_conn.commit()
        cursor.execute("SELECT COUNT(*) FROM dvdrental_snowflake.dim_film")
        count = cursor.fetchone()[0]
    print(f"✅ Dimensión PELÍCULA cargada: {count} registros")
except Exception as e:
    print(f"❌ Error cargando dimensión PELÍCULA: {e}")

print("\n🏪 Cargando dimensión TIENDA...")

store_sql = """
INSERT INTO dvdrental_snowflake.dim_store (
    store_id, manager_first_name, manager_last_name, location_key
)
SELECT 
    s.store_id,
    st.first_name,
    st.last_name,
    dl.location_key
FROM store s
JOIN staff st ON s.manager_staff_id = st.staff_id
JOIN address a ON s.address_id = a.address_id
JOIN dvdrental_snowflake.dim_location dl ON a.address_id = dl.address_id
ORDER BY s.store_id;
"""

try:
    with target_conn.cursor() as cursor:
        cursor.execute(store_sql)
        target_conn.commit()
        cursor.execute("SELECT COUNT(*) FROM dvdrental_snowflake.dim_store")
        count = cursor.fetchone()[0]
    print(f"✅ Dimensión TIENDA cargada: {count} registros")
except Exception as e:
    print(f"❌ Error cargando dimensión TIENDA: {e}")

print("\n👥 Cargando dimensión STAFF...")

staff_sql = """
INSERT INTO dvdrental_snowflake.dim_staff (
    staff_id, first_name, last_name, email, active, store_key
)
SELECT 
    st.staff_id,
    st.first_name,
    st.last_name,
    st.email,
    st.active,
    ds.store_key
FROM staff st
JOIN store s ON st.store_id = s.store_id
JOIN dvdrental_snowflake.dim_store ds ON s.store_id = ds.store_id
ORDER BY st.staff_id;
"""

try:
    with target_conn.cursor() as cursor:
        cursor.execute(staff_sql)
        target_conn.commit()
        cursor.execute("SELECT COUNT(*) FROM dvdrental_snowflake.dim_staff")
        count = cursor.fetchone()[0]
    print(f"✅ Dimensión STAFF cargada: {count} registros")
except Exception as e:
    print(f"❌ Error cargando dimensión STAFF: {e}")

print("\n📊 Cargando tabla de HECHOS (FACT_SALES)...")

fact_sql = """
INSERT INTO dvdrental_snowflake.fact_sales (
    customer_key, film_key, store_key, time_key, staff_key,
    rental_id, payment_id, payment_amount, rental_days, 
    rental_date, return_date, payment_date
)
SELECT 
    dc.customer_key,
    df.film_key,
    ds.store_key,
    dt.time_key,
    dst.staff_key,
    r.rental_id,
    p.payment_id,
    p.amount,
    CASE 
        WHEN r.return_date IS NOT NULL 
        THEN DATE_PART('day', r.return_date - r.rental_date)::INT 
        ELSE NULL 
    END as rental_days,
    DATE(r.rental_date),
    DATE(r.return_date),
    DATE(p.payment_date)
FROM payment p
JOIN rental r ON p.rental_id = r.rental_id
JOIN inventory i ON r.inventory_id = i.inventory_id
JOIN film f ON i.film_id = f.film_id
JOIN customer c ON r.customer_id = c.customer_id
JOIN store s ON i.store_id = s.store_id
JOIN staff st ON r.staff_id = st.staff_id
-- JOINs con dimensiones del DW Snowflake
JOIN dvdrental_snowflake.dim_customer dc ON c.customer_id = dc.customer_id
JOIN dvdrental_snowflake.dim_film df ON f.film_id = df.film_id
JOIN dvdrental_snowflake.dim_store ds ON s.store_id = ds.store_id
JOIN dvdrental_snowflake.dim_time dt ON DATE(p.payment_date) = dt.full_date
JOIN dvdrental_snowflake.dim_staff dst ON st.staff_id = dst.staff_id
ORDER BY p.payment_date, p.payment_id;
"""

try:
    with target_conn.cursor() as cursor:
        cursor.execute(fact_sql)
        target_conn.commit()
        cursor.execute("SELECT COUNT(*) FROM dvdrental_snowflake.fact_sales")
        count = cursor.fetchone()[0]
    print(f"✅ Tabla de HECHOS cargada: {count} registros")
except Exception as e:
    print(f"❌ Error cargando tabla de HECHOS: {e}")

print("\n🔍 Verificación final del Data Warehouse Snowflake...")

verification_queries = [
    ("Dimensión Tiempo", "SELECT COUNT(*) FROM dvdrental_snowflake.dim_time"),
    ("Dimensión País", "SELECT COUNT(*) FROM dvdrental_snowflake.dim_country"),
    ("Dimensión Ciudad", "SELECT COUNT(*) FROM dvdrental_snowflake.dim_city"),
    ("Dimensión Ubicación", "SELECT COUNT(*) FROM dvdrental_snowflake.dim_location"),
    ("Dimensión Cliente", "SELECT COUNT(*) FROM dvdrental_snowflake.dim_customer"),
    ("Dimensión Idioma", "SELECT COUNT(*) FROM dvdrental_snowflake.dim_language"),
    ("Dimensión Categoría", "SELECT COUNT(*) FROM dvdrental_snowflake.dim_category"),
    ("Dimensión Película", "SELECT COUNT(*) FROM dvdrental_snowflake.dim_film"),
    ("Dimensión Tienda", "SELECT COUNT(*) FROM dvdrental_snowflake.dim_store"),
    ("Dimensión Staff", "SELECT COUNT(*) FROM dvdrental_snowflake.dim_staff"),
    ("Tabla de Hechos", "SELECT COUNT(*) FROM dvdrental_snowflake.fact_sales"),
]

print("\n📊 RESUMEN DE CARGA SNOWFLAKE:")
print("-" * 50)
for table_name, query in verification_queries:
    try:
        with target_conn.cursor() as cursor:
            cursor.execute(query)
            count = cursor.fetchone()[0]
        print(f"{table_name:<25}: {count:>8} registros")
    except Exception as e:
        print(f"{table_name:<25}: ERROR - {e}")

print("\n🧪 Ejecutando consultas de prueba Snowflake...")

test_queries = [
    ("Total ventas por país (usando jerarquía normalizada)", """
        SELECT 
            dco.country_name,
            SUM(fs.payment_amount) as total_ventas,
            COUNT(*) as total_transacciones
        FROM dvdrental_snowflake.fact_sales fs
        JOIN dvdrental_snowflake.dim_customer dc ON fs.customer_key = dc.customer_key
        JOIN dvdrental_snowflake.dim_location dl ON dc.location_key = dl.location_key
        JOIN dvdrental_snowflake.dim_city dci ON dl.city_key = dci.city_key
        JOIN dvdrental_snowflake.dim_country dco ON dci.country_key = dco.country_key
        GROUP BY dco.country_name
        ORDER BY total_ventas DESC
        LIMIT 5;
    """),
    
    ("Películas por categoría e idioma", """
        SELECT 
            dcat.category_name,
            dl.language_name,
            SUM(fs.payment_amount) as ingresos_totales,
            COUNT(*) as total_rentas
        FROM dvdrental_snowflake.fact_sales fs
        JOIN dvdrental_snowflake.dim_film df ON fs.film_key = df.film_key
        JOIN dvdrental_snowflake.dim_category dcat ON df.category_key = dcat.category_key
        JOIN dvdrental_snowflake.dim_language dl ON df.language_key = dl.language_key
        GROUP BY dcat.category_name, dl.language_name
        ORDER BY ingresos_totales DESC
        LIMIT 10;
    """),
    
    ("Ventas por tienda y ciudad", """
        SELECT 
            ds.store_id,
            CONCAT(ds.manager_first_name, ' ', ds.manager_last_name) as gerente,
            dci.city_name,
            dco.country_name,
            SUM(fs.payment_amount) as ventas_totales,
            COUNT(*) as total_transacciones
        FROM dvdrental_snowflake.fact_sales fs
        JOIN dvdrental_snowflake.dim_store ds ON fs.store_key = ds.store_key
        JOIN dvdrental_snowflake.dim_location dl ON ds.location_key = dl.location_key
        JOIN dvdrental_snowflake.dim_city dci ON dl.city_key = dci.city_key
        JOIN dvdrental_snowflake.dim_country dco ON dci.country_key = dco.country_key
        GROUP BY ds.store_id, gerente, dci.city_name, dco.country_name
        ORDER BY ventas_totales DESC;
    """)
]

for test_name, query in test_queries:
    print(f"\n📈 {test_name}:")
    try:
        df = pd.read_sql(query, target_conn)
        print(df.to_string(index=False))
    except Exception as e:
        print(f"❌ Error en consulta: {e}")

source_conn.close()
target_conn.close()

print("\n" + "=" * 60)
print("🎉 ETL SNOWFLAKE COMPLETADO EXITOSAMENTE")
print(f"⏰ Proceso finalizado")
print("=" * 60)