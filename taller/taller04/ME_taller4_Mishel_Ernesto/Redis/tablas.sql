create table users (
    id int primary key,
    name varchar(100),
    email varchar(100),
    city varchar(100),
    request_count int,
    role_id int,
    foreign key (role_id) references roles(id) on delete set null
);

create table permissions (
    id int primary key,
    name varchar(100)
);

create table roles (
    id int primary key,
    name varchar(100)
);


create table  role_permissions (
    role_id int,
    permission_id int,
    primary key (role_id, permission_id),
    foreign key (role_id) references roles(id) on delete cascade,
    foreign key (permission_id) references permissions(id) on delete cascade
);

--Insercion de Datos
insert into users (id, name, email, city, request_count, role_id) values
(1, 'John Doe', 'john.doe@example.com', 'New York', 0, 1),
(2, 'Jane Smith', 'jane.smith@example.com', 'Los Angeles', 0, 2),
(3, 'Carlos Garcia', 'carlos.garcia@example.com', 'Madrid', 0, 1),
(4, 'Maria Lopez', 'maria.lopez@example.com', 'Barcelona', 0, 2),
(5, 'Pedro Sanchez', 'pedro.sanchez@example.com', 'Seville', 0, 1),
(6, 'Ana Martinez', 'ana.martinez@example.com', 'Valencia', 0, 2),
(7, 'Luis Perez', 'luis.perez@example.com', 'Bilbao', 0, 1),
(8, 'Sofia Rodriguez', 'sofia.rodriguez@example.com', 'Malaga', 0, 2),
(9, 'Diego Torres', 'diego.torres@example.com', 'Granada', 0, 1),
(10, 'Laura Gomez', 'laura.gomez@example.com', 'Zaragoza', 0, 2);

insert into roles (id, name) values
(1, 'admin'),
(2, 'user');

insert into permissions (id, name) values
(1, 'read'),
(2, 'write'),
(3, 'delete'),
(4, 'update'),
(5, 'execute');

insert into role_permissions (role_id, permission_id) values
(1, 1), (1, 2), (1, 3), (1, 4), (1, 5),
(2, 1), (2, 2); 