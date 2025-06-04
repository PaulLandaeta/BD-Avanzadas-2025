# Realizar una funcion para calcular cuantos gasto un cliente en el ultimo año (dentro de la BD)
```
CREATE OR REPLACE FUNCTION gasto_ultimo_anhio(custId integer)
RETURNS TABLE(year NUMERIC, total NUMERIC) AS $$
BEGIN
    RETURN QUERY
    select EXTRACT(YEAR FROM p.payment_date), sum(p.amount)
    from payment p
    where p.customer_id = custId
    group by EXTRACT(YEAR FROM p.payment_date)
    order by year desc
    limit '1';
END;
$$ LANGUAGE plpgsql;

select gasto_ultimo_anhio(6);
```
![Captura de pantalla 2025-05-21 163650](https://github.com/user-attachments/assets/b4664ceb-f03c-48a5-bd89-432b16d1b554)


# Un SP que active un cliente si el minimo gasto y muestre el mensaje ( valor minimo debe ser ingresado por IN)
```
CREATE OR REPLACE PROCEDURE activate_client_and_show(
    IN gastoMin integer)
LANGUAGE plpgsql AS $$
DECLARE
  suma NUMERIC;
BEGIN
    select sum(p.amount) into suma
    from customer c
    inner join payment p
    on c.customer_id=p.customer_id;
    IF c.active = false and suma = gastoMin then
        update customer set active = 1;
    ELSE
        RAISE NOTICE 'No cumple';
    END IF;
END
$$;
```

![Captura de pantalla 2025-05-21 164322](https://github.com/user-attachments/assets/6634580c-6e8a-46e6-ae96-2ede0eaed07a)


# Un trigger que audite el cambio de email o de estado de un Customer mostrar el mensaje el valor antiguo y nuevo. Agregar esos datos dentro de un tabla. 
# Una vista que listo todos los cliente VIP con sus peliculas alquiladas en formato JSON. 
```
---3
CREATE TABLE IF NOT EXISTS customer_audit (
  audit_id SERIAL PRIMARY KEY,
  customer_id INT,
  field_changed TEXT,
  old_value TEXT,
  new_value TEXT,
  changed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);


CREATE OR REPLACE FUNCTION audit_customer_changes()
RETURNS TRIGGER AS $$
BEGIN
  IF NEW.email IS DISTINCT FROM OLD.email THEN
    INSERT INTO customer_audit (customer_id, field_changed, old_value, new_value)
    VALUES (OLD.customer_id, 'email', OLD.email, NEW.email);

    RAISE NOTICE 'Email: A %', OLD.email, NEW.email;
  END IF;

  IF NEW.active IS DISTINCT FROM OLD.active THEN
    INSERT INTO customer_audit (customer_id, field_changed, old_value, new_value)
    VALUES (OLD.customer_id, 'active', OLD.active::TEXT, NEW.active::TEXT);

    RAISE NOTICE 'EActivo: De % A %', OLD.active, NEW.active;
  END IF;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;
 
CREATE or replace TRIGGER trg_audit_customer_changes
AFTER UPDATE ON customer
FOR EACH ROW
EXECUTE FUNCTION audit_customer_changes();


UPDATE customer SET email = 'rebe@email.com', active = false 
WHERE customer_id = 1;
SELECT * 
FROM customer_audit;




---4
CREATE OR REPLACE VIEW vista_clientes_vip_peliculas AS
SELECT
  c.customer_id,
  c.first_name || ' ' || c.last_name AS nombre_completo,
  json_agg(DISTINCT f.title) AS peliculas_alquiladas
FROM customer c
JOIN rental r ON c.customer_id = r.customer_id
JOIN inventory i ON r.inventory_id = i.inventory_id
JOIN film f ON i.film_id = f.film_id
WHERE c.customer_id IN (
  SELECT customer_id
  FROM payment
  WHERE payment_date >= CURRENT_DATE - INTERVAL '1 year'
  GROUP BY customer_id
  HAVING SUM(amount) > 200
)
GROUP BY c.customer_id, nombre_completo;


SELECT * FROM vista_clientes_vip_peliculas;
```

![Captura de pantalla 2025-05-21 164912](https://github.com/user-attachments/assets/015e0d9b-1306-4e48-aa41-2d9d1329b65d)
