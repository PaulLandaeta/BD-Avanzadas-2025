--Tabla users
create table
    users (
        id serial primary key,
        username text,
        email text,
        city text,
        role_id integer references roles (id)
    );

-- Tabla de Roles
create table
    roles (id serial primary key, name text);

-- Tabla de Permisos
create table
    permissions (id serial primary key, name text);

create table
    role_permissions (
        role_id integer references roles (id),
        permission_id integer references permissions (id),
        primary key (role_id, permission_id)
    );

insert into
    users (username, email, city, role_id)
values
    ('adriann', 'a@a.com', 'La Paz', 1),
    ('ernesto', 'a@a.com', 'La Paz', 2),
    ('andres', 'a@a.com', 'La Paz', 3),
    ('marian', 'a@a.com', 'La Paz', 1),
    ('paul', 'a@a.com', 'La Paz', 2),
    ('zayn', 'a@a.com', 'La Paz', 3),
    ('zein', 'a@a.com', 'La Paz', 1),
    ('diego', 'a@a.com', 'La Paz', 1),
    ('luis', 'a@a.com', 'La Paz', 2),
    ('alexia', 'a@a.com', 'La Paz', 3);

insert into
    roles (name)
VALUES
    ('admin'),
    ('editor'),
    ('reader');

insert into
    permissions (name)
VALUES
    ('create_post'),
    ('edit_post'),
    ('delete_post'),
    ('read_post'),
    ('god_mode');

-- Asignar roles a usuarios
INSERT INTO
    user_roles (user_id, role_id)
VALUES
    (1, 1), -- Alice es admin
    (2, 2), -- Bob es editor
    (3, 3);

-- Charlie es viewer
-- Asignar permisos a roles
INSERT INTO
    role_permissions (role_id, permission_id)
VALUES
    -- admin puede hacer todo
    (1, 1),
    (1, 2),
    (1, 3),
    (1, 4),
    (1, 5)
    -- editor puede crear, editar y ver
    (2, 1),
    (2, 2),
    (2, 4),
    -- viewer solo puede ver
    (3, 4);

select
    u.username,
    u.email,
    u.city,
    r.name as role,
    json_agg (p.name) as permissions
from
    users u
    join roles r on u.role_id = r.id
    join role_permissions rp on r.id = rp.role_id
    join permissions p on rp.permission_id = p.id
where
    u.id = 1
group by
    u.id,
    r.id