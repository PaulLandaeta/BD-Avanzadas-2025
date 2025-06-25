-- Crear las consultas necesarias para obtener los datos necesarios

SELECT *

FROM payment p

INNER JOIN rental r ON p.rental_id = r.rental_id

INNER JOIN customer c ON p.customer_id = c.customer_id

INNER JOIN staff st ON p.staff_id = st.staff_id

INNER JOIN store s ON st.staff_id = s.manager_staff_id

INNER JOIN address a ON st.address_id = a.address_id

INNER JOIN city ci ON a.city_id = ci.city_id

INNER JOIN country co ON ci.country_id = co.country_id

INNER JOIN inventory i ON r.inventory_id = i.inventory_id

INNER JOIN film f ON i.film_id = f.film_id

INNER JOIN film_category fc ON f.film_id = fc.film_id

INNER JOIN category ct ON fc.category_id = ct.category_id;

--Posteriormente se exporta el resultado en csv
