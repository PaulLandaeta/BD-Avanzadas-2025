-- Dimension 
SELECT DISTINCT
    DATE(rental_date) AS date_key,
    rental_date,
    EXTRACT(YEAR FROM rental_date) AS year,
    EXTRACT(MONTH FROM rental_date) AS month,
    EXTRACT(DAY FROM rental_date) AS day,
    EXTRACT(QUARTER FROM rental_date) AS quarter,
    EXTRACT(DOW FROM rental_date) AS day_of_week,
    TO_CHAR(rental_date, 'Month') AS month_name,
    TO_CHAR(rental_date, 'Day') AS day_name
FROM rental
WHERE rental_date IS NOT NULL
ORDER BY rental_date;

-- DIMENSIÓN CLIENTE
SELECT 
    c.customer_id,
    c.first_name,
    c.last_name,
    c.email,
    c.active,
    c.create_date,
    a.address,
    a.district,
    ci.city,
    co.country,
    s.store_id AS customer_store_id
FROM customer c
JOIN store s ON c.store_id = s.store_id
JOIN address a ON s.address_id = a.address_id
JOIN city ci ON a.city_id = ci.city_id
JOIN country co ON ci.country_id = co.country_id;

-- DIMENSIÓN PELÍCULA
SELECT 
    f.film_id,
    f.title,
    f.description,
    f.release_year,
    f.rental_duration,
    f.rental_rate,
    f.length,
    f.replacement_cost,
    f.rating,
    f.special_features,
    l.name AS language_name,
    c.name AS category_name
FROM film f
LEFT JOIN film_category fc ON fc.film_id = f.film_id
LEFT JOIN category c ON c.category_id = fc.category_id
JOIN language l ON f.language_id = l.language_id;

-- DIMENSIÓN CATEGORÍA
SELECT 
    category_id,
    name AS category_name,
    last_update
FROM category
WHERE category_id IN (SELECT category_id FROM film_category)
ORDER BY last_update;

-- DIMENSIÓN ACTOR
SELECT 
    actor_id,
    first_name,
    last_name,
    CONCAT(first_name, ' ', last_name) AS full_name,
    last_update
FROM actor
WHERE actor_id IN (SELECT actor_id FROM film_actor)
ORDER BY last_update;

-- DIMENSIÓN TIENDA 
SELECT 
    s.store_id,
    s.manager_staff_id,
    st.first_name AS manager_first_name,
    st.last_name AS manager_last_name,
    a.address AS store_address,
    a.district AS store_district,
    c.city AS store_city,
    co.country AS store_country
FROM store s
JOIN country co ON s.store_id IN (SELECT store_id FROM inventory WHERE address_id IN (SELECT address_id FROM address WHERE country_id = co.country_id))
JOIN city c ON c.country_id = co.country_id
JOIN address a ON a.city_id = c.city_id
JOIN staff st ON s.manager_staff_id = st.staff_id;

-- DIMENSIÓN UBICACIÓN
SELECT 
    a.address_id,
    a.address,
    a.address2,
    a.district,
    a.postal_code,
    a.phone,
    c.city,
    co.country,
    a.last_update
FROM address a
JOIN country co ON a.address_id IN (SELECT address_id FROM customer WHERE address_id IN (SELECT address_id FROM address WHERE country_id = co.country_id))
JOIN city c ON c.country_id = co.country_id;

-- DIMENSIÓN IDIOMA
SELECT 
    language_id,
    name AS language_name,
    last_update
FROM language
WHERE language_id IN (SELECT language_id FROM film)
ORDER BY last_update;

-- TABLA DE HECHOS 
SELECT 
    r.rental_id,
    r.rental_date,
    r.return_date,
    r.customer_id,
    r.inventory_id,
    r.staff_id,
    p.payment_id,
    p.amount AS payment_amount,
    p.payment_date,
    i.film_id,
    i.store_id,
    f.rental_rate,
    f.rental_duration,
    CASE 
        WHEN r.return_date IS NOT NULL THEN FLOOR((EXTRACT(EPOCH FROM r.return_date - r.rental_date) / 86400)::NUMERIC) 
        ELSE NULL 
    END AS actual_rental_days,
    CASE 
        WHEN r.return_date IS NULL THEN 'Not Returned'
        WHEN FLOOR((EXTRACT(EPOCH FROM r.return_date - r.rental_date) / 86400)::NUMERIC) <= f.rental_duration THEN 'On Time'
        ELSE 'Late'
    END AS return_status
FROM rental r
JOIN inventory i ON r.inventory_id = i.inventory_id
JOIN film f ON i.film_id = f.film_id
JOIN payment p ON p.rental_id = r.rental_id;