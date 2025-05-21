# Funciones 
## Función simple: total pagado por un cliente
```
CREATE OR REPLACE FUNCTION fn_total_pagado(cliente_id INT)
RETURNS NUMERIC AS $$
DECLARE
  total NUMERIC;
BEGIN
  SELECT SUM(amount) INTO total
  FROM payment
  WHERE customer_id = cliente_id;

  RETURN COALESCE(total, 0);
END;
$$ LANGUAGE plpgsql;
``` 

## Listar Pagos de un cliente 

```
CREATE OR REPLACE FUNCTION fn_listar_pagos(cliente_id INT)
RETURNS TABLE(pago NUMERIC, fecha TIMESTAMP) AS $$
BEGIN
  RETURN QUERY
  SELECT amount, payment_date
  FROM payment
  WHERE customer_id = cliente_id;
END;
$$ LANGUAGE plpgsql;
```

# Triggers 

## Estructura General 

```
CREATE TRIGGER nombre_trigger
{ BEFORE | AFTER } { INSERT | UPDATE | DELETE }
ON nombre_tabla
FOR EACH ROW
EXECUTE FUNCTION nombre_funcion_trigger();
```

## Trigger que actualiza automáticamente la fecha

```
CREATE OR REPLACE FUNCTION fn_actualizar_fecha()
RETURNS trigger AS $$
BEGIN
  NEW.last_update := CURRENT_TIMESTAMP;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;
```

```
CREATE TRIGGER trg_update_timestamp
BEFORE UPDATE ON actor
FOR EACH ROW
EXECUTE FUNCTION fn_actualizar_fecha();
```