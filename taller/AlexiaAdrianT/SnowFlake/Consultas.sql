SELECT
  pc.nombre AS country,
  dt.año AS year,
  dt.mes AS month_num,
  SUM(fs.monto_pagado) AS total_ventas
FROM dw.fact_ventas fs
JOIN dw.dim_cliente c ON c.id_cliente = fs.id_cliente
JOIN dw.dim_ciudad_c cc ON cc.id_ciudad = c.id_ciudad
JOIN dw.dim_pais_c pc ON pc.id_pais = cc.id_pais
JOIN dw.dim_tiempo dt ON dt.id_tiempo = fs.id_tiempo
GROUP BY pc.nombre, dt.año, dt.mes
ORDER BY pc.nombre, dt.año, dt.mes;


SELECT
  dp.rating,
  dp.nombre AS title,
  SUM(fs.monto_pagado) AS ingresos
FROM dw.fact_ventas fs
JOIN dw.dim_pelicula dp ON dp.id_pelicula = fs.id_pelicula
GROUP BY dp.rating, dp.nombre
ORDER BY dp.rating, ingresos DESC;



SELECT
  ds.nombre AS store_name,
  AVG(fs.monto_pagado) AS venta_promedio
FROM dw.fact_ventas fs
JOIN dw.dim_store ds ON ds.id_store = fs.id_store
GROUP BY ds.nombre
ORDER BY ds.nombre;

SELECT
  dc.nombre AS genero,
  SUM(fs.monto_pagado) AS total_ventas
FROM dw.fact_ventas fs
JOIN dw.dim_pelicula dp ON dp.id_pelicula = fs.id_pelicula
JOIN dw.dim_categoria dc ON dc.id_categoria = dp.id_categoria
GROUP BY dc.nombre
ORDER BY total_ventas DESC;


SELECT
  ds.nombre AS tienda,
  sc.nombre AS ciudad_tienda,
  dc.id_cliente AS cliente_id,
  AVG(fs.monto_pagado) AS gasto_promedio
FROM dw.fact_ventas fs
JOIN dw.dim_store ds ON ds.id_store = fs.id_store
JOIN dw.dim_s_ciudad sc ON sc.id_ciudad = ds.id_ciudad
JOIN dw.dim_cliente dc ON dc.id_cliente = fs.id_cliente
GROUP BY ds.nombre, sc.nombre, dc.id_cliente
ORDER BY tienda, ciudad_tienda, cliente_id;

