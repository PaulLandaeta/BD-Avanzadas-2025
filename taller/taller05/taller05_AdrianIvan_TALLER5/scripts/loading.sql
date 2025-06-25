-- Tabla de hechos ventas
CREATE TABLE fact_ventas (
  payment_id INTEGER PRIMARY KEY,
  rental_id INTEGER,
  customer_id SMALLINT,
  staff_id SMALLINT,
  amount NUMERIC(10,2),
  payment_date DATE
);

-- Dimensión tiempo
CREATE TABLE dim_tiempo (
  fecha DATE PRIMARY KEY,
  dia SMALLINT,
  mes SMALLINT,
  anio SMALLINT
);

-- Dimensión cliente
CREATE TABLE dim_cliente (
  customer_id SMALLINT PRIMARY KEY,
  first_name VARCHAR(50),
  last_name VARCHAR(50),
  email VARCHAR(100),
  city VARCHAR(50),
  country VARCHAR(50)
);

-- Dimensión película
CREATE TABLE dim_pelicula (
  film_id SMALLINT PRIMARY KEY,
  title VARCHAR(255),
  rating VARCHAR(10),
  rental_duration SMALLINT,
  length SMALLINT,
  replacement_cost NUMERIC(10,2),
  idioma VARCHAR(50)
);

-- Dimensión género
CREATE TABLE dim_genero (
  film_id SMALLINT PRIMARY KEY,
  genero VARCHAR(50)
);

-- Dimensión tienda
CREATE TABLE dim_tienda (
  store_id INTEGER PRIMARY KEY,
  city VARCHAR(50),
  country VARCHAR(50)
);


INSERT INTO dim_tiempo (fecha, dia, mes, anio)
SELECT DISTINCT
  DATE(payment_date) AS fecha,
  EXTRACT(DAY FROM payment_date) AS dia,
  EXTRACT(MONTH FROM payment_date) AS mes,
  EXTRACT(YEAR FROM payment_date) AS anio
FROM payment;


INSERT INTO dim_cliente (customer_id, first_name, last_name, email, city, country)
SELECT DISTINCT
  c.customer_id,
  c.first_name,
  c.last_name,
  c.email,
  ci.city,
  co.country
FROM customer c
JOIN address a ON c.address_id = a.address_id
JOIN city ci ON a.city_id = ci.city_id
JOIN country co ON ci.country_id = co.country_id;


SELECT f.film_id, f.title, l.name AS idioma
FROM film f
LEFT JOIN language l ON f.language_id = l.language_id
LIMIT 10;


INSERT INTO dim_pelicula (film_id, title, rating, rental_duration, length, replacement_cost, idioma)
SELECT DISTINCT
  f.film_id,
  f.title,
  f.rating,
  f.rental_duration,
  f.length,
  f.replacement_cost,
  COALESCE(l.name, 'Desconocido') AS idioma
FROM film f
LEFT JOIN language l ON f.language_id = l.language_id;
