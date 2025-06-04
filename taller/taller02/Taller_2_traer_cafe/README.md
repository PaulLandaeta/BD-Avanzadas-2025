# Taller 02 Traer Cafe

Integrante:

- Wendy Cáceres


## Registrar alquileres con un SP

```
CREATE OR REPLACE PROCEDURE registrar_alquiler(
    p_customer_id INT,
    p_inventory_id INT,
    p_staff_id INT
)
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO rental (rental_date, inventory_id, customer_id, return_date, staff_id, last_update)
    VALUES (NOW(), p_inventory_id, p_customer_id, NULL, p_staff_id, NOW());

    RAISE NOTICE 'Alquiler registrado exitosamente para el cliente %.', p_customer_id;
END;
$$;

```

```
call registrar_alquiler (11,05,15);

```

## Validar y registrar transacción + manejo de error

```
CREATE OR REPLACE PROCEDURE registrar_pago_seguro(
    p_payment_id INT,
    p_customer_id INT,
    p_staff_id INT,
    p_rental_id INT,
    p_amount NUMERIC,
    p_payment_date TIMESTAMP
)
LANGUAGE plpgsql
AS $$
BEGIN
    BEGIN
        IF p_amount <= 0 OR p_amount >= 1000 THEN
            RAISE EXCEPTION 'El monto debe ser mayor que 0 y menor que 1000.';
        END IF;
        INSERT INTO payment (payment_id, customer_id, staff_id, rental_id, amount, payment_date)
        VALUES (p_payment_id, p_customer_id, p_staff_id, p_rental_id, p_amount, p_payment_date);
        RAISE NOTICE 'Pago registrado exitosamente por %.', p_amount;
    EXCEPTION
        WHEN OTHERS THEN
            RAISE NOTICE 'Se hará rollback: %', SQLERRM;
            ROLLBACK;
    END;
END;
$$;

CALL registrar_pago_seguro(1000, 1, 1, 1, 9.99, '2025-05-28 15:00:00');
CALL registrar_pago_seguro(1001, 1, 1, 1, -5.00, '2025-05-28 15:00:00');
CALL registrar_pago_seguro(1002, 1, 1, 1, 1500.00, '2025-05-28 15:00:00');
```

## Automatizar registros con un trigger

```
create table rental_log (
    id serial,
    rental_id integer,
    action VARCHAR(45),
    log_date DATE
)
select * 
from rental_log

create or replace function log_rental_action()
returns trigger as $$
BEGIN
    insert into rental_log (
        rental_id, action, log_date
    ) VALUES (
        NEW.rental_id,
        'Insert',
        now()
    );
    return new;
END;
$$ LANGUAGE plpgsql;


CREATE or replace TRIGGER trg_log_rental
AFTER insert ON rental
FOR EACH ROW
EXECUTE FUNCTION log_rental_action();
insert into rental (
    rental_date, inventory_id, customer_id, return_date, staff_id
) values (
    now(), 1, 1, now(), 1
);

select * 
from rental_log;
```

## Crear una función para informes

```
create or replace function pago_total(client_id INT)
returns DECIMAL as $$
begin
    return COALESCE((
        select SUM(amount)
        from payment
        where customer_id = client_id
    ), 0);
end;
$$ language plpgsql;
select pago_total(110515);
select pago_total(2);
```

## Diagnotico y optimizacion de ingresos por categoria y cliente

```
explain analyze 
select
    c.first_name,
    c.last_name,
    cat.name,
    sum(p.amount) as total_pagado
from customer c
join rental r on c.customer_id = r.customer_id
join payment p on r.rental_id = p.rental_id
join inventory i on r.inventory_id = i.inventory_id
join film f on i.film_id = f.film_id
join film_category fc on f.film_id = fc.film_id
join category cat on fc.category_id = cat.category_id
where 
    r.rental_date > '2005-12-31'
    and c.first_name like 'D%'
    and cat.category_id in (
        select  fc2.category_id
        from film_category fc2
        group by fc2.category_id
        having count(fc2.film_id) > 5
    )
group by c.customer_id, c.first_name, c.last_name, cat.category_id, cat.name
order by total_pagado desc;

create index idx_customer_first_namee on customer(first_name);
create index idx_rental_rental_datee on rental(rental_date);
```
## Antes
C:\Users\Moxcr\OneDrive\Documentos\BaseDeDts\BD-Avanzadas-2026\taller\taller02\Taller_2_traer_cafe\antes.png

## Despues
C:\Users\Moxcr\OneDrive\Documentos\BaseDeDts\BD-Avanzadas-2026\taller\taller02\Taller_2_traer_cafe\despues.png

## Particionamiento
```
DROP TABLE IF EXISTS rental_log CASCADE;
CREATE SEQUENCE rental_log_seq START 1;
CREATE TABLE rental_log (
    rental_id INT NOT NULL,
    action VARCHAR(10),
    log_date TIMESTAMP NOT NULL,
    id INT DEFAULT nextval('rental_log_seq')
) PARTITION BY RANGE (log_date);
CREATE TABLE rental_log_y2022 PARTITION OF rental_log
    FOR VALUES FROM ('2022-01-01') TO ('2023-01-01');
CREATE TABLE rental_log_y2023 PARTITION OF rental_log
    FOR VALUES FROM ('2023-01-01') TO ('2024-01-01');
CREATE TABLE rental_log_y2024 PARTITION OF rental_log
    FOR VALUES FROM ('2024-01-01') TO ('2025-01-01');
CREATE TABLE rental_log_y2025 PARTITION OF rental_log
    FOR VALUES FROM ('2025-01-01') TO ('2026-01-01');
INSERT INTO rental_log (rental_id, action, log_date) VALUES
    (101, 'INSERT', '2022-07-15'),
    (102, 'UPDATE', '2023-03-10'),
    (103, 'DELETE', '2024-11-05'),
    (104, 'INSERT', '2025-01-20');
SELECT * FROM rental_log_y2022
SELECT * FROM rental_log_y2023
SELECT * FROM rental_log_y2024
SELECT * FROM rental_log_y2025;
```