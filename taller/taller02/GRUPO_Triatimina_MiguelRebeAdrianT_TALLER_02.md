# Ejercicios:
## Registrar alquileres como un SP

```sql
-- Registrar alquileres como un SP
CREATE OR REPLACE PROCEDURE registrar_alquiler(filmTitle varchar)
LANGUAGE plpgsql AS $$
DECLARE tituloID numeric;
BEGIN
    select i.inventory_id into tituloID
    from rental r
    inner join inventory i
    on r.inventory_id = i.inventory_id
    inner join film f
on i.film_id = f.film_id
    where f.title = filmTitle;

    insert into rental (rental_date, inventory_id, customer_id, return_date, staff_id)
    values (now(), tituloID, 6, now(), 1 );
    RAISE NOTICE 'Se insertó el alquiler de la película: %', filmTitle;
END
$$;

CALL registrar_alquiler('Chamber Italian');

--Para verificar que funciona:
select f.title, count(r.rental_date)
from rental r
inner join inventory i
on r.inventory_id = i.inventory_id
inner join film f
on i.film_id = f.film_id
where title = 'Chamber Italian'
group by f.title;

```

## Validar y Registrar pagos con transaccion + manejo de error 

```sql
-- Validar y Registrar pagos con transaccion + manejo de error

create or replace function registrar_pago_seguro(amount NUMERIC)
    RETURNS BOOLEAN AS $$
BEGIN
    RETURN amount > 0 and amount < 1000;
END;
$$ LANGUAGE plpgsql;

BEGIN;
DO $$
    DECLARE
        result BOOLEAN;
        amount NUMERIC := 6.99;
--         amount NUMERIC := -6.99;
--         amount NUMERIC := -10.99;
--         amount NUMERIC := 1002;
    BEGIN
        result := registrar_pago_seguro(amount);

        IF result THEN
            INSERT INTO payment(payment_id, customer_id, staff_id, rental_id, amount, payment_date)
            VALUES (nextval('payment_payment_id_seq'), 237, 1, 8836, amount, now());
            RAISE NOTICE 'Valid amount %. Adding...', amount;
        ELSE
            RAISE NOTICE 'Invalid amount %. Rolling back...', amount;
            ROLLBACK;
            RETURN;
        END IF;
    END;
$$;
COMMIT;
```

## Automatizar registros con un trigger

```sql
--Automatizar registros con un trigger
create table rental_log(
    id serial,
    rental_id int,
    action varchar(6),
    log_date timestamp default current_timestamp
)partition by RANGE(log_date);

create table rental_log_2022 partition of rental_log FOR VALUES FROM ('2022-01-01') to ('2022-12-31');
create table rental_log_2023 partition of rental_log FOR VALUES FROM ('2023-01-01') to ('2023-12-31');
create table rental_log_2024 partition of rental_log FOR VALUES FROM ('2024-01-01') to ('2024-12-31');
create table rental_log_2025 partition of rental_log FOR VALUES FROM ('2025-01-01') to ('2025-12-31');

create or replace function fn_insert_into_rental()
returns trigger as $$
    begin
        insert into rental_log(rental_id, action)
        values(new.rental_id,'create');
        return new;
    end;
$$ language plpgsql;


create trigger trg_rental_insertion
after INSERT ON rental
for each row
execute function fn_insert_into_rental();

-- prueba
insert into rental(rental_date, inventory_id, customer_id, return_date, staff_id, last_update)
values (current_timestamp,1,1,current_timestamp,1,current_timestamp);

select * from rental_log_2025
```

## Crear una funcion para informes de cliente 

```sql
-- Crear una funcion para informes de cliente



create or replace function total_pagado(cliente_id INT)
    returns numeric as $$
declare
    total numeric;
begin
    SELECT SUM(amount) INTO total
    FROM payment p
    inner join customer c
    on p.customer_id = c.customer_id
    WHERE c.customer_id = cliente_id;
    return coalesce(total,0);
end;
$$ language plpgsql;


select total_pagado(1);
select total_pagado(30);
select total_pagado(10000);

```

## Diagnotico y optimizacion de ingresos por categoria y cliente.

```sql
explain analyse
select c.customer_id, sum(p.amount)
from customer c
inner join payment p on c.customer_id = p.customer_id
inner join rental r on p.rental_id = r.rental_id
inner join inventory i on r.inventory_id = i.inventory_id
inner join film f on  i.film_id = f.film_id
inner join film_category fc on f.film_id = fc.film_id
where
    c.first_name like 'B%' and
    c.last_name like 'B%' and
    r.rental_date >= '2025-01-01 00:00:00.000' and
    fc.category_id in (
    select fcs.category_id
    from film_category fcs
     group by fcs.category_id
     having count(fcs.film_id) > 5
    )
group by c.customer_id;
-- Resultados sin indice: Planning 3.785. y Execution 0.226
-- Resultados con indice: Planning 3.643 y Execution 0.180

create index idx_r_date on rental(rental_date);
create index idx_c_first_name on customer(first_name);
create index idx_c_last_name on customer(last_name);

drop index  idx_c_first_name;
drop index  idx_r_date;
drop index  idx_c_last_name

```
Imagen antes:
![Captura de pantalla 2025-05-28 160008](https://github.com/user-attachments/assets/7c22eeb0-3045-4481-8313-1033d7e8f472)


Imagen Después: 

![Captura de pantalla 2025-05-28 155444](https://github.com/user-attachments/assets/7bf7da33-ec92-4e65-b5a6-509355f1c7a2)


## Particionamiento 

```sql
create table rental_log(
    id serial,
    rental_id int,
    action varchar(6),
    log_date timestamp default current_timestamp
)partition by RANGE(log_date);

create table rental_log_2022 partition of rental_log FOR VALUES FROM ('2022-01-01') to ('2022-12-31');
create table rental_log_2023 partition of rental_log FOR VALUES FROM ('2023-01-01') to ('2023-12-31');
create table rental_log_2024 partition of rental_log FOR VALUES FROM ('2024-01-01') to ('2024-12-31');
create table rental_log_2025 partition of rental_log FOR VALUES FROM ('2025-01-01') to ('2025-12-31');

```
