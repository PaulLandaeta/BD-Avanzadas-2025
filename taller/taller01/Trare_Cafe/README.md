# Taller 1

## Nombre del grupo: Trae Café

## Integrantes:
- Wendy Cáceres

## Instrucciones:

### Diseño
1. **Función para calcular el gasto de un cliente**  
   Realizar una función que calcule cuánto gastó un cliente en el último año (dentro de la base de datos).

```sql
-- Ejercicio 1
create or replace function gastp_cliente_anio(p_coustumer_id INT)
returns int as $$
declare gasto_anual int; 
begin
	select SUM(p.amount)
    into gasto_anual
    from customer c
    join payment p
    on c.customer_id = p.customer_id
	where p.payment_date >= CURRENT_DATE - INTERVAL '1 year'
	;

	IF gasto_anual IS NULL THEN
    	gasto_anual := 0;
	END IF;
	return gasto_anual;
end
$$ language plpgsql;

select *
from customer c
join payment p
on c.customer_id = p.customer_id


select gastp_cliente_anio(341);
```

2. **Stored Procedure (SP)**  
   Crear un SP que active los clientes que hayan realizado un gasto mínimo (el valor mínimo debe ser ingresado como parámetro IN).  
   - Incluir mensajes dentro del SP para un mejor control.

```sql
-- Ejercicio 2
CREATE OR REPLACE PROCEDURE activar_clientes_por_gasto_minimo(
    IN p_valor_minimo NUMERIC
)
LANGUAGE plpgsql
AS $$
DECLARE
    r RECORD;
    gasto_total NUMERIC;
BEGIN
    FOR r IN SELECT customer_id FROM customer LOOP
        SELECT COALESCE(SUM(p.amount), 0)
        INTO gasto_total
        FROM payment p
        WHERE p.customer_id = r.customer_id;

        IF gasto_total >= p_valor_minimo THEN
            UPDATE customer
            SET activebool = TRUE
            WHERE customer_id = r.customer_id;
        END IF;
    END LOOP;
END;
$$;
```

3. **Trigger para auditoría**  
   Crear un trigger que audite los cambios en el email o el estado de un cliente (`Customer`).  
   - Mostrar un mensaje con el valor antiguo y el nuevo.  
   - Registrar esos datos en una tabla de auditoría.

```sql
-- Crear tabla
CREATE TABLE audit_custom_log (
    audit_id SERIAL PRIMARY KEY,
    customer_id INT,
    old_email TEXT,
    new_email TEXT,
    old_active INT,  
    new_active INT,
    change_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```
```sql
-- Función del trigger
CREATE OR REPLACE FUNCTION audit_custom_changes() RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO audit_custom_log (customer_id, old_email, new_email, old_active, new_active)
    VALUES (OLD.customer_id, OLD.email, NEW.email, OLD.active, NEW.active);
    IF NEW.email != OLD.email THEN
        RAISE NOTICE 'El email fue cambiado para el cliente %: de % a %', OLD.customer_id, OLD.email, NEW.email;
    END IF;
    IF NEW.activebool != OLD.activebool THEN
        RAISE NOTICE 'El estado fue cambiado para el cliente %: de % a %', OLD.customer_id, OLD.active, NEW.active;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

```

```sql
-- Función del trigger
CREATE TRIGGER audit_custom_trigger
AFTER UPDATE OF email, active ON customer
FOR EACH ROW
EXECUTE FUNCTION audit_custom_changes();

```

```sql
-- Ejemplo
UPDATE customer SET email = 'prueba2@email.com' WHERE customer_id = 10;
UPDATE customer SET active = 0 WHERE customer_id = 10; 

```

```sql
-- Visualizacion
SELECT * 
FROM audit_custom_log;

```

4. **Vista para clientes VIP**  
   Crear una vista que liste todos los clientes VIP junto con sus películas alquiladas en formato JSON.

```sql
-- Ejercicio 4
create view vip_cutomers as
  select c.customer_id, sum(p.amount) from customer c
  inner join payment p on c.customer_id = p.customer_id
  GROUP BY c.customer_id
  having sum(p.amount) > 200

select * 
from vip_cutomers
```
