-- 1. Transformar cliente
CREATE OR REPLACE VIEW dim_cliente_vw AS
SELECT 
  c.customer_id,
  LOWER(TRIM(c.email)) AS email,
  INITCAP(TRIM(ci.city)) AS city,
  INITCAP(TRIM(co.country)) AS country
FROM customer c
JOIN address a ON c.address_id = a.address_id
JOIN city ci ON a.city_id = ci.city_id
JOIN country co ON ci.country_id = co.country_id;

-- 2. Transformar película
CREATE OR REPLACE VIEW dim_pelicula_vw AS
SELECT 
  f.film_id,
  f.title,
  f.rating,
  f.length,
  ROUND(f.replacement_cost::numeric, 2) AS replacement_cost
FROM film f;

-- 3. Transformar tiempo
CREATE OR REPLACE VIEW dim_tiempo_vw AS
SELECT DISTINCT 
  DATE(p.payment_date) AS fecha,
  EXTRACT(DAY FROM p.payment_date) AS dia,
  EXTRACT(MONTH FROM p.payment_date) AS mes,
  EXTRACT(YEAR FROM p.payment_date) AS anio,
  EXTRACT(QUARTER FROM p.payment_date) AS trimestre
FROM payment p;

-- 4. Transformar género
CREATE OR REPLACE VIEW dim_genero_vw AS
SELECT DISTINCT
  f.film_id,
  c.name AS genero
FROM film f
JOIN film_category fc ON f.film_id = fc.film_id
JOIN category c ON fc.category_id = c.category_id;

-- 5. Transformar tienda
CREATE OR REPLACE VIEW dim_tienda_vw AS
SELECT 
  s.store_id,
  INITCAP(ci.city) AS city,
  INITCAP(co.country) AS country
FROM store s
JOIN address a ON s.address_id = a.address_id
JOIN city ci ON a.city_id = ci.city_id
JOIN country co ON ci.country_id = co.country_id;

-- 6. Transformar hechos (ventas)
CREATE OR REPLACE VIEW fact_ventas_vw AS
SELECT 
  p.payment_id,
  p.customer_id,
  i.film_id,
  s.store_id,
  DATE(p.payment_date) AS fecha,
  ROUND(p.amount::numeric, 2) AS monto
FROM payment p
JOIN rental r ON p.rental_id = r.rental_id
JOIN inventory i ON r.inventory_id = i.inventory_id
JOIN store s ON i.store_id = s.store_id;
