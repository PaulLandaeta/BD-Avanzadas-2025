INSERT INTO dw.dim_time (full_date, year, month_num, month_name, day)
SELECT DISTINCT
  CAST(payment_date AS DATE)               AS full_date,
  EXTRACT(YEAR FROM payment_date)::SMALLINT  AS year,
  EXTRACT(MONTH FROM payment_date)::SMALLINT AS month_num,
  TO_CHAR(payment_date, 'Mon')             AS month_name,
  EXTRACT(DAY FROM payment_date)::SMALLINT  AS day
FROM public.payment
ON CONFLICT (full_date) DO NOTHING;


INSERT INTO dw.dim_customer (first_name, last_name, email, city, country)
SELECT DISTINCT
  cu.first_name,
  cu.last_name,
  cu.email,
  ci.city,
  co.country
FROM public.customer cu
JOIN public.address a ON a.address_id = cu.address_id
JOIN public.city ci ON ci.city_id = a.city_id
JOIN public.country co ON co.country_id = ci.country_id
ON CONFLICT DO NOTHING;


INSERT INTO dw.dim_store (store_name, address, city, country)
SELECT DISTINCT
  'Store_' || st.store_id,
  a.address,
  ci.city,
  co.country
FROM public.store st
JOIN public.address a ON a.address_id = st.address_id
JOIN public.city ci ON ci.city_id = a.city_id
JOIN public.country co ON co.country_id = ci.country_id
ON CONFLICT DO NOTHING;



INSERT INTO dw.dim_genre (name, description)
SELECT DISTINCT
  name,
  NULL::TEXT
FROM public.category
ON CONFLICT DO NOTHING;

INSERT INTO dw.dim_film (title, release_year, rating, length_min)
SELECT DISTINCT
  f.title,
  f.release_year,
  f.rating,
  f.length
FROM public.film f
ON CONFLICT DO NOTHING;


INSERT INTO dw.fact_sales (
  amount, quantity, customer_key, store_key, film_key, genre_key, time_key
)
SELECT
  p.amount,
  1 AS quantity,
  dc.customer_key,
  ds.store_key,
  df.film_key,
  dg.genre_key,
  dt.time_key
FROM public.payment p
JOIN public.rental r ON r.rental_id = p.rental_id
JOIN public.inventory i ON i.inventory_id = r.inventory_id
JOIN public.store s ON s.store_id = i.store_id
JOIN public.film f ON f.film_id = i.film_id
JOIN public.film_category fc ON fc.film_id = f.film_id
JOIN public.category c ON c.category_id = fc.category_id

JOIN dw.dim_customer dc ON
    dc.first_name = (SELECT first_name FROM public.customer WHERE customer_id = p.customer_id LIMIT 1)
AND dc.last_name = (SELECT last_name FROM public.customer WHERE customer_id = p.customer_id LIMIT 1)

JOIN dw.dim_store ds ON ds.store_name = ('Store_' || s.store_id)
JOIN dw.dim_film df ON df.title = f.title
JOIN dw.dim_genre dg ON dg.name = c.name
JOIN dw.dim_time dt ON dt.full_date = CAST(p.payment_date AS DATE);

