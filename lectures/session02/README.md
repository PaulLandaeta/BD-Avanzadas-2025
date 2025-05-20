# Stored Procedures en PostgreSQL

Un Stored Procedure (SP) es un bloque de código SQL que se guarda en la base de datos y puede ejecutarse cuando se necesite, ideal para lógica de negocios como actualizaciones masivas, auditorías, u operaciones administrativas.

## Declarar varaibles 

```
DECLARE
  total_pagos NUMERIC;
  nombre_cliente TEXT;
```

## IF/ ELSE/ ELSEIF 

```
CREATE OR REPLACE PROCEDURE sp_evaluar_cliente(
  cliente_id INT
)
LANGUAGE plpgsql AS $$
DECLARE
  total NUMERIC;
BEGIN
  SELECT SUM(amount)
  INTO total
  FROM payment
  WHERE customer_id = cliente_id;

  IF total IS NULL THEN
    RAISE NOTICE 'El cliente no tiene pagos.';
  ELSIF total > 100 THEN
    RAISE NOTICE 'El cliente es Premium 💰';
  ELSE
    RAISE NOTICE 'El cliente es Regular.';
  END IF;
END;
$$;

```

## while  

```
CREATE OR REPLACE PROCEDURE sp_sumar_hasta(
  limite INT
)
LANGUAGE plpgsql AS $$
DECLARE
  i INT := 1;
  suma INT := 0;
BEGIN
  WHILE i <= limite LOOP
    suma := suma + i;
    i := i + 1;
  END LOOP;
  RAISE NOTICE 'La suma es: %', suma;
END;
$$;

-- CALL sp_sumar_hasta(5);  

```

## FOR loop (range-based)
```
CREATE OR REPLACE PROCEDURE sp_mostrar_clientes()
LANGUAGE plpgsql AS $$
DECLARE 
  c RECORD;
BEGIN
  FOR c IN SELECT customer_id, first_name, last_name FROM customer LIMIT 5
  LOOP
    RAISE NOTICE 'Cliente %: % %', c.customer_id, c.first_name, c.last_name;
  END LOOP; 
END;
$$;

```

# Ejercicios
## Activar clientes inactivos de una tienda

```
CREATE OR REPLACE PROCEDURE activar_clientes_con_pago(store_id_input INT)
LANGUAGE plpgsql
AS $$
BEGIN
  UPDATE customer
  SET activebool = true
  WHERE store_id = store_id_input
    AND customer_id IN (
      SELECT DISTINCT p.customer_id
      FROM payment p
      WHERE p.customer_id = customer.customer_id
    );
  
  RAISE NOTICE 'Clientes actualizados correctamente.';
END;
$$;
```

## Ejecutar el Procedimiento 

```
CALL activar_clientes_con_pago(1);
```

## Entrada Simple Mostrar pagos de un cliente

```
CREATE OR REPLACE PROCEDURE sp_listar_pagos_cliente(cliente_id IN INT)
LANGUAGE plpgsql AS $$
BEGIN
  RAISE NOTICE 'Pagos del cliente %:', cliente_id;

  PERFORM amount, payment_date
  FROM payment
  WHERE customer_id = cliente_id;

END;
$$;

CALL sp_listar_pagos_cliente(10);

```

##  Parámetro OUT – Total pagado por un cliente

```
CREATE OR REPLACE PROCEDURE sp_total_pagado_cliente(
  cliente_id IN INT,
  total OUT NUMERIC
)
LANGUAGE plpgsql AS $$
BEGIN
  SELECT SUM(amount)
  INTO total
  FROM payment
  WHERE customer_id = cliente_id;
END;
$$;

-- CALL sp_total_pagado_cliente(10, NULL);
```

##  Parámetro INOUT – Incrementar duración de películas cortas

```
CREATE OR REPLACE PROCEDURE sp_incrementar_duracion(
  INOUT duracion_minima SMALLINT
)
LANGUAGE plpgsql AS $$
BEGIN
  UPDATE film
  SET length = length + 5
  WHERE length < duracion_minima;

  duracion_minima := duracion_minima + 5;
END;
$$;

-- CALL sp_incrementar_duracion(60);

```