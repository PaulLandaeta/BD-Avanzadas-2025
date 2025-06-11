CREATE TABLE roles (
    id SERIAL PRIMARY KEY,
    name VARCHAR(50)
);

CREATE TABLE permissions (
    id SERIAL PRIMARY KEY,
    name VARCHAR(50)
);


CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100),
    email VARCHAR(100),
    city VARCHAR(100),
    role_id INT REFERENCES roles(id)
);


CREATE TABLE role_permissions (
    role_id INT REFERENCES roles(id),
    permission_id INT REFERENCES permissions(id),
    PRIMARY KEY (role_id, permission_id)
);


INSERT INTO roles (name) VALUES ('admin'), ('editor');

INSERT INTO permissions (name) VALUES
('create'), ('read'), ('update'), ('delete'), ('publish');

INSERT INTO users (name, email, city, role_id) VALUES
('Luis', 'luis@mail.com', 'La Paz', 1),
('Ana', 'ana@mail.com', 'Cochabamba', 2),
('Jose', 'jose@mail.com', 'Sucre', 2),
('Laura', 'laura@mail.com', 'Santa Cruz', 1),
('Pedro', 'pedro@mail.com', 'Potosí', 1),
('Sofia', 'sofia@mail.com', 'Oruro', 2),
('Martin', 'martin@mail.com', 'Tarija', 2),
('Julia', 'julia@mail.com', 'Trinidad', 2),
('Carlos', 'carlos@mail.com', 'Cobija', 1),
('María', 'maria@mail.com', 'El Alto', 1);

INSERT INTO role_permissions (role_id, permission_id) VALUES
(1, 1), (1, 2), (1, 3), (1, 4), (1, 5),x
(2, 2), (2, 3);
