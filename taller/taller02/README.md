# Taller 02
## Registrar alquileres como un SP

Se necesita un operacion centralizada (SP) para registar 
un nuevo alquiler de pelicula.
Crear un SP llamado registrar_alquiler que: 
- Inserte el nuevo registro en la tabla rental
- Paramentros customer_id, inventory_id y staff_id

## Validar y Registrar pagos con transaccion + manejo de error 

Cada pago debe realizarse solo si el monto es positivo y menor a 1000. Se debe encapsular 
esta logica en una transaccion dentro de un SP para que  deshaga automaticamente si ocurre el error.

Crear un SP llamado registrar_pago_seguro que:
- Verifique que el monto es mayor que 0 y menor que 1000
- Inserte en la tabla payment
- Usar Transacciones para el Rollback.
- Tener un ejemplo valido y 2 negativos.

## Automatizar registros con un trigger

El area de seguridad quiere mantener un historial de operaciones sobre los alquileres para fines de auditoria y control 

1.  Crear una tabla rental_log con columnas id, rental_id, action, log_date.
2. Crear un trigger que: 
    - Dispare despues de cada insercion en rental
    - INserte un registro en rental_log

## Crear una funcion para informes de cliente 

El area financiera solicita un reporte que obtenga cuanto ha pagado cada cliente: Este calculo se usara varias veces por lo cual queremos llamarlo como una funcion. 

1. Crear un Funcion llamada total_pagado que: 
   - devuelva el total de pagos (SUM) de ese cliente.
   - Devuelve 0 si no hay registros.
   - parametro de entrada client_id 
2. Ejecutar caso con 0 y uno con monto.

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

## Particionamiento 

Los logs creados en ejercicios anteriores provocara una tabla con muchos datos para una mejor consulta 
particionar por fecha dicha tabla para cada año.