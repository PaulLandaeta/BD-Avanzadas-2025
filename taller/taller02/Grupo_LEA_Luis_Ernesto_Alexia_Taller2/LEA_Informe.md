# Taller 02
## Registrar alquileres como un SP
CREATE OR REPLACE PROCEDURE registrar_alquiler(
    IN p_customer_id INT,
    IN p_inventory_id INT,
    IN p_staff_id INT
)
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO rental (rental_date, inventory_id, customer_id, staff_id)
    VALUES (NOW(), p_inventory_id, p_customer_id, p_staff_id);
END;
$$;

CALL registrar_alquiler(1, 3, 2);

## Validar y Registrar pagos con transaccion + manejo de error 

CREATE OR REPLACE PROCEDURE registrar_pago_seguro(
    IN p_customer_id INT,
    IN p_staff_id INT,
    IN p_rental_id INT,
    IN p_amount NUMERIC(5,2)
)
LANGUAGE plpgsql
AS $$
BEGIN
    IF p_amount <= 0 OR p_amount >= 1000 THEN
        RAISE EXCEPTION 'Monto inválido. Debe ser mayor que 0 y menor que 1000';
    END IF;

    BEGIN 
        INSERT INTO payment (customer_id, staff_id, rental_id, amount, payment_date)
        VALUES (p_customer_id, p_staff_id, p_rental_id, p_amount, NOW());
    EXCEPTION
        WHEN OTHERS THEN
            RAISE EXCEPTION 'Error al registrar el pago. Se hizo rollback: %', SQLERRM;
    Commit;
	end;
END;
$$;

CALL registrar_pago_seguro(1, 2, 16057, 100.15);

CALL registrar_pago_seguro(1, 2, 16050, -10.00);

CALL registrar_pago_seguro(1, 2, 16050, 1234.56);

## Automatizar registros con un trigger

CREATE TABLE rental_log (
    id serial,
    rental_id numeric,
    action VARCHAR(50),
    log_date date
) PARTITION BY RANGE (log_date);

create or replace function log_rental_action() 
returns trigger AS $$
BEGIN
    INSERT INTO rental_log (rental_id, action, log_date)
    VALUES (NEW.rental_id, 'INSERT', CURRENT_TIMESTAMP);
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER tgr_log_rental_action_1
After insert ON rental
FOR EACH ROW
EXECUTE FUNCTION log_rental_action();

## Crear una funcion para informes de cliente 

CREATE OR REPLACE FUNCTION total_pagado(client_id INT)
RETURNS NUMERIC AS $$
DECLARE
    total NUMERIC;
BEGIN
    SELECT SUM(p.amount)
    INTO total
    FROM payment p
    JOIN rental r ON p.rental_id = r.rental_id
    WHERE r.customer_id = client_id;

    RETURN COALESCE(total, 0);
END;
$$ LANGUAGE plpgsql;


SELECT total_pagado(1);

## Diagnotico y optimizacion de ingresos por categoria y cliente.

EXPLAIN ANALYZE
SELECT 
    c.first_name || ' ' || c.last_name AS customer_name,
    cat.name AS category_name,
    SUM(p.amount) AS total_paid
FROM 
    customer c
    JOIN rental r ON c.customer_id = r.customer_id
    JOIN payment p ON r.rental_id = p.rental_id
    JOIN inventory i ON r.inventory_id = i.inventory_id
    JOIN film f ON i.film_id = f.film_id
    JOIN film_category fc ON f.film_id = fc.film_id
    JOIN category cat ON fc.category_id = cat.category_id
WHERE 
    r.rental_date >= '2005-01-01'
    AND c.last_name LIKE 'B%'
    AND cat.category_id IN (
        SELECT category_id 
        FROM film_category 
        GROUP BY category_id 
        HAVING COUNT(*) > 5
    )
GROUP BY 
    c.customer_id, c.first_name, c.last_name, cat.category_id, cat.name
ORDER BY 
    customer_name, category_name;
   
create index idx_last_name_1 on customer(last_name);
create index idx_rental_date on  rental(rental_date);
create index idx_category_film on film_category(category_id);

## Particionamiento 

CREATE TABLE rental_log_2022 PARTITION OF rental_log
FOR VALUES FROM ('2022-01-01') TO ('2023-01-01');

CREATE TABLE rental_log_2023 PARTITION OF rental_log
FOR VALUES FROM ('2023-01-01') TO ('2024-01-01');

CREATE TABLE rental_log_2024 PARTITION OF rental_log
FOR VALUES FROM ('2024-01-01') TO ('2025-01-01');

CREATE TABLE rental_log_2025 PARTITION OF rental_log
FOR VALUES FROM ('2025-01-01') TO ('2026-01-01');

select *
from rental_log_2025