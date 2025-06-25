CREATE TABLE hechos_ventas (
    id_venta SERIAL PRIMARY KEY,
    id_tiempo INT,
    id_cliente INT,
    id_tienda INT,
    id_pelicula INT,
    id_ciudad INT,
    monto_uni NUMERIC,
    cantidad INT,
    renta_uni INT
);

CREATE TABLE dim_tiempo (
    id_tiempo INT PRIMARY KEY,
    fecha DATE,
    anio INT,
    mes INT,
    dia INT
);

CREATE TABLE dim_ciudad (
    id_ciudad INT PRIMARY KEY,
    ciudad VARCHAR(100),
    pais VARCHAR(100)
);

CREATE TABLE dim_cliente (
    id_cliente INT PRIMARY KEY,
    nombre VARCHAR(100),
    genero VARCHAR(15),
    id_ciudad INT
);

CREATE TABLE dim_tienda (
    id_tienda INT PRIMARY KEY,
    nombre VARCHAR(100),
    id_ciudad INT
);

CREATE TABLE dim_pelicula (
    id_pelicula INT PRIMARY KEY,
    titulo VARCHAR(255),
    duracion INT,
    rating VARCHAR(10),
    id_ciudad VARCHAR(100)
);
