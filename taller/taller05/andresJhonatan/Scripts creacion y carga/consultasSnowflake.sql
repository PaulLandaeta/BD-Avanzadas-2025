-- 1. TOTAL DE VENTAS POR PAÍS Y MES
-- =====================================================
SELECT
    dvdrental_snowflake.dim_country.country_name,
    dvdrental_snowflake.dim_time.month_name,
    SUM(dvdrental_snowflake.fact_sales.payment_amount) AS total_ventas
FROM
    dvdrental_snowflake.fact_sales
LEFT JOIN
    dvdrental_snowflake.dim_customer ON dvdrental_snowflake.fact_sales.customer_key = dvdrental_snowflake.dim_customer.customer_key
LEFT JOIN
    dvdrental_snowflake.dim_location ON dvdrental_snowflake.dim_customer.location_key = dvdrental_snowflake.dim_location.location_key
LEFT JOIN
    dvdrental_snowflake.dim_city ON dvdrental_snowflake.dim_location.city_key = dvdrental_snowflake.dim_city.city_key
LEFT JOIN
    dvdrental_snowflake.dim_country ON dvdrental_snowflake.dim_city.country_key = dvdrental_snowflake.dim_country.country_key
LEFT JOIN
    dvdrental_snowflake.dim_time ON dvdrental_snowflake.fact_sales.time_key = dvdrental_snowflake.dim_time.time_key
GROUP BY
    dvdrental_snowflake.dim_country.country_name,
    dvdrental_snowflake.dim_time.month_name
ORDER BY
    dvdrental_snowflake.dim_country.country_name;
-- 2. PELÍCULAS MÁS RENTABLES POR RATING
-- =====================================================
SELECT
    dvdrental_snowflake.dim_film.rating,

    SUM(dvdrental_snowflake.fact_sales.payment_amount) AS total_revenue
FROM
    dvdrental_snowflake.fact_sales
LEFT JOIN
    dvdrental_snowflake.dim_film ON dvdrental_snowflake.fact_sales.film_key = dvdrental_snowflake.dim_film.film_key
GROUP BY
    dvdrental_snowflake.dim_film.rating
ORDER BY
    dvdrental_snowflake.dim_film.rating,
    total_revenue DESC;
    
    

-- 3. VENTAS PROMEDIO POR TIENDA
-- =====================================================
SELECT
    dvdrental_snowflake.dim_store.store_id,
    dvdrental_snowflake.dim_store.manager_first_name,
    dvdrental_snowflake.dim_store.manager_last_name,
    ROUND(AVG(dvdrental_snowflake.fact_sales.payment_amount), 2) AS promedio_ventas
FROM
    dvdrental_snowflake.fact_sales
LEFT JOIN
    dvdrental_snowflake.dim_store ON dvdrental_snowflake.fact_sales.store_key = dvdrental_snowflake.dim_store.store_key
GROUP BY
    dvdrental_snowflake.dim_store.store_id,
    dvdrental_snowflake.dim_store.manager_first_name,
    dvdrental_snowflake.dim_store.manager_last_name
ORDER BY
    promedio_ventas DESC;

-- 4. VENTAS TOTALES POR GÉNERO (CATEGORÍA)
-- =====================================================
SELECT
    dvdrental_snowflake.dim_category.category_name AS genero,
    SUM(dvdrental_snowflake.fact_sales.payment_amount) AS ventas_totales
FROM
    dvdrental_snowflake.fact_sales
LEFT JOIN
    dvdrental_snowflake.dim_film ON dvdrental_snowflake.fact_sales.film_key = dvdrental_snowflake.dim_film.film_key
LEFT JOIN
    dvdrental_snowflake.dim_category ON dvdrental_snowflake.dim_film.category_key = dvdrental_snowflake.dim_category.category_key
GROUP BY
    dvdrental_snowflake.dim_category.category_name
ORDER BY
    ventas_totales DESC;
-- 5. PROMEDIO DE GASTO POR CLIENTE SEGÚN TIENDA Y CIUDAD
-- =====================================================
SELECT
    dvdrental_snowflake.dim_customer.first_name AS customer_first_name,
    dvdrental_snowflake.dim_customer.last_name AS customer_last_name,
    dvdrental_snowflake.dim_store.manager_first_name AS store_manager_first_name,
    dvdrental_snowflake.dim_store.manager_last_name AS store_manager_last_name,
    dvdrental_snowflake.dim_city.city_name AS store_city,
    ROUND(AVG(dvdrental_snowflake.fact_sales.payment_amount), 2) AS promedio_gasto
FROM
    dvdrental_snowflake.fact_sales
LEFT JOIN
    dvdrental_snowflake.dim_customer ON dvdrental_snowflake.fact_sales.customer_key = dvdrental_snowflake.dim_customer.customer_key
LEFT JOIN
    dvdrental_snowflake.dim_store ON dvdrental_snowflake.fact_sales.store_key = dvdrental_snowflake.dim_store.store_key
LEFT JOIN
    dvdrental_snowflake.dim_location ON dvdrental_snowflake.dim_store.location_key = dvdrental_snowflake.dim_location.location_key
LEFT JOIN
    dvdrental_snowflake.dim_city ON dvdrental_snowflake.dim_location.city_key = dvdrental_snowflake.dim_city.city_key
GROUP BY
    dvdrental_snowflake.dim_customer.customer_key,
    dvdrental_snowflake.dim_customer.first_name,
    dvdrental_snowflake.dim_customer.last_name,
    dvdrental_snowflake.dim_store.manager_first_name,
    dvdrental_snowflake.dim_store.manager_last_name,
    dvdrental_snowflake.dim_city.city_name
ORDER BY
    dvdrental_snowflake.dim_customer.first_name,
    dvdrental_snowflake.dim_store.manager_first_name,
    dvdrental_snowflake.dim_city.city_name;