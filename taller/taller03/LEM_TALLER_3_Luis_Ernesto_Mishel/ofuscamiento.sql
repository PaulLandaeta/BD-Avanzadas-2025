
UPDATE customer
SET 
    first_name = CONCAT('Nombre', customer_id),
    last_name = CONCAT('Apellido', customer_id),
    email = CONCAT('cliente', customer_id, '@ejemplo.com');

UPDATE staff
SET 
    first_name = CONCAT('Empleado', staff_id),
    last_name = CONCAT('Apellido', staff_id),
    email = CONCAT('empleado', staff_id, '@empresa.com'),
    username = CONCAT('user', staff_id),
    password = MD5(CONCAT('password', staff_id));

UPDATE address
SET 
    address = CONCAT('Calle Falsa #', address_id),
    address2 = NULL,
    district = 'Distrito X',
    phone = CONCAT('+591', LPAD(address_id::text, 8, '0'));

UPDATE city
SET city = CONCAT('Ciudad_', city_id);

UPDATE country
SET country = CONCAT('Pais_', country_id);
