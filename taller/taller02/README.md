# Taller 02
## Registrar alquileres como un SP

Se necesita un operacion centralizada (SP) para registar 
un nuevo alquiler de pelicula.
Crear un SP llamado registrar_alquiler que: 
- Inserte el nuevo registro en la tabla rental
- Paramentros customer_id, inventory_id y staff_id
```
create or replace procedure create_rental(customer_id_ in numeric, inventory_id_ in numeric, staff_id_ in numeric)
language plpgsql as $$
begin
	insert into rental (rental_date, inventory_id, customer_id, return_date, staff_id, last_update) values (now(), inventory_id_,customer_id_,now(),staff_id_, now());
	
end;

$$;

call create_rental(1,1,1)
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
create or replace procedure check_payment(amount in numeric(5,2))
language plpgsql as $$
begin

		insert into payment (customer_id, staff_id,	rental_id,	amount, payment_date)values (1,1,1,amount, now());
		if amount < 0 or amount > 1000 then
			rollback;
			raise notice 'Payment no creado, el valor debe estar 0 y 1000';
		else 
			
			raise notice 'Payment creado';
			return;
		end if;

    exception
        when SQLSTATE '22003'then
            rollback;
			raise notice 'Payment no creado, el valor debe estar 0 y 1000';

end;
$$;

call check_payment(9999)
call check_payment(999)
call check_payment(99)
```

## Automatizar registros con un trigger

El area de seguridad quiere mantener un historial de operaciones sobre los alquileres para fines de auditoria y control 

1.  Crear una tabla rental_log con columnas id, rental_id, action, log_date.
2. Crear un trigger que: 
    - Dispare despues de cada insercion en rental
    - INserte un registro en rental_log
```
create or replace function fn_log_rental()
returns trigger as $$
begin
	insert into rental_log (rental_id, action, log_date) values(new.rental_id, 'INSERT', now());
	return new;
end;
$$ language plpgsql;


create trigger trg_log_rental;
after insert on rental
for each row
execute function fn_log_rental();
```

## Crear una funcion para informes de cliente 

El area financiera solicita un reporte que obtenga cuanto ha pagado cada cliente: Este calculo se usara varias veces por lo cual queremos llamarlo como una funcion. 

1. Crear un Funcion llamada total_pagado que: 
   - devuelva el total de pagos (SUM) de ese cliente.
   - Devuelve 0 si no hay registros.
   - parametro de entrada client_id 
2. Ejecutar caso con 0 y uno con monto.
```
create or replace function fn_total_pagado(customer_id_ int)
returns table(amount numeric) as $$
begin
	if exists (select 1 from payment where customer_id = customer_id_) then
	return query
	select sum(p.amount) from payment p
	where p.customer_id = customer_id_
	group by p.customer_id;
	else
		return query
        select 0.0 as amount;
	end if;
end;
$$ language plpgsql;



select * from fn_total_pagado(0) 
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
```
explain
select (first_name || ' ' || last_name), ca.name, count(*), sum(p.amount)  from rental r
inner join customer c on r.customer_id = c.customer_id
inner join inventory i on r.inventory_id = i.inventory_id
inner join film f on i.film_id = f.film_id
inner join film_category fc on fc.film_id = f.film_id
inner join category ca on ca.category_id = fc.category_id
inner join payment p on p.customer_id  = c.customer_id
where r.rental_date > '2005-12-31'
and c.last_name like 'B%'
AND ca.category_id IN (
    SELECT category_id
    FROM film_category
    GROUP BY category_id
    HAVING COUNT(film_id) > 5
)
group by (first_name || ' ' || last_name), ca.name 
having count(*) >= 5
order by (first_name || ' ' || last_name)	

CREATE INDEX idx_customer_last_name ON customer(last_name);

CREATE INDEX idx_rental_rental_date ON rental(rental_date);

```

## Particionamiento 

Los logs creados en ejercicios anteriores provocara una tabla con muchos datos para una mejor consulta 
particionar por fecha dicha tabla para cada año. ( 2022- 2023 -2024 - 2025)
```
create table rental_log(id serial, rental_id int, action text, log_date date default now())
partition by range(log_date)

create table rental_log_2025
    partition of rental_log
    for values from ('2025-01-01') to ('2025-12-31');

create table rental_log_2024
    partition of rental_log
    for values from ('2024-01-01') to ('2024-12-31');

create table rental_log_2023
    partition of rental_log
    for values from ('2023-01-01') to ('2023-12-31');

create table rental_log_2025
    partition of rental_log
    for values from ('2025-01-01') to ('2025-12-31');


```



