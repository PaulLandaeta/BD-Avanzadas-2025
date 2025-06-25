-- 1. Total de ventas por país y mes
SELECT 
    co.country,
    EXTRACT(YEAR FROM p.payment_date) as año,
    EXTRACT(MONTH FROM p.payment_date) as mes,
    SUM(p.amount) as total_ventas,
    COUNT(p.payment_id) as total_transacciones
FROM payment p
    JOIN rental r ON p.rental_id = r.rental_id
    JOIN customer c ON r.customer_id = c.customer_id
    JOIN address a ON c.address_id = a.address_id
    JOIN city ci ON a.city_id = ci.city_id
    JOIN country co ON ci.country_id = co.country_id
GROUP BY co.country, EXTRACT(YEAR FROM p.payment_date), EXTRACT(MONTH FROM p.payment_date)
ORDER BY co.country, año, mes;

-- 2. Películas más rentables por rating
SELECT 
    f.rating,
    SUM(p.amount) as ingresos_totales,
    COUNT(r.rental_id) as total_rentas
FROM film f
    JOIN inventory i ON f.film_id = i.film_id
    JOIN rental r ON i.inventory_id = r.inventory_id
    JOIN payment p ON r.rental_id = p.rental_id
GROUP BY f.rating
ORDER BY ingresos_totales DESC;


-- 3. Ventas promedio por tienda
SELECT 
    s.store_id,
    CONCAT(st.first_name, ' ', st.last_name) as encargado,
    COUNT(DISTINCT c.customer_id) as total_clientes,
    SUM(p.amount) as montos_totales,
    ROUND(AVG(p.amount), 2) as monto_promedio_por_transaccion
FROM store s
    JOIN staff st ON s.manager_staff_id = st.staff_id
    JOIN customer c ON s.store_id = c.store_id
    JOIN rental r ON c.customer_id = r.customer_id
    JOIN payment p ON r.rental_id = p.rental_id
GROUP BY s.store_id, st.first_name, st.last_name
ORDER BY s.store_id;

-- 4. Ventas totales por género
SELECT 
    cat.name as genero,
    COUNT(r.rental_id) as total_rentas,
    SUM(p.amount) as montos_totales,
    ROUND(AVG(p.amount), 2) as precio_promedio_renta,
    COUNT(DISTINCT f.film_id) as nro_peliculas_por_genero
FROM category cat
    JOIN film_category fc ON cat.category_id = fc.category_id
    JOIN film f ON fc.film_id = f.film_id
    JOIN inventory i ON f.film_id = i.film_id
    JOIN rental r ON i.inventory_id = r.inventory_id
    JOIN payment p ON r.rental_id = p.rental_id
GROUP BY cat.category_id, cat.name
ORDER BY montos_totales DESC;

-- 5. Promedio de gasto por cliente según tienda y ciudad
SELECT 
    s.store_id,
    ci.city as ciudad_tienda,
    COUNT(DISTINCT c.customer_id) as total_clientes,
    SUM(p.amount) as ventas_totales,
    ROUND(AVG(p.amount), 2) as gasto_promedio_por_transaccion,
    ROUND(SUM(p.amount) / COUNT(DISTINCT c.customer_id), 2) as gasto_promedio_por_cliente
FROM store s
    JOIN address a ON s.address_id = a.address_id
    JOIN city ci ON a.city_id = ci.city_id
    JOIN inventory i ON s.store_id = i.store_id
    JOIN rental r ON i.inventory_id = r.inventory_id
    JOIN customer c ON r.customer_id = c.customer_id
    JOIN payment p ON r.rental_id = p.rental_id
GROUP BY s.store_id, ci.city_id, ci.city
ORDER BY s.store_id, ci.city;
