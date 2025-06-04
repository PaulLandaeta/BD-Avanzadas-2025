# Taller 02

Integrantes:

- Diego Ledezma
  
- Marian Zamorano
  
- Valeria Zerain
  

## Registrar alquileres con un SP

```
CREATE OR REPLACE PROCEDURE sp_registrar_alquiler(
    inventoryId int, customerId int, staffId int
)
    LANGUAGE plpgsql AS $$
    BEGIN
INSERT INTO rental(rental_date, inventory_id, customer_id, staff_id)
VALUES (now(), inventoryId, customerId, staffId);
END;
$$;

Call sp_registrar_alquiler(466, 100, 1);
```

## Validar y registrar transacción + manejo de error

```
Call sp_registrar_alquiler(466, 100, 1);

CREATE OR REPLACE PROCEDURE sp_registrar_pago_seguro(
    monto numeric, customerId int, staffId int, rentalId int
)
LANGUAGE plpgsql AS $$
    BEGIN
        IF monto < 0 THEN
            ROLLBACK;
            RAISE EXCEPTION 'El monto es negativo, solo se debe poner montos positivos';
        ELSIF monto > 1000 THEN
            ROLLBACK ;
            RAISE EXCEPTION 'El monto es mayor a 1000';
        ELSE
            insert into payment(customer_id, staff_id, rental_id, amount, payment_date)
    values (customerId,staffId,rentalId,monto,now());
        end if;
    END;
$$;

CALL sp_registrar_pago_seguro(1001, 100,1,1600);

CALL sp_registrar_pago_seguro(200, 100,1,1600);

CALL sp_registrar_pago_seguro(-100, 100,1,1600);
```

## Automatizar registros con un trigger

```
CREATE TABLE rental_log (
    id SERIAL PRIMARY KEY,
    rental_id INT,
    action VARCHAR(10),
    log_date TIMESTAMP
);

CREATE OR REPLACE FUNCTION log_rental_insert()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO rental_log (rental_id, action, log_date)
    VALUES (NEW.rental_id, 'insert', now());
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_log_rental_insert
AFTER INSERT ON rental
FOR EACH ROW
EXECUTE FUNCTION log_rental_insert();

INSERT INTO rental (rental_date, inventory_id, customer_id, staff_id, last_update)
VALUES (NOW(), 466, 100, 1, NOW());

INSERT INTO rental (rental_date, inventory_id, customer_id, staff_id, last_update)
VALUES (NOW(), 285, 312, 2, NOW());

INSERT INTO rental (rental_date, inventory_id, customer_id, staff_id, last_update)
VALUES (NOW(), 336, 105, 1, NOW());

INSERT INTO rental (rental_date, inventory_id, customer_id, staff_id, last_update)
VALUES (NOW(), 846, 160, 2, NOW());

INSERT INTO rental (rental_date, inventory_id, customer_id, staff_id, last_update)
VALUES (NOW(), 589, 175, 1, NOW());

SELECT * FROM rental_log
ORDER BY id DESC;
```

## Crear una función para informes

```
create or replace function total_pagado(client_id INT)
returns DECIMAL as $$
begin
    return COALESCE((
        select SUM(amount)
        from payment
        where customer_id = client_id
    ), 0);
end;
$$ language plpgsql;

select total_pagado(845684680);

select total_pagado(69);
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

create index idx_customer_first_name on customer(first_name);

create index idx_rental_rental_date on rental(rental_date);
```
### Costo antes
![image](https://github.com/user-attachments/assets/4aeb0357-637e-490c-9f30-1b3ce6b1e2f8)

### Costo despues
![image](https://github.com/user-attachments/assets/41456f47-0ce2-47e7-901c-aac9dd16ef98)

## Particionamiento
```
DROP TABLE IF EXISTS rental_log;

CREATE TABLE rental_log (
    id INT,
    rental_id INT,
    action VARCHAR(10),
    log_date TIMESTAMP
) PARTITION BY RANGE (log_date);


CREATE TABLE rental_log_2022 PARTITION OF rental_log
    FOR VALUES FROM ('2022-01-01') TO ('2023-01-01');

CREATE TABLE rental_log_2023 PARTITION OF rental_log
    FOR VALUES FROM ('2023-01-01') TO ('2024-01-01');

CREATE TABLE rental_log_2024 PARTITION OF rental_log
    FOR VALUES FROM ('2024-01-01') TO ('2025-01-01');

CREATE TABLE rental_log_2025 PARTITION OF rental_log
    FOR VALUES FROM ('2025-01-01') TO ('2026-01-01');


INSERT INTO rental_log (id,rental_id, action, log_date)
VALUES (1,101, 'INSERT', '2022-07-15');


INSERT INTO rental_log (id,rental_id, action, log_date)
VALUES (2,102, 'UPDATE', '2023-03-10');


INSERT INTO rental_log (id,rental_id, action, log_date)
VALUES (3,103, 'DELETE', '2024-11-05');


INSERT INTO rental_log (id,rental_id, action, log_date)
VALUES (4,104, 'INSERT', '2025-01-20');

select * from rental_log_2022;
select * from rental_log_2023;
select * from rental_log_2024;
select * from rental_log_2025;
```
