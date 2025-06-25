-- Países clientes
INSERT INTO snowflake.dim_pais_c (nombre)
SELECT DISTINCT co.country
FROM public.customer cu
JOIN public.address a ON a.address_id = cu.address_id
JOIN public.city ci ON ci.city_id = a.city_id
JOIN public.country co ON co.country_id = ci.country_id
ON CONFLICT (nombre) DO NOTHING;

-- Países tienda
INSERT INTO snowflake.dim_s_pais (nombre)
SELECT DISTINCT co.country
FROM public.store st
JOIN public.address a ON a.address_id = st.address_id
JOIN public.city ci ON ci.city_id = a.city_id
JOIN public.country co ON co.country_id = ci.country_id
ON CONFLICT (nombre) DO NOTHING;


-- Ciudades clientes
INSERT INTO snowflake.dim_ciudad_c (nombre, id_pais)
SELECT DISTINCT ci.city, dp.id_pais
FROM public.customer cu
JOIN public.address a ON a.address_id = cu.address_id
JOIN public.city ci ON ci.city_id = a.city_id
JOIN public.country co ON co.country_id = ci.country_id
JOIN snowflake.dim_pais_c dp ON dp.nombre = co.country
ON CONFLICT (nombre) DO NOTHING;

-- Ciudades tienda
INSERT INTO snowflake.dim_s_ciudad (nombre, id_pais)
SELECT DISTINCT ci.city, dp.id_pais
FROM public.store st
JOIN public.address a ON a.address_id = st.address_id
JOIN public.city ci ON ci.city_id = a.city_id
JOIN public.country co ON co.country_id = ci.country_id
JOIN snowflake.dim_s_pais dp ON dp.nombre = co.country
ON CONFLICT (nombre) DO NOTHING;



INSERT INTO snowflake.dim_cliente (id_cliente, first_name, last_name, direccion, id_ciudad)
SELECT
  cu.customer_id,
  cu.first_name,
  cu.last_name,
  a.address,
  dc.id_ciudad
FROM public.customer cu
JOIN public.address a ON a.address_id = cu.address_id
JOIN public.city ci ON ci.city_id = a.city_id
JOIN public.country co ON co.country_id = ci.country_id
JOIN snowflake.dim_ciudad_c dc ON dc.nombre = ci.city
ON CONFLICT (id_cliente) DO NOTHING;


INSERT INTO snowflake.dim_store (id_store, nombre, direccion, id_ciudad)
SELECT
  st.store_id,
  'Store_' || st.store_id,
  a.address,
  ds.id_ciudad
FROM public.store st
JOIN public.address a ON a.address_id = st.address_id
JOIN public.city ci ON ci.city_id = a.city_id
JOIN public.country co ON co.country_id = ci.country_id
JOIN snowflake.dim_s_ciudad ds ON ds.nombre = ci.city
ON CONFLICT (id_store) DO NOTHING;



INSERT INTO snowflake.dim_tiempo (fecha, dia, mes, año, dia_semana)
SELECT DISTINCT
  CAST(p.payment_date AS DATE),
  EXTRACT(DAY FROM p.payment_date)::INT,
  EXTRACT(MONTH FROM p.payment_date)::INT,
  EXTRACT(YEAR FROM p.payment_date)::INT,
  TO_CHAR(p.payment_date, 'Day')
FROM public.payment p
ON CONFLICT (fecha) DO NOTHING;


INSERT INTO snowflake.dim_categoria (nombre, descripcion, genero)
SELECT DISTINCT
  c.name,
  NULL::TEXT,
  c.name  -- Asumo género = nombre categoría
FROM public.category c
ON CONFLICT (nombre) DO NOTHING;


INSERT INTO snowflake.dim_pelicula (id_pelicula, nombre, id_categoria, rating, duracion)
SELECT DISTINCT
  f.film_id,
  f.title,
  dc.id_categoria,
  f.rating,
  f.length
FROM public.film f
JOIN public.film_category fc ON fc.film_id = f.film_id
JOIN snowflake.dim_categoria dc ON dc.nombre = (SELECT name FROM public.category WHERE category_id = fc.category_id LIMIT 1)
ON CONFLICT (id_pelicula) DO NOTHING;


INSERT INTO snowflake.fact_ventas (id_pago, id_cliente, id_tiempo, id_pelicula, id_store, monto_pagado, pel_alquilados)
SELECT
  p.payment_id,
  dc.id_cliente,
  dt.id_tiempo,
  dp.id_pelicula,
  ds.id_store,
  p.amount,
  1
FROM public.payment p
JOIN public.rental r ON r.rental_id = p.rental_id
JOIN public.inventory i ON i.inventory_id = r.inventory_id
JOIN public.store st ON st.store_id = i.store_id
JOIN snowflake.dim_cliente dc ON dc.id_cliente = p.customer_id
JOIN snowflake.dim_tiempo dt ON dt.fecha = CAST(p.payment_date AS DATE)
JOIN snowflake.dim_pelicula dp ON dp.id_pelicula = i.film_id
JOIN snowflake.dim_store ds ON ds.id_store = st.store_id
ON CONFLICT (id_pago) DO NOTHING;

