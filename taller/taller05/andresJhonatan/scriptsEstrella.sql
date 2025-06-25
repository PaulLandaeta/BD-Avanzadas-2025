-- Dimension 
select distinct 
    date (rental_date) as date_key,
    rental_date,
    EXTRACT(year from  rental_date) as year,
    EXTRACT(month from rental_date) as month,
    EXTRACT(DAY FROM rental_date) as day,
    EXTRACT(QUARTER FROM rental_date) as quarter,
    EXTRACT(DOW FROM rental_date) as day_of_week,
    TO_CHAR(rental_date, 'Month') as month_name,
    TO_CHAR(rental_date, 'Day') as day_name
FROM rental
WHERE rental_date IS NOT NULL
ORDER BY date_key;

-- DIMENSIÓN CLIENTE (DIM_CUSTOMER)
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
    s.store_id as customer_store_id
FROM customer c
JOIN address a ON c.address_id = a.address_id
JOIN city ci ON a.city_id = ci.city_id
JOIN country co ON ci.country_id = co.country_id
JOIN store s ON c.store_id = s.store_id;

-- DIMENSIÓN PELÍCULA (DIM_FILM)
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
    l.name as language_name,
    c.name as category_name
FROM film f
JOIN language l ON f.language_id = l.language_id
LEFT JOIN film_category fc ON f.film_id = fc.film_id
LEFT JOIN category c ON fc.category_id = c.category_id;

-- DIMENSIÓN CATEGORÍA (DIM_CATEGORY)
SELECT 
    category_id,
    name as category_name,
    last_update
FROM category;

-- DIMENSIÓN ACTOR (DIM_ACTOR)
SELECT 
    actor_id,
    first_name,
    last_name,
    CONCAT(first_name, ' ', last_name) as full_name,
    last_update
FROM actor;

-- DIMENSIÓN TIENDA (DIM_STORE)
SELECT 
    s.store_id,
    s.manager_staff_id,
    st.first_name as manager_first_name,
    st.last_name as manager_last_name,
    a.address as store_address,
    a.district as store_district,
    c.city as store_city,
    co.country as store_country
FROM store s
JOIN staff st ON s.manager_staff_id = st.staff_id
JOIN address a ON s.address_id = a.address_id
JOIN city c ON a.city_id = c.city_id
JOIN country co ON c.country_id = co.country_id;

-- DIMENSIÓN UBICACIÓN (DIM_LOCATION)
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
JOIN city c ON a.city_id = c.city_id
JOIN country co ON c.country_id = co.country_id;

-- DIMENSIÓN IDIOMA (DIM_LANGUAGE)
SELECT 
    language_id,
    name as language_name,
    last_update
FROM language;

-- TABLA DE HECHOS - VENTAS (FACT_SALES)
SELECT 
    r.rental_id,
    r.rental_date,
    r.return_date,
    r.customer_id,
    r.inventory_id,
    r.staff_id,
    p.payment_id,
    p.amount as payment_amount,
    p.payment_date,
    i.film_id,
    i.store_id,
    f.rental_rate,
    f.rental_duration,
    CASE 
        WHEN r.return_date IS NOT NULL 
        THEN EXTRACT(EPOCH FROM (r.return_date - r.rental_date))/86400 
        ELSE NULL 
    END as actual_rental_days,
    -- Calculamos si fue devuelto a tiempo
    CASE 
        WHEN r.return_date IS NULL THEN 'Not Returned'
        WHEN EXTRACT(EPOCH FROM (r.return_date - r.rental_date))/86400 <= f.rental_duration THEN 'On Time'
        ELSE 'Late'
    END as return_status
FROM rental r
JOIN payment p ON r.rental_id = p.rental_id
JOIN inventory i ON r.inventory_id = i.inventory_id
JOIN film f ON i.film_id = f.film_id;