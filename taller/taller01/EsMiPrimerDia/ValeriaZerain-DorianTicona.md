# Valeria Zerain - Dorian Ticona

## Ejercicio 1
![Ejercicio 1](/taller/taller01/EsMiPrimerDia/Ejercicio1.jpg)

```
CREATE OR REPLACE PROCEDURE sp_client_year(
    id_cliente INT
)
LANGUAGE plpgsql AS $$
    DECLARE
    total NUMERIC;
    max_date DATE := '2007-12-31';
    BEGIN
        SELECT SUM(amount)
        INTO total
        FROM payment
        WHERE customer_id = id_cliente
          AND TO_DATE(payment_date::TEXT, 'YYYYMMDD') BETWEEN (max_date - INTERVAL '1 year') AND max_date;

        RAISE NOTICE 'Gasto del ultimo año %', total;
    END;
$$;
```

## Ejercicio 2
![Ejercicio 2](/taller/taller01/EsMiPrimerDia/Ejercicio2.jpg)

```
CREATE OR REPLACE PROCEDURE sp_activar_minimo_gasto(
    monto_minimo NUMERIC
)
LANGUAGE plpgsql AS $$
DECLARE
    customerR RECORD;
BEGIN
    FOR customerR IN
        SELECT p.customer_id
        FROM payment p
        INNER JOIN customer c ON c.customer_id = p.customer_id
        GROUP BY p.customer_id
        HAVING SUM(amount) >= monto_minimo
    LOOP
        RAISE NOTICE 'CUSTOMER %', customerR.customer_id;
        UPDATE customer
        SET activebool = true
        WHERE customer_id = customerR.customer_id;
    END LOOP;
END;
$$;
```

## Ejercicio 3
![Ejercicio 3](/taller/taller01/EsMiPrimerDia/Ejercicio3.jpg)

## Ejercicio 4
![Ejercicio 4](/taller/taller01/EsMiPrimerDia/Ejercicio4.jpg)
