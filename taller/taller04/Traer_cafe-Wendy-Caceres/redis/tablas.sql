CREATE TABLE access_rights (
  right_id SERIAL PRIMARY KEY,
  description VARCHAR(50) NOT NULL
);
CREATE TABLE user_roles (
  role_id SERIAL PRIMARY KEY,
  title VARCHAR(50) NOT NULL
);
CREATE TABLE accounts (
  account_id SERIAL PRIMARY KEY,
  username VARCHAR(50) NOT NULL,
  email VARCHAR(100) NOT NULL,
  location VARCHAR(50),
  role_id INTEGER REFERENCES user_roles(role_id)
);
CREATE TABLE role_access (
  role_id INTEGER REFERENCES user_roles(role_id),
  right_id INTEGER REFERENCES access_rights(right_id),
  PRIMARY KEY (role_id, right_id)
);
INSERT INTO accounts (username, email, location, role_id) VALUES
('Sofia', 'sofia@example.com', 'La Paz', 1),
('Miguel', 'miguel@example.com', 'Cochabamba', 2),
('Lucia', 'lucia@example.com', 'Santa Cruz', 2),
('Diego', 'diego@example.com', 'El Alto', 2),
('Valeria', 'valeria@example.com', 'Sucre', 1),
('Andres', 'andres@example.com', 'Tarija', 1),
('Camila', 'camila@example.com', 'Oruro', 2),
('Felipe', 'felipe@example.com', 'Potosí', 1),
('Isabela', 'isabela@example.com', 'Trinidad', 2),
('Tomas', 'tomas@example.com', 'Cobija', 2);

INSERT INTO user_roles (title) VALUES
('Manager'),
('Member');

INSERT INTO access_rights (description) VALUES
('Add Task'),
('Update Task'),
('Delete Task'),
('View Reports'),
('Manage Accounts'),
('Assign Roles');

INSERT INTO role_access (role_id, right_id) VALUES
(1, 1), (1, 2), (1, 3), (1, 4), (1, 5), (1, 6);

INSERT INTO role_access (role_id, right_id) VALUES
(2, 1), (2, 4);