# Funciones 

## Duración promedio de las películas

## Categoría favorita de un cliente
Devuelve la categoria mas alquilada por un customer_id

## Pagos por cliente y mes
Funcion que reciba un customer_id y devuelva una tabla con mes y total pagado.

## Clientes sin alquiler en los últimos 3 meses
Funcion sin parametros que retorne customer_id nombre de los inactivos.

# Triggers 

## Auditoría de actualización
Crear un trigger que registre cada vez que se actualice un cliente.
Use RAISE NOTICE
Imprima el nombre completo del cliente y su nuevo correo electrónico (NEW.email)

## Log de inserciones de películas
Mostrar mensaje cuando se registre una nueva película.
AFTER INSERT
"Nueva película: [title] fue registrada con rating [rating]"

## Historial de eliminaciones
Al eliminar un staff, insertar una fila en una tabla staff_deleted_log.

Crea una tabla staff_deleted_log con los campos:

staff_id, first_name, last_name, deleted_at

Crea un trigger AFTER DELETE que:

Inserte en staff_deleted_log

Use los valores de OLD



