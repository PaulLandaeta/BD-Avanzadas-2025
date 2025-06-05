UPDATE customer SET first_name = 'Cliente';
UPDATE customer SET last_name = 'Anonimo';
UPDATE customer SET email = 'cliente_' || customer_id || '@dvd.com';

-- DIRECCIONES
UPDATE address SET address = 'Calle Falsa 123';
UPDATE address SET address2 = 'Depto A';
UPDATE address SET district = 'Distrito';
UPDATE address SET postal_code = '00000';
UPDATE address SET phone = '000-000-0000';

-- PERSONAL
UPDATE staff SET first_name = 'Empleado';
UPDATE staff SET last_name = 'DVDStore';
UPDATE staff SET email = 'staff_' || staff_id || '@empresa.com';
UPDATE staff SET username = 'user_' || staff_id;
UPDATE staff SET password = 'hash123';

-- ACTORES
UPDATE actor SET first_name = 'Actor';
UPDATE actor SET last_name = 'Famoso';

-- PELICULAS
UPDATE film SET description = 'Pelicula muy buena';
UPDATE film SET rental_rate = 2.99;
UPDATE film SET replacement_cost = 19.99;



-- PAGOS
UPDATE payment SET amount = 4.99;

-- CIUDADES
UPDATE city SET city = 'Ciudad';

-- PAISES
UPDATE country SET country = 'Pais';

-- CATEGORIAS
UPDATE category SET name = 'Categoria';

-- IDIOMAS
UPDATE language SET name = 'Idioma';



--Para que muestre las tablas y su ofuscamiento

SELECT 'CUSTOMER' as tabla, count(*) as registros FROM customer;
SELECT 'ADDRESS' as tabla, count(*) as registros FROM address;
SELECT 'STAFF' as tabla, count(*) as registros FROM staff;
SELECT 'ACTOR' as tabla, count(*) as registros FROM actor;
SELECT 'FILM' as tabla, count(*) as registros FROM film;
SELECT 'PAYMENT' as tabla, count(*) as registros FROM payment;
