-- Consultas
-- Total de ventas por pais y mes
-- peliculas mas rentables por rating
-- Ventas promedio por tienda
-- Ventas totales por género
-- Promedio de gasto por cliente segun tienda, ciudad de la pelicula


/*Total de ventas por país y mes */
SELECT dc.country,dt.year,dt.month_num, SUM(fs.amount) AS total_ventas
FROM fact_sales fs
JOIN dim_customer dc ON dc.customer_key = fs.customer_key
JOIN dim_time dt ON dt.time_key = fs.time_key
GROUP BY dc.country, dt.year, dt.month_num
ORDER BY dc.country, dt.year, dt.month_num;


/*Películas más rentables por rating */
SELECT df.rating,df.title,SUM(fs.amount) AS ingresos
FROM fact_sales fs
JOIN dim_film df ON df.film_key = fs.film_key
GROUP BY df.rating, df.title
ORDER BY df.rating, ingresos DESC;


/*Ventas promedio por tienda */
SELECT ds.store_name,AVG(fs.amount) AS venta_promedio
FROM fact_sales fs
JOIN dim_store ds ON ds.store_key = fs.store_key
GROUP BY ds.store_name
ORDER BY ds.store_name;


/*Ventas totales por género */
SELECT dg.name AS genero, SUM(fs.amount) AS total_ventas
FROM fact_sales fs
JOIN bridge_film_genre bfg ON bfg.film_key = fs.film_key
JOIN dim_genre dg ON dg.genre_key = bfg.genre_key
GROUP BY dg.name
ORDER BY total_ventas DESC;


/*Promedio de gasto por cliente segun tienda y ciudad de la tienda */
SELECT ds.store_name AS tienda,ds.city AS ciudad_tienda,dc.customer_nk AS cliente_id,AVG(fs.amount) AS gasto_promedio
FROM fact_sales fs
JOIN dim_store ds ON ds.store_key = fs.store_key
JOIN dim_customer dc ON dc.customer_key = fs.customer_key
GROUP BY ds.store_name, ds.city, dc.customer_nk
ORDER BY tienda, ciudad_tienda, cliente_id;

