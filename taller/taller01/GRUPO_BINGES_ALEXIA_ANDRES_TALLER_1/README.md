# Gestion de fidelizacion de Socios en DVD Rental

## Diseño 
- Realizar una funcion para calcular cuantos gasto un cliente en el ultimo año (dentro de la BD)
```
create or replace function fn_pagos_por_anio(customer_id_ int)
returns table(year timestamp, amount numeric) as $$
begin
	return query
	select date_trunc('year',p.payment_date) as year, sum(p.amount) as total
	from payment p 
	where p.customer_id = customer_id_
	group by year;
end;
$$ language plpgsql;

select * from fn_pagos_por_anio(1)
```

- Un SP que active un cliente si el minimo gasto y muestre el mensaje ( valor minimo debe ser ingresado por IN)
```
create or replace procedure sp_min_activar (
	minimo in numeric
)
language plpgsql as $$
declare
	c record;
begin	
  FOR c IN 
	select sum(p.amount) as total, p.customer_id
	from payment p
	group by p.customer_id
  LOOP
  IF c.total >= minimo THEN
    RAISE NOTICE 'El cliente % ha sido activado', c.customer_id;
	update customer
	set activebool = true
	where customer_id = c.customer_id;
  END IF;
  END LOOP;
end;
$$;

call sp_min_activar(100)
```

-  Un trigger que audite el cambio de email o de estado de un Customer mostrar el mensaje el valor antiguo y nuevo. Agregar esos datos dentro de un tabla. 
```
create or replace function fn_update_client_log()
returns trigger as $$
begin
	raise notice '% con email antiguo % - nuevo email: %', concat(new.first_name, ' ', new.last_name), old.email, new.email;
	return new;
end;
$$ language plpgsql;


create trigger trg_update_client_log
before update on customer
for each row 
execute function fn_update_client_log();

update customer 
set email = 'alexia@aandres.com'
where customer_id = 1
```

-  Una vista que listo todos los cliente VIP con sus peliculas alquiladas en formato JSON. 
```
create view vip_movie_list as
select concat(c.first_name, ' ',c.last_name) as full_name, sum(p.amount), 
		json_agg(
			json_build_object(
			'film_name',f.title	
			) 
		) as movies
from customer c
inner join rental r on c.customer_id = r.customer_id 
inner join payment p on p.customer_id = r.customer_id
inner join inventory i on i.inventory_id = r.inventory_id
inner join film f on f.film_id = i.film_id
group by c.customer_id
having sum(p.amount) >= 1000

select * from vip_movie_list
```

