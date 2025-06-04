UPDATE customer
SET 
  first_name = 'NOMBRE',
  last_name = 'CLIENTE',
  email = 'anonimo' || customer_id || '@dvdrental.com';


UPDATE actor
SET 
  first_name = 'ACTOR',
  last_name = 'X';


UPDATE address
SET 
  address = 'CALLE FALSA 123',
  phone = '000000000';

--staff
UPDATE staff
SET 
  first_name = 'STAFF',
  last_name = 'X',
  email = 'empleado' || staff_id || '@dvdrental.com',
  password = MD5(CONCAT('password', staff_id));

UPDATE city
SET city = CONCAT('Ciudad_', city_id);
