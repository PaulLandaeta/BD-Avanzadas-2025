# Gestion de fidelizacion de Socios en DVD Rental

## Diseño 
- Realizar una funcion para calcular cuantos gasto un cliente en el ultimo año (dentro de la BD)

CREATE OR REPLACE FUNCTION ultimo_gasto_cliente_anio(p_customer_id INTEGER)
RETURNS INTEGER AS $$
DECLARE 
    ultimo_anio INTEGER;
BEGIN 
    SELECT EXTRACT(YEAR FROM MAX(payment_date)) INTO ultimo_anio
    FROM payment
    WHERE customer_id = p_customer_id;
    
    RETURN ultimo_anio;
END;
$$ LANGUAGE plpgsql;

SELECT ultimo_gasto_cliente_anio(343);

- Crear un SP que active los clientes que hayan realizado un gasto minimo ( valor minimo debe ser ingresado por IN) - Agregar Mensajes dentro del SP para un mejor control


-  Un trigger que audite el cambio de email o de estado de un Customer mostrar el mensaje el valor antiguo y nuevo. Agregar esos datos dentro de un tabla.

CREATE OR REPLACE FUNCTION auditar_cambio_email_state()
RETURNS TRIGGER AS $$
BEGIN
    RAISE NOTICE 'Cliente actualizado: % (ID: %), nuevo email: %, Estado: %', 
        NEW.first_name || ' ' || NEW.last_name, 
        NEW.customer_id, 
        NEW.email,
		NEW active,;
	INSERT INTO auditoria_table (staff_id, first_name, last_name, deleted_at)
	    VALUES (OLD.staff_id, OLD.first_name, OLD.last_name, now());
	    RETURN OLD;
	    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE or replace TRIGGER trg_auditar_email_state
AFTER UPDATE ON customer
FOR EACH ROW
EXECUTE FUNCTION auditar_cambio_email_state();

CREATE TABLE auditoria_table (
    first_name VARCHAR(45),
    customer_id INT(),
    last_name VARCHAR(45),
    email VARCHAR(45),
    active INT()
);

-  Una vista que listo todos los cliente VIP con sus peliculas alquiladas en formato JSON. 


## Entregable 
Diseño de la BD en README dentro del Proyecto 
GRUPO_XYZ_INTEGRANTES_TALLER_1 
SQL
