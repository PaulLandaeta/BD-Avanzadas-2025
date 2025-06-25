
-- 1. TOTAL DE VENTAS POR PAÍS Y MES
-- =====================================================
SELECT 
    dl.country,
    dt.year,
    dt.month,
    dt.month_name,
    SUM(fs.payment_amount) as total_ventas,
    COUNT(*) as total_transacciones,
    ROUND(AVG(fs.payment_amount), 2) as venta_promedio
FROM dvdrental_dw.fact_sales fs
JOIN dvdrental_dw.dim_location dl ON fs.location_key = dl.location_key
JOIN dvdrental_dw.dim_time dt ON fs.time_key = dt.time_key
GROUP BY dl.country, dt.year, dt.month, dt.month_name
ORDER BY dl.country, dt.year, dt.month;

-- 2. PELÍCULAS MÁS RENTABLES POR RATING
-- =====================================================
SELECT 
    df.rating,
    SUM(fs.payment_amount) as ingresos_totales,
    COUNT(*) as total_rentas,
    ROUND(AVG(fs.payment_amount), 2) as ingreso_promedio_por_renta,
    ROUND(SUM(fs.payment_amount) / COUNT(DISTINCT df.film_id), 2) as ingreso_promedio_por_pelicula,
    COUNT(DISTINCT df.film_id) as total_peliculas_rating
FROM dvdrental_dw.fact_sales fs
JOIN dvdrental_dw.dim_film df ON fs.film_key = df.film_key
GROUP BY df.rating
ORDER BY ingresos_totales DESC;

-- 3. VENTAS PROMEDIO POR TIENDA
-- =====================================================
SELECT 
    ds.store_id,
    CONCAT(ds.manager_first_name, ' ', ds.manager_last_name) as gerente,
    ds.store_city,
    ds.store_country,
    SUM(fs.payment_amount) as ventas_totales,
    COUNT(*) as total_transacciones,
    ROUND(AVG(fs.payment_amount), 2) as venta_promedio_por_transaccion,
    COUNT(DISTINCT fs.customer_key) as clientes_unicos,
    ROUND(SUM(fs.payment_amount) / COUNT(DISTINCT fs.customer_key), 2) as venta_promedio_por_cliente
FROM dvdrental_dw.fact_sales fs
JOIN dvdrental_dw.dim_store ds ON fs.store_key = ds.store_key
GROUP BY ds.store_id, gerente, ds.store_city, ds.store_country
ORDER BY ventas_totales DESC;

-- 4. VENTAS TOTALES POR GÉNERO (CATEGORÍA)
-- =====================================================
SELECT 
    dc.category_name as genero,
    SUM(fs.payment_amount) as ventas_totales,
    COUNT(*) as total_rentas,
    ROUND(AVG(fs.payment_amount), 2) as venta_promedio,
    COUNT(DISTINCT fs.film_key) as peliculas_diferentes_rentadas,
    COUNT(DISTINCT fs.customer_key) as clientes_unicos,
    ROUND(SUM(fs.payment_amount) / COUNT(DISTINCT fs.film_key), 2) as ingreso_promedio_por_pelicula
FROM dvdrental_dw.fact_sales fs
JOIN dvdrental_dw.dim_category dc ON fs.category_key = dc.category_key
GROUP BY dc.category_name
ORDER BY ventas_totales DESC;

-- 5. PROMEDIO DE GASTO POR CLIENTE SEGÚN TIENDA Y CIUDAD
-- =====================================================
SELECT 
    ds.store_id,
    ds.store_city as ciudad_tienda,
    ds.store_country as pais_tienda,
    CONCAT(ds.manager_first_name, ' ', ds.manager_last_name) as gerente_tienda,
    COUNT(DISTINCT fs.customer_key) as total_clientes,
    SUM(fs.payment_amount) as ventas_totales,
    ROUND(AVG(fs.payment_amount), 2) as gasto_promedio_por_transaccion,
    ROUND(SUM(fs.payment_amount) / COUNT(DISTINCT fs.customer_key), 2) as gasto_promedio_por_cliente,
    ROUND(COUNT(*) / COUNT(DISTINCT fs.customer_key), 2) as transacciones_promedio_por_cliente
FROM dvdrental_dw.fact_sales fs
JOIN dvdrental_dw.dim_store ds ON fs.store_key = ds.store_key
GROUP BY ds.store_id, ds.store_city, ds.store_country, gerente_tienda
ORDER BY gasto_promedio_por_cliente DESC;
