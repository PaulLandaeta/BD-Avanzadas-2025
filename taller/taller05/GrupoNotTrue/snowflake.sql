create table dim_customer (
    id int primary key,
    city varchar(50),
    country varchar(50)
);
create table dim_store (
    id int primary key,
    city varchar(50),
    country varchar(50)
);

create table dim_date (
    id serial primary key,
    date date,
    day int,
    month int,
    year int
);

create table dim_film (
    id int primary key,
    title varchar(100),
    rating varchar(10)
);

create table dim_cateogry(
    id int primary key,
    name varchar(100)
);

create table dim_film_category(
    filmId int,
    categoryId int,
    foreign key (filmId) references dim_film,
    foreign key (categoryId) references dim_cateogry
);


create table fact_film_rental(
    id serial primary key,
    amount numeric(5, 2),
    filmId int,
    customerId int,
    storeId int,
    dateId int,
    foreign key (filmId) references dim_film,
    foreign key (customerId) references dim_customer,
    foreign key (storeId) references dim_store,
    foreign key (dateId) references dim_date

);



-- ETL Script: Cargar datos desde dvdrental.public al esquema Star
-- Asume que el esquema destino ya existe y las tablas dim_* y fact_* están creadas.

-- 1. Cargar dim_date
-- Insertamos cada fecha de pago única con su día, mes y año
INSERT INTO dim_date(date, day, month, year)
SELECT
    p.payment_date      AS date,
    EXTRACT(DAY FROM p.payment_date)::int   AS day,
    EXTRACT(MONTH FROM p.payment_date)::int AS month,
    EXTRACT(YEAR FROM p.payment_date)::int  AS year
FROM dvdrental.public.payment p;

-- 2. Cargar dim_store
-- Insertamos cada tienda única con ciudad y país
INSERT INTO dim_store(id, city, country)
SELECT DISTINCT
    st.store_id AS id,
    c1.city     AS city,
    co1.country AS country
FROM dvdrental.public.staff s
JOIN dvdrental.public.store st   ON s.store_id = st.store_id
JOIN dvdrental.public.address add1 ON st.address_id = add1.address_id
JOIN dvdrental.public.city c1     ON add1.city_id = c1.city_id
JOIN dvdrental.public.country co1 ON c1.country_id = co1.country_id;

-- 3. Cargar dim_customer
-- Insertamos cada cliente con su ciudad y país
INSERT INTO dim_customer(id, city, country)
SELECT DISTINCT
    c.customer_id AS id,
    c2.city       AS city,
    co2.country   AS country
FROM dvdrental.public.customer c
JOIN dvdrental.public.address add2 ON c.address_id = add2.address_id
JOIN dvdrental.public.city c2       ON add2.city_id = c2.city_id
JOIN dvdrental.public.country co2   ON c2.country_id = co2.country_id;

-- 4. Cargar dim_film
-- Insertamos cada película con su título y calificación
INSERT INTO dim_film(id, title, rating)
SELECT DISTINCT
    f.film_id AS id,
    f.title    AS title,
    f.rating   AS rating
FROM dvdrental.public.film f;

-- 5. Cargar dim_cateogry (categorías)
INSERT INTO dim_cateogry(id, name)
SELECT DISTINCT
    ca.category_id AS id,
    ca.name        AS name
FROM dvdrental.public.category ca;

-- 6. Cargar dim_film_category
INSERT INTO dim_film_category(filmId, categoryId)
SELECT DISTINCT
    fc.film_id     AS filmId,
    fc.category_id AS categoryId
FROM dvdrental.public.film_category fc;

-- 7. Cargar fact_film_rental
INSERT INTO fact_film_rental(amount, filmId, customerId, storeId, dateId)
SELECT
    p.amount,
    p.film_id     AS filmId,
    p.customer_id AS customerId,
    p.store_id    AS storeId,
    d.id          AS dateId
FROM (
    SELECT
        pay.amount,
        pay.payment_date,
        pay.customer_id,
        inv.film_id,
        st.store_id
    FROM payment     pay
    JOIN rental      r   ON pay.rental_id   = r.rental_id
    JOIN inventory   inv ON r.inventory_id  = inv.inventory_id
    JOIN staff       st  ON pay.staff_id     = st.staff_id
    JOIN customer    c   ON pay.customer_id  = c.customer_id
) AS p
-- Unir con dimensión de fechas
JOIN dim_date     d   ON d.date        = p.payment_date
-- Unir con dimensión de tiendas
JOIN dim_store    st  ON st.id          = p.store_id
-- Unir con dimensión de clientes
JOIN dim_customer c   ON c.id           = p.customer_id;

select *
from fact_film_rental;

-- ==================================================
-- Consultas analíticas sobre el esquema estrella
-- ==================================================

-- 1. Total de ventas por país y mes

SELECT
  ds.country         AS country,
  dd.year,
  dd.month,
  SUM(ffr.amount)    AS total_sales
FROM fact_film_rental ffr
JOIN dim_store ds    ON ds.id       = ffr.storeId
JOIN dim_date dd     ON dd.id       = ffr.dateId
GROUP BY ds.country, dd.year, dd.month
ORDER BY ds.country, dd.year, dd.month;

-- 2. Películas más rentables por rating
--    (sumatoria de monto, ordenadas por rating y monto)
SELECT
  df.rating,
  df.title,
  SUM(ffr.amount)    AS total_amount
FROM fact_film_rental ffr
JOIN dim_film df     ON df.id       = ffr.filmId
GROUP BY df.rating, df.title
ORDER BY df.rating, total_amount DESC;

-- 3. Ventas promedio por tienda
SELECT
  ds.id              AS store_id,
  ds.city,
  ds.country,
  AVG(ffr.amount)    AS avg_sales
FROM fact_film_rental ffr
JOIN dim_store ds    ON ds.id       = ffr.storeId
GROUP BY ds.id, ds.city, ds.country
ORDER BY avg_sales DESC;

-- 4. Ventas totales por género
SELECT
  dc.name            AS category,
  SUM(ffr.amount)    AS total_sales
FROM fact_film_rental ffr
JOIN dim_film_category dfc ON dfc.filmId   = ffr.filmId
JOIN dim_cateogry dc       ON dc.id         = dfc.categoryId
GROUP BY dc.name
ORDER BY total_sales DESC;

-- 5. Promedio de gasto por cliente según tienda y ciudad de la película
--    (para cada tienda y ciudad origen de la película, avg gasto por cliente)
SELECT
  ds.id              AS store_id,
  ds.city            AS store_city,
  df_city.city       AS film_city,
  ffr.customerId     AS customer_id,
  AVG(ffr.amount)    AS avg_spent
FROM fact_film_rental ffr
JOIN dim_store ds        ON ds.id        = ffr.storeId
JOIN dim_film df         ON df.id        = ffr.filmId
-- Suponiendo que ciudad de la película es misma ciudad de la tienda o almacenada en dimensión de película
-- Si quisieras la ciudad de origen de la película, necesitarías una relación adicional; uso la ciudad de la tienda aquí.
JOIN dim_store df_city   ON df_city.id = ffr.storeId
GROUP BY ds.id, ds.city, df_city.city, ffr.customerId
ORDER BY ds.id, df_city.city, avg_spent DESC;
