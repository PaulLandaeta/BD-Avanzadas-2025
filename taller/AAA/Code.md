--EJERCICIO 1
CREATE OR REPLACE FUNCTION calcular_gasto_anual(cliente_id INT)
RETURNS NUMERIC AS $$
DECLARE
  total NUMERIC;
BEGIN
  SELECT COALESCE(SUM(p.amount), 0) INTO total
  FROM payment p
  WHERE p.customer_id = cliente_id;

  RETURN total;
END;
$$ LANGUAGE plpgsql;
select calcular_gasto_anual(1);


-- EJERCICIO 2
CREATE OR REPLACE PROCEDURE sp_activar_cliente_si_gasto_minimo(
  cliente_id INT,
  gasto_minimo NUMERIC
)
LANGUAGE plpgsql AS $$
DECLARE
  total_gasto NUMERIC := 0;
BEGIN
  -- Calcular gasto total del cliente
  SELECT COALESCE(SUM(amount), 0)
  INTO total_gasto
  FROM payment
  WHERE customer_id = cliente_id;

  -- Verificar si alcanza el mínimo
  IF total_gasto >= gasto_minimo THEN
    UPDATE customer
    SET activebool = true
    WHERE customer_id = cliente_id;

    RAISE NOTICE 'Cliente % activado. Gasto total: %', cliente_id, total_gasto;
  ELSE
    RAISE NOTICE 'Cliente % NO activado. Gasto total: %, mínimo requerido: %',
      cliente_id, total_gasto, gasto_minimo;
  END IF;
END;
$$;
CALL sp_activar_cliente_si_gasto_minimo(8, 150);

--EJERCICIO 4


CREATE OR REPLACE VIEW vista_clientes_vip_json AS
SELECT 
  c.customer_id,
  json_build_object(
    'nombre', c.first_name || ' ' || c.last_name,
    'email', c.email,
    'peliculas_alquiladas', (
      SELECT json_agg(f.title)
      FROM rental r
     INNER JOIN inventory i ON r.inventory_id = i.inventory_id
     inner JOIN film f ON i.film_id = f.film_id
      WHERE r.customer_id = c.customer_id
    )
  ) AS datos_vip
FROM customer c
WHERE (
  SELECT COUNT(*) 
  FROM rental r 
  WHERE r.customer_id = c.customer_id
) > 20;

select * 
from vista_clientes_vip_json;