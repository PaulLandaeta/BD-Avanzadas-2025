import psycopg2
import pandas as pd
from datetime import datetime


# ===== CONFIGURACIÓN DE CONEXIONES =====
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

print("🚀 Iniciando proceso ETL")
print("=" * 60)

# ===== CONEXIONES A LAS BASES DE DATOS =====
try:
    source_conn = psycopg2.connect(**SOURCE_CONFIG)
    target_conn = psycopg2.connect(**TARGET_CONFIG)
    print("✅ Conexiones a bases de datos establecidas")
except Exception as e:
    print(f"❌ Error en conexiones: {e}")
    exit(1)

# ===== CREAR ESQUEMA DEL DATA WAREHOUSE =====
print("\n📋 Creando esquema del Data Warehouse...")

create_schema_sql = """
-- Crear esquema
CREATE SCHEMA IF NOT EXISTS dvdrental_dw;

-- Dimensión Tiempo
DROP TABLE IF EXISTS dvdrental_dw.dim_time CASCADE;
CREATE TABLE dvdrental_dw.dim_time (
    time_key SERIAL PRIMARY KEY,
    full_date DATE UNIQUE NOT NULL,
    year INT NOT NULL,
    quarter INT NOT NULL,
    month INT NOT NULL,
    month_name VARCHAR(20) NOT NULL,
    day INT NOT NULL
);

-- Dimensión Cliente
DROP TABLE IF EXISTS dvdrental_dw.dim_customer CASCADE;
CREATE TABLE dvdrental_dw.dim_customer (
    customer_key SERIAL PRIMARY KEY,
    customer_id INT UNIQUE NOT NULL,
    first_name VARCHAR(45) NOT NULL,
    last_name VARCHAR(45) NOT NULL,
    email VARCHAR(50),
    customer_status BOOLEAN NOT NULL,
    registration_date DATE NOT NULL
);

-- Dimensión Película
DROP TABLE IF EXISTS dvdrental_dw.dim_film CASCADE;
CREATE TABLE dvdrental_dw.dim_film (
    film_key SERIAL PRIMARY KEY,
    film_id INT UNIQUE NOT NULL,
    title VARCHAR(255) NOT NULL,
    description TEXT,
    release_year INT,
    rating VARCHAR(10),
    length INT,
    rental_duration INT NOT NULL,
    rental_rate DECIMAL(4,2) NOT NULL
);

-- Dimensión Categoría
DROP TABLE IF EXISTS dvdrental_dw.dim_category CASCADE;
CREATE TABLE dvdrental_dw.dim_category (
    category_key SERIAL PRIMARY KEY,
    category_id INT UNIQUE NOT NULL,
    category_name VARCHAR(25) NOT NULL
);

-- Dimensión Tienda
DROP TABLE IF EXISTS dvdrental_dw.dim_store CASCADE;
CREATE TABLE dvdrental_dw.dim_store (
    store_key SERIAL PRIMARY KEY,
    store_id INT UNIQUE NOT NULL,
    manager_first_name VARCHAR(45),
    manager_last_name VARCHAR(45),
    store_address VARCHAR(50),
    store_city VARCHAR(50),
    store_country VARCHAR(50),
    store_postal_code VARCHAR(10)
);

-- Dimensión Ubicación
DROP TABLE IF EXISTS dvdrental_dw.dim_location CASCADE;
CREATE TABLE dvdrental_dw.dim_location (
    location_key SERIAL PRIMARY KEY,
    address_id INT UNIQUE NOT NULL,
    address VARCHAR(50),
    district VARCHAR(20),
    city VARCHAR(50),
    country VARCHAR(50),
    postal_code VARCHAR(10)
);

-- Dimensión Staff
DROP TABLE IF EXISTS dvdrental_dw.dim_staff CASCADE;
CREATE TABLE dvdrental_dw.dim_staff (
    staff_key SERIAL PRIMARY KEY,
    staff_id INT UNIQUE NOT NULL,
    first_name VARCHAR(45),
    last_name VARCHAR(45),
    email VARCHAR(50),
    store_id INT,
    active BOOLEAN
);

-- Tabla de Hechos
DROP TABLE IF EXISTS dvdrental_dw.fact_sales CASCADE;
CREATE TABLE dvdrental_dw.fact_sales (
    sales_key SERIAL PRIMARY KEY,
    customer_key INT REFERENCES dvdrental_dw.dim_customer(customer_key),
    film_key INT REFERENCES dvdrental_dw.dim_film(film_key),
    store_key INT REFERENCES dvdrental_dw.dim_store(store_key),
    time_key INT REFERENCES dvdrental_dw.dim_time(time_key),
    location_key INT REFERENCES dvdrental_dw.dim_location(location_key),
    category_key INT REFERENCES dvdrental_dw.dim_category(category_key),
    staff_key INT REFERENCES dvdrental_dw.dim_staff(staff_key),
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
    print("✅ Esquema del Data Warehouse creado exitosamente")
except Exception as e:
    print(f"❌ Error creando esquema: {e}")
    exit(1)

# ===== CARGA DE DIMENSIÓN TIEMPO =====
print("\n📅 Cargando dimensión TIEMPO...")

time_sql = """
INSERT INTO dvdrental_dw.dim_time (
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
        cursor.execute("SELECT COUNT(*) FROM dvdrental_dw.dim_time")
        count = cursor.fetchone()[0]
    print(f"✅ Dimensión TIEMPO cargada: {count} registros")
except Exception as e:
    print(f"❌ Error cargando dimensión TIEMPO: {e}")

# ===== CARGA DE DIMENSIÓN CLIENTE =====
print("\n👤 Cargando dimensión CLIENTE...")

customer_sql = """
INSERT INTO dvdrental_dw.dim_customer (
    customer_id, first_name, last_name, email, customer_status, registration_date
)
SELECT 
    c.customer_id,
    c.first_name,
    c.last_name,
    c.email,
    c.activebool,
    c.create_date
FROM customer c
ORDER BY c.customer_id;
"""

try:
    with target_conn.cursor() as cursor:
        cursor.execute(customer_sql)
        target_conn.commit()
        cursor.execute("SELECT COUNT(*) FROM dvdrental_dw.dim_customer")
        count = cursor.fetchone()[0]
    print(f"✅ Dimensión CLIENTE cargada: {count} registros")
except Exception as e:
    print(f"❌ Error cargando dimensión CLIENTE: {e}")

# ===== CARGA DE DIMENSIÓN PELÍCULA =====
print("\n🎬 Cargando dimensión PELÍCULA...")

film_sql = """
INSERT INTO dvdrental_dw.dim_film (
    film_id, title, description, release_year, rating, 
    length, rental_duration, rental_rate
)
SELECT 
    f.film_id,
    f.title,
    f.description,
    f.release_year,
    f.rating,
    f.length,
    f.rental_duration,
    f.rental_rate
FROM film f
ORDER BY f.film_id;
"""

try:
    with target_conn.cursor() as cursor:
        cursor.execute(film_sql)
        target_conn.commit()
        cursor.execute("SELECT COUNT(*) FROM dvdrental_dw.dim_film")
        count = cursor.fetchone()[0]
    print(f"✅ Dimensión PELÍCULA cargada: {count} registros")
except Exception as e:
    print(f"❌ Error cargando dimensión PELÍCULA: {e}")

# ===== CARGA DE DIMENSIÓN CATEGORÍA =====
print("\n🎭 Cargando dimensión CATEGORÍA...")

category_sql = """
INSERT INTO dvdrental_dw.dim_category (category_id, category_name)
SELECT category_id, name
FROM category
ORDER BY category_id;
"""

try:
    with target_conn.cursor() as cursor:
        cursor.execute(category_sql)
        target_conn.commit()
        cursor.execute("SELECT COUNT(*) FROM dvdrental_dw.dim_category")
        count = cursor.fetchone()[0]
    print(f"✅ Dimensión CATEGORÍA cargada: {count} registros")
except Exception as e:
    print(f"❌ Error cargando dimensión CATEGORÍA: {e}")

# ===== CARGA DE DIMENSIÓN TIENDA =====
print("\n🏪 Cargando dimensión TIENDA...")

store_sql = """
INSERT INTO dvdrental_dw.dim_store (
    store_id, manager_first_name, manager_last_name, 
    store_address, store_city, store_country, store_postal_code
)
SELECT 
    s.store_id,
    st.first_name,
    st.last_name,
    a.address,
    c.city,
    co.country,
    a.postal_code
FROM store s
JOIN staff st ON s.manager_staff_id = st.staff_id
JOIN address a ON s.address_id = a.address_id
JOIN city c ON a.city_id = c.city_id
JOIN country co ON c.country_id = co.country_id
ORDER BY s.store_id;
"""

try:
    with target_conn.cursor() as cursor:
        cursor.execute(store_sql)
        target_conn.commit()
        cursor.execute("SELECT COUNT(*) FROM dvdrental_dw.dim_store")
        count = cursor.fetchone()[0]
    print(f"✅ Dimensión TIENDA cargada: {count} registros")
except Exception as e:
    print(f"❌ Error cargando dimensión TIENDA: {e}")

# ===== CARGA DE DIMENSIÓN UBICACIÓN =====
print("\n📍 Cargando dimensión UBICACIÓN...")

location_sql = """
INSERT INTO dvdrental_dw.dim_location (
    address_id, address, district, city, country, postal_code
)
SELECT DISTINCT
    a.address_id,
    a.address,
    a.district,
    c.city,
    co.country,
    a.postal_code
FROM address a
JOIN city c ON a.city_id = c.city_id
JOIN country co ON c.country_id = co.country_id
WHERE a.address_id IN (SELECT DISTINCT address_id FROM customer)
ORDER BY a.address_id;
"""

try:
    with target_conn.cursor() as cursor:
        cursor.execute(location_sql)
        target_conn.commit()
        cursor.execute("SELECT COUNT(*) FROM dvdrental_dw.dim_location")
        count = cursor.fetchone()[0]
    print(f"✅ Dimensión UBICACIÓN cargada: {count} registros")
except Exception as e:
    print(f"❌ Error cargando dimensión UBICACIÓN: {e}")

# ===== CARGA DE DIMENSIÓN STAFF =====
print("\n👥 Cargando dimensión STAFF...")

staff_sql = """
INSERT INTO dvdrental_dw.dim_staff (
    staff_id, first_name, last_name, email, store_id, active
)
SELECT 
    staff_id, first_name, last_name, email, store_id, active
FROM staff
ORDER BY staff_id;
"""

try:
    with target_conn.cursor() as cursor:
        cursor.execute(staff_sql)
        target_conn.commit()
        cursor.execute("SELECT COUNT(*) FROM dvdrental_dw.dim_staff")
        count = cursor.fetchone()[0]
    print(f"✅ Dimensión STAFF cargada: {count} registros")
except Exception as e:
    print(f"❌ Error cargando dimensión STAFF: {e}")

# ===== CARGA DE TABLA DE HECHOS =====
print("\n📊 Cargando tabla de HECHOS (FACT_SALES)...")

fact_sql = """
INSERT INTO dvdrental_dw.fact_sales (
    customer_key, film_key, store_key, time_key, location_key, 
    category_key, staff_key, rental_id, payment_id, payment_amount, 
    rental_days, rental_date, return_date, payment_date
)
SELECT 
    dc.customer_key,
    df.film_key,
    ds.store_key,
    dt.time_key,
    dl.location_key,
    dcat.category_key,
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
JOIN film_category fc ON f.film_id = fc.film_id
JOIN category cat ON fc.category_id = cat.category_id
JOIN customer c ON r.customer_id = c.customer_id
JOIN address a ON c.address_id = a.address_id
JOIN store s ON i.store_id = s.store_id
JOIN staff st ON r.staff_id = st.staff_id
-- JOINs con dimensiones del DW
JOIN dvdrental_dw.dim_customer dc ON c.customer_id = dc.customer_id
JOIN dvdrental_dw.dim_film df ON f.film_id = df.film_id
JOIN dvdrental_dw.dim_store ds ON s.store_id = ds.store_id
JOIN dvdrental_dw.dim_time dt ON DATE(p.payment_date) = dt.full_date
JOIN dvdrental_dw.dim_location dl ON a.address_id = dl.address_id
JOIN dvdrental_dw.dim_category dcat ON cat.category_id = dcat.category_id
JOIN dvdrental_dw.dim_staff dst ON st.staff_id = dst.staff_id
ORDER BY p.payment_date, p.payment_id;
"""

try:
    with target_conn.cursor() as cursor:
        cursor.execute(fact_sql)
        target_conn.commit()
        cursor.execute("SELECT COUNT(*) FROM dvdrental_dw.fact_sales")
        count = cursor.fetchone()[0]
    print(f"✅ Tabla de HECHOS cargada: {count} registros")
except Exception as e:
    print(f"❌ Error cargando tabla de HECHOS: {e}")


# ===== VERIFICACIÓN FINAL =====
print("\n🔍 Verificación final del Data Warehouse...")

verification_queries = [
    ("Dimensión Tiempo", "SELECT COUNT(*) FROM dvdrental_dw.dim_time"),
    ("Dimensión Cliente", "SELECT COUNT(*) FROM dvdrental_dw.dim_customer"),
    ("Dimensión Película", "SELECT COUNT(*) FROM dvdrental_dw.dim_film"),
    ("Dimensión Categoría", "SELECT COUNT(*) FROM dvdrental_dw.dim_category"),
    ("Dimensión Tienda", "SELECT COUNT(*) FROM dvdrental_dw.dim_store"),
    ("Dimensión Ubicación", "SELECT COUNT(*) FROM dvdrental_dw.dim_location"),
    ("Dimensión Staff", "SELECT COUNT(*) FROM dvdrental_dw.dim_staff"),
    ("Tabla de Hechos", "SELECT COUNT(*) FROM dvdrental_dw.fact_sales"),
]

print("\n📊 RESUMEN DE CARGA:")
print("-" * 40)
for table_name, query in verification_queries:
    try:
        with target_conn.cursor() as cursor:
            cursor.execute(query)
            count = cursor.fetchone()[0]
        print(f"{table_name:<20}: {count:>8} registros")
    except Exception as e:
        print(f"{table_name:<20}: ERROR - {e}")


# ===== CIERRE DE CONEXIONES =====
source_conn.close()
target_conn.close()

print("\n" + "=" * 60)
print("🎉 ETL COMPLETADO EXITOSAMENTE")
print(f"⏰ Proceso finalizado")
print("=" * 60)