-- EJERCICIO 1

CREATE OR REPLACE PROCEDURE registrar_alquiler(
    IN p_customer_id INT,
    IN p_inventory_id INT,
    IN p_staff_id INT
)
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO rental (
        rental_date,
        inventory_id,
        customer_id,
        staff_id,
        last_update
    ) VALUES (
        NOW(),           
        p_inventory_id,
        p_customer_id,
        p_staff_id,
        NOW()           
    );
    
    RAISE NOTICE 'Aquiler registrado customer_id=%', p_customer_id;
END;
$$;

call registrar_alquiler (15,54,2);

-- EJERCICIO 2
CREATE OR REPLACE PROCEDURE registrar_pago_seguro(
    IN monto NUMERIC
)
LANGUAGE plpgsql AS $$
BEGIN
    IF monto > 0 AND monto < 1000 THEN 
		insert into payment(customer_id,staff_id,rental_id,amount,payment_date)
		values(341,1,1778,monto,now());
    ELSE
		raise notice 'Se hara un rollback';
		rollback;
    END IF;
END;
$$;

-- Este funciona
call registrar_pago_seguro(100);

-- Este no funciona (menor a 0)
call registrar_pago_seguro(-100);

-- Este no funciona (mayor a 1000)
call registrar_pago_seguro(1000);

-- EJERCICIO 3
create table rental_log (
    id serial,
    rental_id integer,
    action VARCHAR(45),
    log_date DATE
)

select * from rental_log

create or replace function log_rental_actions()
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
EXECUTE FUNCTION log_rental_actions();

insert into rental (
    rental_date, inventory_id, customer_id, return_date, staff_id
) values (
    now(), 1, 1, now(), 1
);

select * from rental_log;

-- EJERCICIO 4

create or replace function total_pagado( p_customer_id INT)
returns numeric as $$ 
declare
	total numeric; 
begin 
SELECT SUM(amount) INTO total
  FROM payment p 
  WHERE customer_id = p_customer_id;
  RETURN COALESCE(total, 0);
return total; 
END;
$$ LANGUAGE plpgsql;

select total_pagado (0);

-- EJERCICIO 5
explain analyse
select
  c.first_name || ' ' || c.last_name as cliente, cat.name as categoria, sum(p.amount) as total_pagado
from payment p
join rental r on p.rental_id = r.rental_id
join inventory i on r.inventory_id = i.inventory_id
join film f on i.film_id = f.film_id
join film_category fc on f.film_id = fc.film_id
join category cat on fc.category_id = cat.category_id
join customer c on p.customer_id = c.customer_id
where r.rental_date > '2005-01-01'
  and c.last_name like 'B%'
  and cat.category_id in(
    select fc.category_id
    from film_category fc
    group by fc.category_id
    having count(distinct fc.film_id) > 5
  )
group by cliente, categoria
order by cliente, categoria;

create index rental_date ON rental (rental_date);
create index customer_lastname ON customer (last_name);
create index film_category_film_id ON film_category (film_id);
create index film_category_category_id ON film_category (category_id);

-- EJERCICIO 6
drop table rental_log;
create table rental_log (
    id serial,
    rental_id integer,
    action VARCHAR(45),
    log_date DATE
) partition by range (log_date);

create table rental_log_2025 partition of rental_log
for values from ('2025-01-01') to ('2025-12-31');

create table rental_log_2024 partition of rental_log
for values from ('2024-01-01') to ('2024-12-31');

create table rental_log_2023 partition of rental_log
for values from ('2023-01-01') to ('2023-12-31');

-- Vamos a insertar logs a las tablas 2024 y 2023 para poner a prueba las particiones

insert into rental_log (
        rental_id, action, log_date
) VALUES (
    1,
    'Insert',
    '2023-03-05'
);

insert into rental_log (
        rental_id, action, log_date
) VALUES (
    2,
    'Insert',
    '2024-03-05'
);

select * from rental_log_2025;
select * from rental_log_2024;
select * from rental_log_2023;
select * from rental_log;