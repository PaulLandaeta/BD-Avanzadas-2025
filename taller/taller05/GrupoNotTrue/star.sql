CREATE TABLE Dim_Tiempo (
    id SERIAL PRIMARY KEY,
    año INT,
    mes INT
);

CREATE TABLE Dim_Country (
    id SERIAL PRIMARY KEY,
    country VARCHAR(50)
);

CREATE TABLE Dim_Store (
    id SERIAL PRIMARY KEY,
    country_id INT,
    city VARCHAR(50),
    FOREIGN KEY (country_id) REFERENCES Dim_Country(id)
);

CREATE TABLE Dim_Customer (
    id SERIAL PRIMARY KEY,
    first_name VARCHAR(50),
    last_name VARCHAR(50)
);

CREATE TABLE Dim_Film (
    id SERIAL PRIMARY KEY,
    title VARCHAR(255),
    rating VARCHAR(10)
);

CREATE TABLE Fact_Ganancia (
    id SERIAL PRIMARY KEY,
    tiempo_id INT,
    store_id INT,
    film_id INT,
    customer_id INT,
    precio DECIMAL(5,2),
    reporte_ganancia DECIMAL(10,2),
    FOREIGN KEY (tiempo_id) REFERENCES Dim_Tiempo(id),
    FOREIGN KEY (store_id) REFERENCES Dim_Store(id),
    FOREIGN KEY (film_id) REFERENCES Dim_Film(id),
    FOREIGN KEY (customer_id) REFERENCES Dim_Customer(id)
);

INSERT INTO Dim_Tiempo (año, mes)
SELECT DISTINCT
    EXTRACT(YEAR FROM p.payment_date) AS año,
    EXTRACT(MONTH FROM p.payment_date) AS mes
FROM postgres.public.payment p
ORDER BY año, mes;


INSERT INTO Dim_Country (country)
SELECT DISTINCT co1.country
FROM postgres.public.country co1
ORDER BY co1.country;

INSERT INTO Dim_Store (country_id, city)
SELECT
    dc.id AS country_id,
    c1.city
FROM postgres.public.store st
JOIN postgres.public.address a ON st.address_id = a.address_id
JOIN postgres.public.city c1 ON a.city_id = c1.city_id
JOIN postgres.public.country co1 ON c1.country_id = co1.country_id
JOIN Dim_Country dc ON co1.country = dc.country
ORDER BY c1.city;

INSERT INTO Dim_Customer (id, first_name, last_name)
SELECT DISTINCT
    c.customer_id,
    c.first_name,
    c.last_name
FROM postgres.public.customer c
ORDER BY c.customer_id;

INSERT INTO Dim_Film (id, title, rating)
SELECT
    film_id,
    title,
    rating
FROM postgres.public.film
ORDER BY film_id;


INSERT INTO Fact_Ganancia (tiempo_id, store_id, film_id, customer_id, precio, reporte_ganancia)
SELECT
    dt.id AS tiempo_id,
    ds.id AS store_id,
    df.id AS film_id,
    dc.id AS customer_id,
    p.amount AS precio,
    p.amount AS reporte_ganancia
FROM postgres.public.payment p
JOIN postgres.public.customer c ON p.customer_id = c.customer_id
JOIN postgres.public.rental r ON p.rental_id = r.rental_id
JOIN postgres.public.inventory i ON r.inventory_id = i.inventory_id
JOIN postgres.public.film f ON i.film_id = f.film_id
JOIN postgres.public.film_category fc ON f.film_id = fc.film_id
JOIN postgres.public.category ca ON fc.category_id = ca.category_id
JOIN postgres.public.staff s ON p.staff_id = s.staff_id
JOIN postgres.public.store st ON s.store_id = st.store_id
JOIN postgres.public.address add1 ON st.address_id = add1.address_id
JOIN postgres.public.city c1 ON add1.city_id = c1.city_id
JOIN postgres.public.country co1 ON c1.country_id = co1.country_id
JOIN postgres.public.address add2 ON c.address_id = add2.address_id
JOIN postgres.public.city c2 ON add2.city_id = c2.city_id
JOIN postgres.public.country co2 ON c2.country_id = co2.country_id
JOIN Dim_Tiempo dt ON EXTRACT(YEAR FROM p.payment_date) = dt.año AND EXTRACT(MONTH FROM p.payment_date) = dt.mes
JOIN Dim_Customer dc ON c.customer_id = dc.id
JOIN Dim_Film df ON f.film_id = df.id
JOIN Dim_Country dc2 ON co1.country = dc2.country
JOIN Dim_Store ds ON st.store_id = ds.id AND dc2.id = ds.country_id;