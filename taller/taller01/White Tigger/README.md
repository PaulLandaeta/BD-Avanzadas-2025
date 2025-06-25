# Taller 01 equipo White Tigger

integrantes:
- Diego Ledezma
- Miguel Quenta 

---

## Realizar una funcion para calcular cuantos gasto un cliente en el ultimo año (dentro de la BD)

```sql
CREATE OR REPLACE FUNCTION fn_gasto_cliente_ultimo_anno(cliente_id INT)
RETURNS NUMERIC AS $$
declare
	total numeric;
	last_year numeric;
BEGIN
  select extract(year from p.payment_date) into last_year
  from payment p
  group by extract(year from p.payment_date)
  order by extract(year from p.payment_date) desc
  limit 1;
  
  select sum(p.amount) into total
  from customer c
  left join payment p on p.customer_id = c.customer_id 
  where c.customer_id = cliente_id and extract(year from p.payment_date) = last_year
  group by c.customer_id, extract(year from p.payment_date);
  
  return total;
END;
$$ LANGUAGE plpgsql;

select fn_gasto_cliente_ultimo_anno(1);
```

