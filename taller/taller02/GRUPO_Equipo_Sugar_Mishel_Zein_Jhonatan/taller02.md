# Taller 02
## Registrar alquileres como un SP

Se necesita un operacion centralizada (SP) para registar 
un nuevo alquiler de pelicula.
Crear un SP llamado registrar_alquiler que: 
- Inserte el nuevo registro en la tabla rental
- Paramentros customer_id, inventory_id y staff_id

```
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
```

## Validar y Registrar pagos con transaccion + manejo de error 

Cada pago debe realizarse solo si el monto es positivo y menor a 1000. Se debe encapsular 
esta logica en una transaccion dentro de un SP para que  deshaga automaticamente si ocurre el error.

Crear un SP llamado registrar_pago_seguro que:
- Verifique que el monto es mayor que 0 y menor que 1000
- Inserte en la tabla payment
- Usar Transacciones para el Rollback.
- Tener un ejemplo valido y 2 negativos.

```
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
```

## Automatizar registros con un trigger

El area de seguridad quiere mantener un historial de operaciones sobre los alquileres para fines de auditoria y control 

1.  Crear una tabla rental_log con columnas id, rental_id, action, log_date.
2. Crear un trigger que: 
    - Dispare despues de cada insercion en rental
    - INserte un registro en rental_log

```
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
```

## Crear una funcion para informes de cliente 

El area financiera solicita un reporte que obtenga cuanto ha pagado cada cliente: Este calculo se usara varias veces por lo cual queremos llamarlo como una funcion. 

1. Crear un Funcion llamada total_pagado que: 
   - devuelva el total de pagos (SUM) de ese cliente.
   - Devuelve 0 si no hay registros.
   - parametro de entrada client_id 
2. Ejecutar caso con 0 y uno con monto.
```
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

```

## Diagnotico y optimizacion de ingresos por categoria y cliente.

Marketing necesita generar un reporte que muestre cuanto dinero ha generado cada cliente, por categoria de pelicula considerando solo: 
- alquileres realizados a partir de cierta fecha. 
- Clientes cuyos nombres comienzan con una letra especifica.
- Solo categorias con mas de 5 peliculas disponibles 
- este reporte debe ejecutarse lo mas rapido posible optimice usando indices. 
- Escriba la consulta que muestre nombre completo del cliente, nombre de la categoria, total pagado por ese cliente en peliculas de esa categoria.
- Restricciones incluir datos despues del 2005, solo cliente cuyo last_name empiece con B, solo categorias con mas de 5 peliculas (subconsulta o function)
- Aplicar Explain Anotar los tiempos()
- Crear al menos 2 indices que mejores el plan 
- Aplicar nuevamente Explain y verificar la mejora

### Sin indices

```
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

```
#### Explain Analyze
![alt text](<Imagen de WhatsApp 2025-05-28 a las 15.49.14_afd40e05.jpg>)
![alt text](<Imagen de WhatsApp 2025-05-28 a las 15.49.22_531e2dec.jpg>)

### Optimizacion con Indices
```
create index rental_date ON rental (rental_date);
create index customer_lastname ON customer (last_name);
create index film_category_film_id ON film_category (film_id);
create index film_category_category_id ON film_category (category_id);
```

#### Explain Analyze
![alt text](<Imagen de WhatsApp 2025-05-28 a las 15.51.22_600b0bcd.jpg>)
![alt text](<Imagen de WhatsApp 2025-05-28 a las 15.51.36_7077a827.jpg>)

## Particionamiento 

Los logs creados en ejercicios anteriores provocara una tabla con muchos datos para una mejor consulta 
particionar por fecha dicha tabla para cada año.
```
-- Eliminamos la tabla si es que ya existe
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
```