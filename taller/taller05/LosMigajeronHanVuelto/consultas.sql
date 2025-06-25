
---Consulta uno seprado por meses hasta por anios
SELECT
  dt.year,
  dt.month,
  dc.country,
  SUM(fs.amount) AS total_ventas
FROM fact_sales fs
JOIN dim_time    dt ON fs.payment_date::date = dt.date
JOIN dim_client  dc ON fs.customer_id      = dc.customer_id
GROUP BY dt.year, dt.month, dc.country
ORDER BY dt.year, dt.month, dc.country;


WITH rev_per_film AS (
  SELECT
    dr.rating,
    dr.film_id,
    dr.title,
    SUM(fs.amount) AS ingresos
  FROM fact_sales fs
  JOIN dim_rental dr ON fs.rental_id = dr.rental_id
  GROUP BY dr.rating, dr.film_id, dr.title
),
ranked AS (
  SELECT
    *,
    ROW_NUMBER() OVER (PARTITION BY rating ORDER BY ingresos DESC) AS rn
  FROM rev_per_film
)
SELECT
  rating,
  film_id,
  title,
  ingresos
FROM ranked
WHERE rn = 1
ORDER BY rating;

SELECT
  ds.store_id,
  ds.address,
  ds.city,
  ds.country,
  AVG(fs.amount) AS venta_promedio
FROM fact_sales fs
JOIN dim_store  ds ON fs.store_id = ds.store_id
GROUP BY ds.store_id, ds.address, ds.city, ds.country
ORDER BY ds.store_id;

SELECT
  dg.genre,
  SUM(fs.amount) AS total_ventas
FROM fact_sales   fs
JOIN dim_rental   dr ON fs.rental_id = dr.rental_id
JOIN dim_genre    dg ON dr.film_id    = dg.film_id
GROUP BY dg.genre
ORDER BY total_ventas DESC;


SELECT
  ds.store_id,
  ds.address,
  ds.city   AS tienda_ciudad,
  dc.city   AS cliente_ciudad,
  AVG(fs.amount) AS gasto_promedio
FROM fact_sales fs
JOIN dim_store  ds ON fs.store_id    = ds.store_id
JOIN dim_client dc ON fs.customer_id = dc.customer_id
GROUP BY ds.store_id, ds.address, ds.city, dc.city
ORDER BY ds.store_id, dc.city;