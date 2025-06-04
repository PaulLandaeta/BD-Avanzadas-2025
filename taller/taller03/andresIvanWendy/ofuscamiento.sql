-- datos de clientes
UPDATE customer SET first_name = 'Anon', last_name = 'Ymous', email = CONCAT('anon', customer_id, '@mail.com');

-- direcciones
UPDATE address SET address = 'Calle Falsa 123', district = 'Desconocido';

-- staff
UPDATE staff SET first_name = 'Admin', last_name = 'User', email = CONCAT('staff', staff_id, '@secure.com');