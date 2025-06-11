create table roles(
    id serial primary key,
    name varchar(50)
);

create table users(
    id serial primary key,
    user_name varchar(50),
    name varchar(50),
    lastname varchar(50),
    email varchar(50),
    password varchar(50)
);

create table permissions(
    id serial primary key,
    menu bool,
    path varchar(100),
    name varchar(50),
    display_name varchar(50)
);

create table user_roles(
  user_id int references users,
  role_id int references roles
);

create table role_permissions(
  role_id int references roles,
  permission_id int references permissions
);

INSERT INTO roles(name) VALUES
  ('admin'),
  ('user');

INSERT INTO permissions(menu, path, name, display_name) VALUES
  (true, '/dashboard', 'dashboard', 'Dashboard'),
  (true, '/users', 'users', 'Usuarios'),
  (false, '/settings', 'settings', 'Configuración'),
  (true, '/reports', 'reports', 'Reportes'),
  (false, '/api/logs', 'logs', 'Logs del Sistema');

INSERT INTO users(user_name, name, lastname, email, password) VALUES
  ('jdoe', 'John', 'Doe', 'john@example.com', 'pass123'),
  ('asmith', 'Alice', 'Smith', 'alice@example.com', 'pass123'),
  ('bwayne', 'Bruce', 'Wayne', 'bruce@example.com', 'pass123'),
  ('ckent', 'Clark', 'Kent', 'clark@example.com', 'pass123'),
  ('dprince', 'Diana', 'Prince', 'diana@example.com', 'pass123'),
  ('pparker', 'Peter', 'Parker', 'peter@example.com', 'pass123'),
  ('srogers', 'Steve', 'Rogers', 'steve@example.com', 'pass123'),
  ('ntasha', 'Natasha', 'Romanoff', 'natasha@example.com', 'pass123'),
  ('tstark', 'Tony', 'Stark', 'tony@example.com', 'pass123'),
  ('sstrange', 'Stephen', 'Strange', 'stephen@example.com', 'pass123');

INSERT INTO user_roles(user_id, role_id) VALUES
  (1, 1),
  (2, 2),
  (3, 1),
  (4, 2),
  (5, 1),
  (6, 2),
  (7, 1),
  (8, 1),
  (8, 2),
  (9, 2),
  (10, 2);

INSERT INTO role_permissions(role_id, permission_id) VALUES
  (1, 1),
  (1, 2),
  (1, 3);

INSERT INTO role_permissions(role_id, permission_id) VALUES
  (2, 2),
  (2, 4),
  (2, 5);

CREATE OR REPLACE FUNCTION get_user_info(_user_id INT)
RETURNS TABLE (
  user_name VARCHAR,
  name VARCHAR,
  lastname VARCHAR,
  email VARCHAR,
  roles varchar(50)[],
  menu permissions[],
  permissions varchar(50)[]
) AS $$
BEGIN
  RETURN QUERY
  SELECT
    u.user_name,
    u.name,
    u.lastname,
    u.email,
    ARRAY(
      SELECT r.name
      FROM roles r
      JOIN user_roles ur ON ur.role_id = r.id
      WHERE ur.user_id = u.id
    ) AS roles,
    ARRAY(
      SELECT p
      FROM permissions p
      JOIN role_permissions rp ON rp.permission_id = p.id
      JOIN user_roles ur ON ur.role_id = rp.role_id
      WHERE ur.user_id = u.id AND p.menu = true
    ) AS menu,
    ARRAY(
      SELECT p.name
      FROM permissions p
      JOIN role_permissions rp ON rp.permission_id = p.id
      JOIN user_roles ur ON ur.role_id = rp.role_id
      WHERE ur.user_id = u.id AND p.menu = false
    ) AS permissions
  FROM users u
  WHERE u.id = _user_id;
END;
$$ LANGUAGE plpgsql;

drop function get_user_info(_user_id INT);

SELECT get_user_info(1);