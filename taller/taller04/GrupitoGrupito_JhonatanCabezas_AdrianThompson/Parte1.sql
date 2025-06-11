create table users (
id serial primary key,
name varchar(50) not null,
email varchar(50) unique not null,
city varchar(50),
role_id int not null,
foreign key (role_id) references roles(id)
);

create table roles (
id serial primary key,
name varchar(50) unique not null
);

create table permisos (
id serial primary key,
name varchar(50) unique not null
);

create table roles_permisos (
role_id int not null,
permiso_id int not null,
primary key (role_id, permiso_id),
foreign key (role_id) references roles(id) on delete cascade,
foreign key (permiso_id) references permisos(id) on delete cascade
);

insert into roles (name) values ('admin'), ('user');
insert into permisos (name) values ('read'), ('write'), ('delete'),('update'), ('create');
insert into roles_permisos (role_id, permiso_id)
values
    ((select id from roles where name = 'admin'), (select id from permisos where name = 'read')),
    ((select id from roles where name = 'admin'), (select id from permisos where name = 'write')),
    ((select id from roles where name = 'admin'), (select id from permisos where name = 'delete'));

insert into users (name, email, city, role_id)
values
    ('admin principal', 'admin@example.com', 'lima', (select id from roles where name = 'admin')),
    ('usuario uno', 'user1@example.com', 'la paz', (select id from roles where name = 'user')),
    ('usuario dos', 'user2@example.com', 'santa cruz', (select id from roles where name = 'user')),
    ('usuario tres', 'user3@example.com', 'cochabamba', (select id from roles where name = 'user')),
    ('usuario cuatro', 'user4@example.com', 'sucre', (select id from roles where name = 'user')),
    ('usuario admin3', 'user5@example.com', 'tarija', (select id from roles where name = 'admin')),
    ('usuario admin2', 'user6@example.com', 'potosi', (select id from roles where name = 'admin')),
    ('usuario siete', 'user7@example.com', 'oruro', (select id from roles where name = 'user')),
    ('usuario ocho', 'user8@example.com', 'beni', (select id from roles where name = 'user')),
    ('usuario nueve', 'user9@example.com', 'pando', (select id from roles where name = 'user'));

insert into roles_permisos (role_id, permiso_id)
values
    ((select id from roles where name = 'user'), (select id from permisos where name = 'read'));

select * from users;
select * from roles;
select * from permisos;