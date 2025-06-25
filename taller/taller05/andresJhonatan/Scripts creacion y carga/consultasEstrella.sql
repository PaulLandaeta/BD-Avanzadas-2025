
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

-- =====================================================
-- CONSULTAS ADICIONALES DE ANÁLISIS AVANZADO
-- =====================================================

-- 6. ANÁLISIS TEMPORAL: VENTAS POR TRIMESTRE Y AÑO
-- =====================================================
SELECT 
    dt.year,
    dt.quarter,
    CASE dt.quarter
        WHEN 1 THEN 'Q1 (Ene-Mar)'
        WHEN 2 THEN 'Q2 (Abr-Jun)'
        WHEN 3 THEN 'Q3 (Jul-Sep)'
        WHEN 4 THEN 'Q4 (Oct-Dic)'
    END as trimestre_desc,
    SUM(fs.payment_amount) as ventas_totales,
    COUNT(*) as total_transacciones,
    ROUND(AVG(fs.payment_amount), 2) as venta_promedio
FROM dvdrental_dw.fact_sales fs
JOIN dvdrental_dw.dim_time dt ON fs.time_key = dt.time_key
GROUP BY dt.year, dt.quarter
ORDER BY dt.year, dt.quarter;

-- 7. TOP 10 CLIENTES MÁS VALIOSOS
-- =====================================================
SELECT 
    CONCAT(dc.first_name, ' ', dc.last_name) as cliente,
    dc.email,
    dl.city as ciudad_cliente,
    dl.country as pais_cliente,
    SUM(fs.payment_amount) as gasto_total,
    COUNT(*) as total_rentas,
    ROUND(AVG(fs.payment_amount), 2) as gasto_promedio_por_renta,
    MAX(fs.payment_date) as ultima_renta
FROM dvdrental_dw.fact_sales fs
JOIN dvdrental_dw.dim_customer dc ON fs.customer_key = dc.customer_key
JOIN dvdrental_dw.dim_location dl ON fs.location_key = dl.location_key
GROUP BY cliente, dc.email, dl.city, dl.country
ORDER BY gasto_total DESC
LIMIT 10;

-- 8. ANÁLISIS DE RENTABILIDAD POR DURACIÓN DE PELÍCULA
-- =====================================================
SELECT 
    CASE 
        WHEN df.length <= 90 THEN 'Corta (≤90 min)'
        WHEN df.length BETWEEN 91 AND 120 THEN 'Media (91-120 min)'
        WHEN df.length BETWEEN 121 AND 150 THEN 'Larga (121-150 min)'
        ELSE 'Muy Larga (>150 min)'
    END as categoria_duracion,
    COUNT(DISTINCT df.film_id) as total_peliculas,
    SUM(fs.payment_amount) as ingresos_totales,
    COUNT(*) as total_rentas,
    ROUND(AVG(fs.payment_amount), 2) as ingreso_promedio_por_renta,
    ROUND(SUM(fs.payment_amount) / COUNT(DISTINCT df.film_id), 2) as ingreso_promedio_por_pelicula
FROM dvdrental_dw.fact_sales fs
JOIN dvdrental_dw.dim_film df ON fs.film_key = df.film_key
GROUP BY categoria_duracion
ORDER BY ingresos_totales DESC;

-- 9. PERFORMANCE DEL STAFF: VENTAS POR EMPLEADO
-- =====================================================
SELECT 
    CONCAT(dst.first_name, ' ', dst.last_name) as empleado,
    dst.email,
    ds.store_city as ciudad_trabajo,
    SUM(fs.payment_amount) as ventas_totales,
    COUNT(*) as total_transacciones,
    COUNT(DISTINCT fs.customer_key) as clientes_atendidos,
    ROUND(AVG(fs.payment_amount), 2) as venta_promedio_por_transaccion,
    ROUND(SUM(fs.payment_amount) / COUNT(DISTINCT fs.customer_key), 2) as venta_promedio_por_cliente
FROM dvdrental_dw.fact_sales fs
JOIN dvdrental_dw.dim_staff dst ON fs.staff_key = dst.staff_key
JOIN dvdrental_dw.dim_store ds ON fs.store_key = ds.store_key
WHERE dst.active = true
GROUP BY empleado, dst.email, ds.store_city
ORDER BY ventas_totales DESC;

-- 10. ANÁLISIS DE RETENCIÓN: DÍAS PROMEDIO DE RENTA
-- =====================================================
SELECT 
    dc.category_name as genero,
    df.rating,
    COUNT(*) as total_rentas,
    ROUND(AVG(fs.rental_days), 2) as dias_promedio_renta,
    ROUND(AVG(df.rental_duration), 2) as duracion_permitida_promedio,
    ROUND(AVG(CASE WHEN fs.rental_days > df.rental_duration THEN 1 ELSE 0 END) * 100, 2) as porcentaje_rentas_tardias
FROM dvdrental_dw.fact_sales fs
JOIN dvdrental_dw.dim_film df ON fs.film_key = df.film_key
JOIN dvdrental_dw.dim_category dc ON fs.category_key = dc.category_key
WHERE fs.rental_days IS NOT NULL
GROUP BY dc.category_name, df.rating
ORDER BY dias_promedio_renta DESC;