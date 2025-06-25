-- Crear esquema
CREATE SCHEMA IF NOT EXISTS snowflake;
SET search_path TO snowflake;

-- Tabla de hechos
CREATE TABLE fact_ventas (
    id_pago INT PRIMARY KEY,
    id_cliente INT,
    id_tiempo INT,
    id_pelicula INT,
    id_store INT,
    monto_pagado NUMERIC,
    pel_alquilados INT
);

-- Tabla de dimensiones: cliente
CREATE TABLE dim_pais_c (
    id_pais SERIAL PRIMARY KEY,
    nombre VARCHAR(100) UNIQUE
);

CREATE TABLE dim_ciudad_c (
    id_ciudad SERIAL PRIMARY KEY,
    nombre VARCHAR(100),
    id_pais INT REFERENCES dim_pais_c(id_pais)
);

CREATE TABLE dim_cliente (
    id_cliente INT PRIMARY KEY,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    direccion TEXT,
    id_ciudad INT REFERENCES dim_ciudad_c(id_ciudad)
);

-- Tabla de dimensiones: tienda (store)
CREATE TABLE dim_s_pais (
    id_pais SERIAL PRIMARY KEY,
    nombre VARCHAR(100) UNIQUE
);

CREATE TABLE dim_s_ciudad (
    id_ciudad SERIAL PRIMARY KEY,
    nombre VARCHAR(100),
    id_pais INT REFERENCES dim_s_pais(id_pais)
);

CREATE TABLE dim_store (
    id_store INT PRIMARY KEY,
    nombre VARCHAR(100),
    direccion TEXT,
    id_ciudad INT REFERENCES dim_s_ciudad(id_ciudad)
);

-- Tabla de dimensiones: tiempo
CREATE TABLE dim_tiempo (
    id_tiempo SERIAL PRIMARY KEY,
    fecha DATE UNIQUE,
    dia INT,
    mes INT,
    año INT,
    dia_semana VARCHAR(20)
);

-- Tabla de dimensiones: película
CREATE TABLE dim_categoria (
    id_categoria SERIAL PRIMARY KEY,
    nombre VARCHAR(100) UNIQUE,
    descripcion TEXT,
    genero VARCHAR(50)
);

-- Tabla de dimensiones: película
CREATE TABLE dim_pelicula (
    id_pelicula INT PRIMARY KEY,
    nombre VARCHAR(255),
    id_categoria INT REFERENCES dim_categoria(id_categoria),
    rating VARCHAR(10),
    duracion INT
);