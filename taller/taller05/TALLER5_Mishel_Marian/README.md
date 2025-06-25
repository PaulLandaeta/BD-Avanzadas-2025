# Taller: Diseño de un Data Warehouse con ETL y esquemas Estrella/ Copo de Nieve. 

Una empresa de alquiler de peliculas online quiere analizar 
el comportamiento de sus clientes. Se desea analizar las ventas 
a partir de su base de datos transaccional (dvdRental)
## Consultas 
- Total de ventas por pais y mes
SELECT 
    c.pais,
    t.mes,
    SUM(h.renta_uni) AS total_ventas
FROM hechos_ventas h
JOIN dim_tiempo t ON h.id_tiempo = t.id_tiempo
JOIN dim_ciudad c ON h.id_ciudad = c.id_ciudad
GROUP BY c.pais, t.mes
ORDER BY c.pais, t.mes;

- peliculas mas rentables por rating
SELECT p.rating, p.titulo, SUM(h.renta_uni) AS total_renta
FROM hechos_ventas h
JOIN dim_pelicula p ON h.id_pelicula = p.id_pelicula
GROUP BY p.rating, p.titulo
ORDER BY p.rating, total_renta DESC;

- Ventas promedio por tienda
SELECT t.nombre, ROUND(AVG(h.renta_uni)) AS promedio_ventas
FROM hechos_ventas h
JOIN dim_tienda t ON h.id_tienda = t.id_tienda
GROUP BY t.nombre
ORDER BY t.nombre;

- Ventas totales por género
SELECT c.genero, SUM(h.renta_uni) AS total_ventas
FROM hechos_ventas h
JOIN dim_cliente c ON h.id_cliente = c.id_cliente
GROUP BY c.genero
ORDER BY c.genero;

- Promedio de gasto por cliente segun tienda, ciudad de la pelicula
SELECT c.nombre AS cliente_nombre, dt.nombre AS tienda_nombre, dc.ciudad AS ciudad_pelicula, ROUND(AVG(h.renta_uni)) AS promedio_gasto
FROM hechos_ventas h
JOIN dim_cliente c ON h.id_cliente = c.id_cliente
JOIN dim_tienda dt ON h.id_tienda = dt.id_tienda
JOIN dim_pelicula p ON h.id_pelicula = p.id_pelicula
JOIN dim_ciudad dc ON p.id_ciudad::INT = dc.id_ciudad
GROUP BY c.nombre, dt.nombre, dc.ciudad
ORDER BY c.nombre, dt.nombre, dc.ciudad;

## Extraer 
- Crear las consultas necesarias para obtener los datos necesarios para crear la base de datos estrella
- Explicar que datos son relevantes para un DataMart de analisis de ventas. Identificar Dimensiones y Hechos.

## Transformar 
- Ver que datos son necesarios para hacer una actualizacion o transformacion, crear el script en SQL o un lenguaje de programacion.

## Cargado 
- Modelar un esquema Estrella para el analisis de ventas
- Implementar las tablas en PostgreSQL.
- Cargar los datos obtenidos al modelo estrella

## Modelo Copo de Nieve 
- Transforma el modelo estrella a un esquema tipo Copo de Nieve. 
- Actualizar las tablas y relaciones.

## Entrega esperada: 
- Script SQL de creacion y carga al DW.
- Documento con el Diseño del esquema estrella y copo de nieve.
- Documento explicando el ETL paso a paso. 
- Captura de los resultados. 