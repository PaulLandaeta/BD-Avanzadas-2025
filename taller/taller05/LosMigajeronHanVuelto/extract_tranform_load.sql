SELECT 
    c.country AS pais,
    EXTRACT(MONTH FROM p.payment_date) AS mes,
    SUM(p.amount) AS ventas_totales
FROM payment p
JOIN customer cu ON p.customer_id = cu.customer_id
JOIN address a ON cu.address_id = a.address_id
JOIN city ci ON a.city_id = ci.city_id
JOIN country c ON ci.country_id = c.country_id
GROUP BY c.country, mes;

-- Hecho Ventas y Rental

SELECT
    p.payment_id,
    p.amount,
    p.payment_date,
    r.rental_id,
    r.customer_id,
    r.inventory_id,
    r.staff_id,
    i.store_id,
   	i.film_id
FROM payment p
JOIN rental r ON p.rental_id = r.rental_id
JOIN inventory i ON r.inventory_id = i.inventory_id;

-- Dim Cliente
SELECT
    c.customer_id,
    c.first_name,
    c.last_name,
    c.email,
    a.address,
    a.district,
    ci.city,
    co.country,
    c.active,
    c.create_date
FROM customer c
JOIN address a ON c.address_id = a.address_id
JOIN city ci ON a.city_id = ci.city_id
JOIN country co ON ci.country_id = co.country_id;

-- Dim Tienda
SELECT
    s.store_id,
    a.address,
    ci.city,
    co.country
FROM store s
JOIN address a ON s.address_id = a.address_id
JOIN city ci ON a.city_id = ci.city_id
JOIN country co ON ci.country_id = co.country_id;

-- Dim Tiempo
SELECT DISTINCT
    payment_date::date AS date,
    EXTRACT(year FROM payment_date) AS year,
    EXTRACT(month FROM payment_date) AS month,
    EXTRACT(day FROM payment_date) AS day,
    EXTRACT(quarter FROM payment_date) AS quarter,
    TO_CHAR(payment_date, 'Month') AS month_name
FROM payment;

-- Dim 
SELECT
    f.film_id,
    f.title,
    f.release_year,
    f.rental_duration,
    f.rental_rate,
    f.length,
    f.replacement_cost,
    f.rating,
    f.special_features,
    l.name AS language
FROM film f
JOIN language l ON f.language_id = l.language_id;


-- Dim genero
SELECT
    fc.film_id,
    c.name AS genre
FROM film_category fc
JOIN category c ON fc.category_id = c.category_id;

	
	-- Hecho Ventas y Rental
	
	SELECT
	    p.payment_id,
	    p.amount,
	    p.payment_date,
	    r.rental_id,
	    r.customer_id,
	    r.inventory_id,
	    r.staff_id,
	    i.store_id,
	   	i.film_id
	FROM payment p
	JOIN rental r ON p.rental_id = r.rental_id
	JOIN inventory i ON r.inventory_id = i.inventory_id;
	
	-- Dim Cliente
	SELECT
	    c.customer_id,
	    c.first_name,
	    c.last_name,
	    c.email,
	    a.address,
	    a.district,
	    ci.city,
	    co.country,
	    c.active,
	    c.create_date
	FROM customer c
	JOIN address a ON c.address_id = a.address_id
	JOIN city ci ON a.city_id = ci.city_id
	JOIN country co ON ci.country_id = co.country_id;
	
	-- Dim Tienda
	SELECT
	    s.store_id,
	    a.address,
	    ci.city,
	    co.country
	FROM store s
	JOIN address a ON s.address_id = a.address_id
	JOIN city ci ON a.city_id = ci.city_id
	JOIN country co ON ci.country_id = co.country_id;
	
	-- Dim Tiempo
	SELECT DISTINCT
	    payment_date::date AS date,
	    EXTRACT(year FROM payment_date) AS year,
	    EXTRACT(month FROM payment_date) AS month,
	    EXTRACT(day FROM payment_date) AS day,
	    EXTRACT(quarter FROM payment_date) AS quarter,
	    TO_CHAR(payment_date, 'Month') AS month_name
	FROM payment;
	
	-- Dim rental
	SELECT
	    f.film_id,
	    f.title,
	    f.release_year,
	    f.rental_duration,
	    f.rental_rate,
	    f.length,
	    f.replacement_cost,
	    f.rating,
	    f.special_features,
	    l.name AS language,
	    r.rental_id,
	    r.rental_date,
	    r.return_date
	FROM film f
	JOIN language l ON f.language_id = l.language_id
	inner join inventory i on i.film_id = f.film_id
	inner join rental r on r.inventory_id = i.inventory_id;
	
	-- Dim genero
	SELECT
	    fc.film_id,
	    c.name AS genre
	FROM film_category fc
	JOIN category c ON fc.category_id = c.category_id;

