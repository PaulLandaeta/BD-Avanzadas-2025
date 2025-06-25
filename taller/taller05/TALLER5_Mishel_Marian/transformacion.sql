/*TRANSFORMACION*/

// Fechas unicas 
SELECT DISTINCT
    fecha,
    EXTRACT(YEAR FROM fecha) AS anio,
    EXTRACT(MONTH FROM fecha) AS mes,
    EXTRACT(DAY FROM fecha) AS dia
FROM staging_ventas;

//Validamos correctamente las ciudades y paises 

SELECT DISTINCT 
    UPPER(ciudad) AS ciudad,
    UPPER(pais) AS pais
FROM staging_clientes;

// Solo se puede un solo genero 
SELECT 
    id_cliente,
    INITCAP(nombre) AS nombre,
    CASE 
        WHEN genero ILIKE 'm%' THEN 'Masculino'
        WHEN genero ILIKE 'f%' THEN 'Femenino'
    END AS genero,
    (SELECT id_ciudad FROM dim_ciudad WHERE ciudad = sc.ciudad AND pais = sc.pais) AS id_ciudad
FROM staging_clientes sc;

//Unificar los nombres y enlazar las ciudades 
SELECT 
    id_tienda,
    INITCAP(nombre) AS nombre,
    (SELECT id_ciudad FROM dim_ciudad WHERE ciudad = st.ciudad AND pais = st.pais) AS id_ciudad
FROM staging_tiendas st;
// Se calcuka monto_uni si no viene explicito 
SELECT 
    sv.id_venta,
    (SELECT id_tiempo FROM dim_tiempo WHERE fecha = sv.fecha) AS id_tiempo,
    sv.id_cliente,
    sv.id_tienda,
    sv.id_pelicula,
    (SELECT id_ciudad FROM dim_ciudad WHERE ciudad = sv.ciudad AND pais = sv.pais) AS id_ciudad,
    sv.monto_total / NULLIF(sv.cantidad, 0) AS monto_uni,
    sv.cantidad,
    sv.renta_uni
FROM staging_ventas sv;