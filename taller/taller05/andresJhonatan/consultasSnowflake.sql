-- 1. Total de ventas por país y mes
SELECT 
    co.country_name,
    t.year,
    t.month,
    t.month_name,
    SUM(f.payment_amount) AS total_ventas
FROM dvdrental_snowflake.fact_sales f
JOIN dvdrental_snowflake.dim_time t ON f.time_key = t.time_key
JOIN dvdrental_snowflake.dim_location l ON f.location_key = l.location_key
JOIN dvdrental_snowflake.dim_city ci ON l.city_key = ci.city_key
JOIN dvdrental_snowflake.dim_country co ON ci.country_key = co.country_key
GROUP BY co.country_name, t.year, t.month, t.month_name
ORDER BY co.country_name, t.year, t.month;

-- 2. Películas más rentables por rating
SELECT 
    fi.rating,
    fi.title,
    SUM(f.payment_amount) AS total_ingresos,
    COUNT(f.rental_id) AS total_rentas,
    ROUND(SUM(f.payment_amount) / COUNT(f.rental_id), 2) AS ingreso_promedio_por_renta
FROM dvdrental_snowflake.fact_sales f
JOIN dvdrental_snowflake.dim_film fi ON f.film_key = fi.film_key
GROUP BY fi.rating, fi.title
ORDER BY fi.rating, total_ingresos DESC;

-- 3. Ventas promedio por tienda
SELECT 
    s.store_id,
    s.manager_first_name,
    s.manager_last_name,
    COUNT(f.rental_id) AS total_transacciones,
    SUM(f.payment_amount) AS total_ventas,
    ROUND(AVG(f.payment_amount), 2) AS venta_promedio_por_transaccion,
    ROUND(SUM(f.payment_amount) / COUNT(DISTINCT f.customer_key), 2) AS venta_promedio_por_cliente
FROM dvdrental_snowflake.fact_sales f
JOIN dvdrental_snowflake.dim_store s ON f.store_key = s.store_key
GROUP BY s.store_id, s.manager_first_name, s.manager_last_name
ORDER BY total_ventas DESC;

-- 4. Ventas totales por género
SELECT 
    ca.category_name AS genero,
    COUNT(f.rental_id) AS total_rentas,
    SUM(f.payment_amount) AS total_ventas,
    ROUND(AVG(f.payment_amount), 2) AS venta_promedio,
    ROUND(SUM(f.payment_amount) * 100.0 / (
        SELECT SUM(payment_amount) FROM dvdrental_snowflake.fact_sales
    ), 2) AS porcentaje_total_ventas
FROM dvdrental_snowflake.fact_sales f
JOIN dvdrental_snowflake.dim_film fi ON f.film_key = fi.film_key
JOIN dvdrental_snowflake.dim_category ca ON fi.category_key = ca.category_key
GROUP BY ca.category_name
ORDER BY total_ventas DESC;

-- 5. Promedio de gasto por cliente según tienda y ciudad
SELECT 
    s.store_id,
    ci.city_name,
    co.country_name,
    COUNT(DISTINCT f.customer_key) AS total_clientes,
    COUNT(f.rental_id) AS total_transacciones,
    SUM(f.payment_amount) AS total_ventas,
    ROUND(AVG(f.payment_amount), 2) AS gasto_promedio_por_transaccion,
    ROUND(SUM(f.payment_amount) / COUNT(DISTINCT f.customer_key), 2) AS gasto_promedio_por_cliente
FROM dvdrental_snowflake.fact_sales f
JOIN dvdrental_snowflake.dim_store s ON f.store_key = s.store_key
JOIN dvdrental_snowflake.dim_location l ON s.location_key = l.location_key
JOIN dvdrental_snowflake.dim_city ci ON l.city_key = ci.city_key
JOIN dvdrental_snowflake.dim_country co ON ci.country_key = co.country_key
GROUP BY s.store_id, ci.city_name, co.country_name
ORDER BY s.store_id, gasto_promedio_por_cliente DESC;