-- Transform
SELECT * FROM payment WHERE amount <= 0;

-- Cargado
-- 1) fact_sales
DROP TABLE IF EXISTS fact_sales;
CREATE TABLE fact_sales AS
SELECT
    p.payment_id,
    p.amount,
    p.payment_date,
    r.rental_id,
    r.customer_id,
    r.inventory_id,
    r.staff_id,
    i.store_id,
    i.film_id
FROM payment p
JOIN rental   r ON p.rental_id   = r.rental_id
JOIN inventory i ON r.inventory_id = i.inventory_id;

-- 2) dim_client
DROP TABLE IF EXISTS dim_client;
CREATE TABLE dim_client AS
SELECT
    c.customer_id,
    c.first_name,
    c.last_name,
    c.email,
    a.address,
    a.district,
    ci.city,
    co.country,
    c.active,
    c.create_date
FROM customer c
JOIN address a  ON c.address_id = a.address_id
JOIN city    ci ON a.city_id    = ci.city_id
JOIN country co ON ci.country_id = co.country_id;

-- 3) dim_store
DROP TABLE IF EXISTS dim_store;
CREATE TABLE dim_store AS
SELECT
    s.store_id,
    a.address,
    ci.city,
    co.country
FROM store s
JOIN address a  ON s.address_id = a.address_id
JOIN city    ci ON a.city_id    = ci.city_id
JOIN country co ON ci.country_id = co.country_id;

-- 4) dim_time
DROP TABLE IF EXISTS dim_time;
CREATE TABLE dim_time AS
SELECT DISTINCT
    payment_date::date    AS date,
    EXTRACT(year    FROM payment_date) AS year,
    EXTRACT(month   FROM payment_date) AS month,
    EXTRACT(day     FROM payment_date) AS day,
    EXTRACT(quarter FROM payment_date) AS quarter,
    TO_CHAR(payment_date, 'Month')    AS month_name
FROM payment;

-- 5) dim_rental
DROP TABLE IF EXISTS dim_rental;
CREATE TABLE dim_rental AS
SELECT
    f.film_id,
    f.title,
    f.release_year,
    f.rental_duration,
    f.rental_rate,
    f.length,
    f.replacement_cost,
    f.rating,
    f.special_features,
    l.name       AS language,
    r.rental_id,
    r.rental_date,
    r.return_date
FROM film f
JOIN language  l ON f.language_id  = l.language_id
JOIN inventory i ON i.film_id     = f.film_id
JOIN rental    r ON r.inventory_id = i.inventory_id;

-- 6) dim_genre
DROP TABLE IF EXISTS dim_genre;
CREATE TABLE dim_genre AS
SELECT
    fc.film_id,
    c.name AS genre
FROM film_category fc
JOIN category      c ON fc.category_id = c.category_id;
-- ------------------------

create table dim_film as
 SELECT
    f.film_id,
    f.title,
    f.release_year,
    f.rental_duration,
    f.rental_rate,
    f.length,
    f.replacement_cost,
    f.rating,
    f.special_features,
    l.name AS language
FROM film f
JOIN language l ON f.language_id = l.language_id;

-- Aqui solo normalizamos film para genero y para rental
