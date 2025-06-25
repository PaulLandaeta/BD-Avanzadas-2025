--Total de ventas por pais y mes
select 
    co.country,
    DATE_TRUNC('month', p.payment_date) as month,
    count(*) as total_rentals,
    sum(p.amount) as total_sales
from payment p
inner join customer c on p.customer_id = c.customer_id
inner join address a on c.address_id = a.address_id
inner join city ci on a.city_id = ci.city_id
inner join country co on ci.country_id = co.country_id
group by co.country, DATE_TRUNC('month', p.payment_date)
order by co.country, month;
--peliculas mas rentables por rating
select 
    f.rating,
    f.title,
    sum(p.amount) as total_revenue
from payment p
inner join rental r on p.rental_id = r.rental_id
inner join inventory i on r.inventory_id = i.inventory_id
inner join film f on  i.film_id = f.film_id
group by f.rating, f.title
order by f.rating, total_revenue desc;

--Ventas promedio por tienda
select 
    s.store_id,
    avg(p.amount) as avg_sales
from payment p
inner join staff st on p.staff_id = st.staff_id
inner join store s on st.store_id = s.store_id
group by s.store_id;

--Ventas totales por género
select 
    c.name as genre,
    SUM(p.amount) as total_sales
from payment p
inner join rental r on p.rental_id = r.rental_id
inner join inventory i on r.inventory_id = i.inventory_id
inner join film f on i.film_id = f.film_id
inner join film_category fc on f.film_id = fc.film_id
inner join category c on fc.category_id = c.category_id
group by c.name
order by total_sales desc;

--Promedio de gasto por cliente segun tienda, ciudad de la pelicula
select 
    s.store_id,
    ci.city,
    c.customer_id,
    avg(p.amount) as avg_spent
from payment p
inner join customer c on p.customer_id = c.customer_id
inner join address a on c.address_id = a.address_id
inner join city ci on a.city_id = ci.city_id
inner join store s on c.store_id = s.store_id
group by s.store_id, ci.city, c.customer_id
order by s.store_id, ci.city, avg_spent desc;

--Transformar Datos-----------------------------------------------------------------------------------
CREATE TEMP TABLE sales_staging AS
SELECT 
    DATE_TRUNC('month', p.payment_date) AS sale_month,
    co.country,
    s.store_id,
    f.film_id,
    f.title,
    f.rating,
    c.name AS genre,
    ci.city AS film_city,
    p.customer_id,
    SUM(p.amount) AS total_amount,
    COUNT(*) AS rental_count
FROM payment p
JOIN rental r ON p.rental_id = r.rental_id
JOIN customer cu ON p.customer_id = cu.customer_id
JOIN address a ON cu.address_id = a.address_id
JOIN city ci ON a.city_id = ci.city_id
JOIN country co ON ci.country_id = co.country_id
JOIN store s ON cu.store_id = s.store_id
JOIN inventory i ON r.inventory_id = i.inventory_id
JOIN film f ON i.film_id = f.film_id
JOIN film_category fc ON f.film_id = fc.film_id
JOIN category c ON fc.category_id = c.category_id
GROUP BY 
    DATE_TRUNC('month', p.payment_date),
    co.country,
    s.store_id,
    f.film_id,
    f.title,
    f.rating,
    c.name,
    ci.city,
    p.customer_id;



--Estrella----------------------------------------------------------------------------
- Tabla de Hechos
CREATE TABLE fact_sales (
	id int primary key,
    sale_month DATE,
    country_id INT,
    store_id INT,
    film_id INT,
    customer_id INT,
    total_amount DECIMAL(10,2),
    rental_count INT,
    FOREIGN KEY (country_id) REFERENCES dim_country(country_id),
    FOREIGN KEY (store_id) REFERENCES dim_store(store_id),
    FOREIGN KEY (film_id) REFERENCES dim_film(film_id),
    FOREIGN KEY (customer_id) REFERENCES dim_customer(customer_id),
    FOREIGN KEY (sale_month) REFERENCES dim_time(id)
);

-- Dimensión Tiempo
CREATE TABLE dim_time (
    id DATE PRIMARY KEY,
    year INT,
    month INT
);

-- Dimensión País (agregando jerarquía implícita, sin hijos adicionales en este caso)
CREATE TABLE dim_country (
    country_id INT PRIMARY KEY,
    country VARCHAR(50)
);

-- Dimensión Tienda (agregando dirección como jerarquía)
CREATE TABLE dim_store (
    store_id INT PRIMARY KEY,
    store_address VARCHAR(100),
    city_id INT,
    FOREIGN KEY (city_id) REFERENCES dim_city(city_id)
);

-- Dimensión Ciudad (nueva dimensión hija de país)
CREATE TABLE dim_city (
    city_id INT PRIMARY KEY,
    city VARCHAR(50),
    country_id INT,
    FOREIGN KEY (country_id) REFERENCES dim_country(country_id)
);

-- Dimensión Película (agregando género y ciudad como jerarquías)
CREATE TABLE dim_film (
    film_id INT PRIMARY KEY,
    title VARCHAR(100),
    rating VARCHAR(10),
    genre_id INT,
    city_id INT,
    FOREIGN KEY (genre_id) REFERENCES dim_genre(genre_id),
    FOREIGN KEY (city_id) REFERENCES dim_city(city_id)
);

-- Dimensión Género (nueva dimensión hija de película)
CREATE TABLE dim_genre (
    genre_id INT PRIMARY KEY,
    genre VARCHAR(50)
);

-- Dimensión Cliente (agregando dirección como jerarquía)
CREATE TABLE dim_customer (
    customer_id INT PRIMARY KEY,
    customer_name VARCHAR(100),
    address_id INT,
    FOREIGN KEY (address_id) REFERENCES dim_address(address_id)
);

