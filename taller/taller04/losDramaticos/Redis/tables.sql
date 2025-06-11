-- Tabla de usuarios
DROP TABLE users;
CREATE TABLE users (
  id SERIAL PRIMARY KEY,
  name VARCHAR(50),
  email VARCHAR(100),
  city VARCHAR(50),
  role_id INTEGER REFERENCES role(id)
);

-- Tabla de roles
CREATE TABLE role (
  id SERIAL PRIMARY KEY,
  name VARCHAR(50)
);

-- Tabla de permisos
CREATE TABLE permission (
  id SERIAL PRIMARY KEY,
  name VARCHAR(50)
);

-- Tabla intermedia role-permission
CREATE TABLE role_permission (
  role_id INTEGER REFERENCES role(id),
  permission_id INTEGER REFERENCES permission(id),
  PRIMARY KEY (role_id, permission_id)
);


INSERT INTO users (name, email, city, role_id) VALUES
('Alice', 'alice@example.com', 'La Paz', 1),
('Bob', 'bob@example.com', 'Cochabamba', 2),
('Carlos', 'carlos@example.com', 'Santa Cruz', 2),
('Diana', 'diana@example.com', 'El Alto', 2),
('Ernesto', 'ernesto@example.com', 'Sucre', 1),
('Fernanda', 'fernanda@example.com', 'Tarija', 1),
('Gabriel', 'gabriel@example.com', 'Oruro',2),
('Helena', 'helena@example.com', 'Potosí',1),
('Iván', 'ivan@example.com', 'Trinidad',2),
('Julia', 'julia@example.com', 'Cobija',2);

INSERT INTO role (name) VALUES
('Admin'),
('User');

INSERT INTO permission (name) VALUES
('Crear tarea'),
('Editar tarea'),
('Borrar tarea'),
('Ver datos finales'),
('CRUD usuarios');

-- Admin tiene todos los permisos
INSERT INTO role_permission (role_id, permission_id) VALUES
(1, 1), (1, 2), (1, 3), (1, 4), (1, 5);

-- User solo algunos permisos
INSERT INTO role_permission (role_id, permission_id) VALUES
(2, 1), (2, 4);


select u.name, u.email,u.city, r.name as userType, json_agg(p.name) AS permisos
    from users u
    inner join role r on u.role_id = r.id
    inner join public.role_permission rp on r.id = rp.role_id
    inner join public.permission p on p.id = rp.permission_id
    where u.id = 2
group by u.name, u.email, u.city, r.name
