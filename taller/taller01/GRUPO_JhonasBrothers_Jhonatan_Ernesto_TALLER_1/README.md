--Taller 1
--Ejercicio 1
create or replace function count_client(id_client int)
returns int as $$
declare
	total int;
begin
	select sum(p.amount) into total
	from payment p
	inner join customer c on c.customer_id = p.customer_id
	where p.customer_id = id_client and p.payment_date >= '2006-01-10'::DATE and p.payment_date <= '2007-05-21'::DATE;
	return total;
end;
$$ language plpgsql;

select count_client(2);
--Ejercicio 2
create or replace procedure activate_clients(
	in gasto_minimo numeric
)
language plpgsql as $$
declare customerR RECORD;
begin
	for customerR in 
		select sum(p.amount) as totalGasto,  c.first_name, c.customer_id from customer c 
		inner join payment p on p.customer_id = c.customer_id
		group by p.customer_id, c.first_name
	loop
		raise notice 'Customer %: total gasto %', customerR.first_name, customerR.total_gasto;
	if customerR.total_gasto >= gasto_minimo then
            UPDATE customer 
            SET activebool = true
            WHERE customer_id = customerR.customer_id;
    end if;
	end loop;
end;
$$;

call activate_clients(300);
-- Ejercicio 3