-- Dimensión Dirección (nueva dimensión hija de cliente)
CREATE TABLE dim_address (
    address_id INT PRIMARY KEY,
    address VARCHAR(100),
    city_id INT,
    FOREIGN KEY (city_id) REFERENCES dim_city(city_id)
);

-- Cargar datos en las tablas de dimensión
-- Insertar datos en dim_time
INSERT INTO dim_time (id, year, month)
SELECT DISTINCT DATE_TRUNC('month', p.payment_date) AS id, 
       EXTRACT(YEAR FROM p.payment_date) AS year, 
       EXTRACT(MONTH FROM p.payment_date) AS month
FROM payment p
ON CONFLICT (id) DO NOTHING;

-- Insertar datos en dim_country
INSERT INTO dim_country (country_id, country)
SELECT DISTINCT co.country_id, co.country
FROM country co
ON CONFLICT (country_id) DO NOTHING;

-- Insertar datos en dim_city
INSERT INTO dim_city (city_id, city, country_id)
SELECT DISTINCT ci.city_id, ci.city, ci.country_id
FROM city ci
ON CONFLICT (city_id) DO NOTHING;

-- Insertar datos en dim_store
INSERT INTO dim_store (store_id, store_address, city_id)
SELECT DISTINCT s.store_id, a.address || ', ' || ci.city || ', ' || co.country AS store_address, a.city_id
FROM store s
JOIN address a ON s.address_id = a.address_id
JOIN city ci ON a.city_id = ci.city_id
JOIN country co ON ci.country_id = co.country_id
ON CONFLICT (store_id) DO NOTHING;

-- Insertar datos en dim_genre
INSERT INTO dim_genre (genre_id, genre)
SELECT DISTINCT c.category_id, c.name AS genre
FROM category c
ON CONFLICT (genre_id) DO NOTHING;

-- Insertar datos en dim_film
INSERT INTO dim_film (film_id, title, rating, genre_id, city_id)
SELECT DISTINCT f.film_id, f.title, f.rating, fc.category_id, a.city_id
FROM film f
JOIN film_category fc ON f.film_id = fc.film_id
JOIN inventory i ON f.film_id = i.film_id
JOIN store s ON i.store_id = s.store_id
JOIN address a ON s.address_id = a.address_id
ON CONFLICT (film_id) DO NOTHING;

-- Insertar datos en dim_address
INSERT INTO dim_address (address_id, address, city_id)
SELECT DISTINCT a.address_id, a.address, a.city_id
FROM address a
ON CONFLICT (address_id) DO NOTHING;

-- Insertar datos en dim_customer
INSERT INTO dim_customer (customer_id, customer_name, address_id)
SELECT DISTINCT c.customer_id, c.first_name || ' ' || c.last_name AS customer_name, c.address_id
FROM customer c
ON CONFLICT (customer_id) DO NOTHING;

-- Insertar datos en fact_sales
INSERT INTO fact_sales (id, sale_month, country_id, store_id, film_id, customer_id, total_amount, rental_count)
SELECT 
    ROW_NUMBER() OVER (ORDER BY p.payment_id) AS id,
    DATE_TRUNC('month', p.payment_date) AS sale_month,
    co.country_id,
    s.store_id,
    f.film_id,
    c.customer_id,
    p.amount AS total_amount,
    1 AS rental_count
FROM payment p
JOIN customer c ON p.customer_id = c.customer_id
JOIN address a ON c.address_id = a.address_id
JOIN city ci ON a.city_id = ci.city_id
JOIN country co ON ci.country_id = co.country_id
JOIN rental r ON p.rental_id = r.rental_id
JOIN inventory i ON r.inventory_id = i.inventory_id
JOIN film f ON i.film_id = f.film_id
JOIN store s ON i.store_id = s.store_id
ON CONFLICT (id) DO NOTHING;


--Consultas pero a la estrella--
-- total de ventas por país y mes
select 
    dc.country,
    dt.year || '-' || lpad(dt.month::text, 2, '0') as month,
    sum(fs.rental_count) as total_rentals,
    sum(fs.total_amount) as total_sales
from fact_sales fs
inner join dim_country dc on fs.country_id = dc.country_id
inner join dim_time dt on fs.sale_month = dt.id
group by dc.country, dt.year, dt.month
order by dc.country, dt.year, dt.month;

-- películas más rentables por rating
select 
    df.rating,
    df.title,
    sum(fs.total_amount) as total_revenue
from fact_sales fs
inner join dim_film df on fs.film_id = df.film_id
group by df.rating, df.title
order by df.rating, total_revenue desc;

-- ventas promedio por tienda
select 
    ds.store_id,
    avg(fs.total_amount) as avg_sales
from fact_sales fs
inner join dim_store ds on fs.store_id = ds.store_id
group by ds.store_id;

-- ventas totales por género
select 
    dg.genre,
    sum(fs.total_amount) as total_sales
from fact_sales fs
inner join dim_film df on fs.film_id = df.film_id
inner join dim_genre dg on df.genre_id = dg.genre_id
group by dg.genre
order by total_sales desc;

-- promedio de gasto por cliente según tienda, ciudad de la película
select 
    ds.store_id,
    dcit.city,
    dc.customer_id,
    avg(fs.total_amount) as avg_spent
from fact_sales fs
inner join dim_store ds on fs.store_id = ds.store_id
inner join dim_customer dc on fs.customer_id = dc.customer_id
inner join dim_film df on fs.film_id = df.film_id
inner join dim_city dcit on df.city_id = dcit.city_id
group by ds.store_id, dcit.city, dc.customer_id
order by ds.store_id, dcit.city, avg_spent desc;


