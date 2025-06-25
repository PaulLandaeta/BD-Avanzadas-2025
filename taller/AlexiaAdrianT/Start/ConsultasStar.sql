SELECT
  dc.country,
  dt.year,
  dt.month_num,
  SUM(fs.amount) AS total_ventas
FROM dw.fact_sales fs
JOIN dw.dim_customer dc ON dc.customer_key = fs.customer_key
JOIN dw.dim_time dt ON dt.time_key = fs.time_key
GROUP BY dc.country, dt.year, dt.month_num
ORDER BY dc.country, dt.year, dt.month_num;


SELECT
  df.rating,
  df.title,
  SUM(fs.amount) AS ingresos
FROM dw.fact_sales fs
JOIN dw.dim_film df ON df.film_key = fs.film_key
GROUP BY df.rating, df.title
ORDER BY df.rating, ingresos DESC;


SELECT
  ds.store_name,
  AVG(fs.amount) AS venta_promedio
FROM dw.fact_sales fs
JOIN dw.dim_store ds ON ds.store_key = fs.store_key
GROUP BY ds.store_name
ORDER BY ds.store_name;


SELECT
  dg.name AS genero,
  SUM(fs.amount) AS total_ventas
FROM dw.fact_sales fs
JOIN dw.bridge_film_genre bfg ON bfg.film_key = fs.film_key
JOIN dw.dim_genre dg ON dg.genre_key = bfg.genre_key
GROUP BY dg.name
ORDER BY total_ventas DESC;


SELECT
  ds.store_name AS tienda,
  ds.city AS ciudad_tienda,
  dc.customer_key AS cliente_id,
  AVG(fs.amount) AS gasto_promedio
FROM dw.fact_sales fs
JOIN dw.dim_store ds ON ds.store_key = fs.store_key
JOIN dw.dim_customer dc ON dc.customer_key = fs.customer_key
GROUP BY ds.store_name, ds.city, dc.customer_key
ORDER BY tienda, ciudad_tienda, cliente_id;
