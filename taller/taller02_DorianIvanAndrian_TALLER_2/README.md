# Taller 02
## Registrar alquileres como un SP

Se necesita un operacion centralizada (SP) para registar 
un nuevo alquiler de pelicula.
Crear un SP llamado registrar_alquiler que: 
- Inserte el nuevo registro en la tabla rental
- Paramentros customer_id, inventory_id y staff_id

### Solucion

``` sql

CREATE OR REPLACE PROCEDURE registrar_alquiler(
    IN p_customer_id   INTEGER,
    IN p_inventory_id  INTEGER,
    IN p_staff_id      INTEGER
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
    )
    VALUES (
        NOW(),
        p_inventory_id,
        p_customer_id,
        p_staff_id,
        NOW()
    );
END;
$$;


CALL registrar_alquiler(427,129,1);


SELECT *
FROM rental
ORDER BY rental_id DESC
LIMIT 5;

```    
## Validar y Registrar pagos con transaccion + manejo de error 

Cada pago debe realizarse solo si el monto es positivo y menor a 1000. Se debe encapsular 
esta logica en una transaccion dentro de un SP para que  deshaga automaticamente si ocurre el error.

Crear un SP llamado registrar_pago_seguro que:
- Verifique que el monto es mayor que 0 y menor que 1000
- Inserte en la tabla payment
- Usar Transacciones para el Rollback.
- Tener un ejemplo valido y 2 negativos.

``` sql

CREATE OR REPLACE PROCEDURE registrar_pago_seguro(
  IN p_customer_id INTEGER,
  IN p_staff_id    INTEGER,
  IN p_rental_id   INTEGER,
  IN p_amount      NUMERIC,
  IN p_payment_date TIMESTAMP DEFAULT NOW()
)
LANGUAGE plpgsql
AS $$
BEGIN
  BEGIN
    IF p_amount <= 0 OR p_amount >= 1000 THEN
      RAISE EXCEPTION 'Monto inválido (debe ser > 0 y < 1000): %', p_amount;
    END IF;
    INSERT INTO payment (
      customer_id,
      staff_id,
      rental_id,
      amount,
      payment_date
    ) VALUES (
      p_customer_id,
      p_staff_id,
      p_rental_id,
      p_amount,
      p_payment_date
    );

  EXCEPTION WHEN OTHERS THEN
    ROLLBACK;
    RAISE;
  END;
END;
$$;

-- aqui funciona
CALL registrar_pago_seguro(42,2,101,150.00,'2007-05-28 14:00');

-- aqui no
CALL registrar_pago_seguro(42,1,101,-10.00,'2007-05-28 14:10');

-- aqui tampoco
CALL registrar_pago_seguro(42,1,101,1500.00,'2007-05-28 14:20');


```
## Automatizar registros con un trigger

El area de seguridad quiere mantener un historial de operaciones sobre los alquileres para fines de auditoria y control 

1.  Crear una tabla rental_log con columnas id, rental_id, action, log_date.
2. Crear un trigger que: 
    - Dispare despues de cada insercion en rental
    - INserte un registro en rental_log

### Solucion

``` sql

CREATE TABLE rental_log(
	id SERIAL PRIMARY KEY,
	rental_id INT,
	action TEXT,
	log_date TIMESTAMP
);

CREATE OR REPLACE FUNCTION log_rental_insert()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO rental_log(rental_id, ACTION, log_date)
  VALUES (NEW.rental_id, 'INSERT', CURRENT_TIMESTAMP);
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER after_rental_insert
AFTER INSERT ON rental
FOR EACH ROW
EXECUTE FUNCTION log_rental_insert();

CALL registrar_alquiler(1, 5, 1);  


SELECT * FROM rental_log ORDER BY id DESC;

```

## Crear una funcion para informes de cliente 

El area financiera solicita un reporte que obtenga cuanto ha pagado cada cliente: Este calculo se usara varias veces por lo cual queremos llamarlo como una funcion. 

1. Crear un Funcion llamada total_pagado que: 
   - devuelva el total de pagos (SUM) de ese cliente.
   - Devuelve 0 si no hay registros.
   - parametro de entrada client_id 
2. Ejecutar caso con 0 y uno con monto.

### Solucion

``` sql
CREATE OR REPLACE FUNCTION total_pagado(p_customer_id INTEGER)
RETURNS NUMERIC
LANGUAGE plpgsql
AS $$
DECLARE
    v_total NUMERIC := 0;
BEGIN
    SELECT COALESCE(SUM(amount), 0)
    INTO v_total
    FROM payment
    WHERE customer_id = p_customer_id;
    
    RETURN v_total;
END;
$$;

SELECT total_pagado(999);
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

``` sql

EXPLAIN ANALYSE
SELECT 
  c.first_name || ' ' || c.last_name AS cliente,
  cat.name AS categoria,
  SUM(p.amount) AS total_pagado
FROM customer c
INNER JOIN rental r ON c.customer_id = r.customer_id
INNER JOIN payment p ON p.rental_id = r.rental_id
INNER JOIN inventory i ON r.inventory_id = i.inventory_id
INNER JOIN film f ON i.film_id = f.film_id
INNER JOIN film_category fc ON f.film_id = fc.film_id
INNER JOIN category cat ON fc.category_id = cat.category_id
WHERE 
  r.rental_date >= '2005-01-01'
  AND c.last_name LIKE 'B%'
  AND fc.category_id IN (
    SELECT category_id
    FROM film_category
    GROUP BY category_id
    HAVING COUNT(film_id) > 5
  )
GROUP BY c.first_name, c.last_name, cat.name
ORDER BY total_pagado DESC;

CREATE INDEX idx_customer_last_name ON customer(last_name);
CREATE INDEX idx_rental_date ON rental(rental_date);
CREATE INDEX idx_category_name ON category(name);
CREATE INDEX idx_film_category_category_id ON film_category(category_id);
CREATE INDEX idx_inventory_film_id ON inventory(film_id);
CREATE INDEX idx_payment_customer_id ON payment(customer_id);

```

## Particionamiento 

Los logs creados en ejercicios anteriores provocara una tabla con muchos datos para una mejor consulta 
particionar por fecha dicha tabla para cada año.

```sql


-- Ejercicio 5
EXPLAIN ANALYSE
SELECT 
  c.first_name || ' ' || c.last_name AS cliente,
  cat.name AS categoria,
  SUM(p.amount) AS total_pagado
FROM customer c
INNER JOIN rental r ON c.customer_id = r.customer_id
INNER JOIN payment p ON p.rental_id = r.rental_id
INNER JOIN inventory i ON r.inventory_id = i.inventory_id
INNER JOIN film f ON i.film_id = f.film_id
INNER JOIN film_category fc ON f.film_id = fc.film_id
INNER JOIN category cat ON fc.category_id = cat.category_id
WHERE 
  r.rental_date >= '2005-01-01'
  AND c.last_name LIKE 'B%'
  AND fc.category_id IN (
    SELECT category_id
    FROM film_category
    GROUP BY category_id
    HAVING COUNT(film_id) > 5
  )
GROUP BY c.first_name, c.last_name, cat.name
ORDER BY total_pagado DESC;

CREATE INDEX idx_customer_last_name ON customer(last_name);
CREATE INDEX idx_rental_date ON rental(rental_date);
CREATE INDEX idx_category_name ON category(name);
CREATE INDEX idx_film_category_category_id ON film_category(category_id);
CREATE INDEX idx_inventory_film_id ON inventory(film_id);
CREATE INDEX idx_payment_customer_id ON payment(customer_id);


```
