# Gestión de Roles y Permisos

## Conceptos 

- Rol: Papel que desempaña un user, una funcion que lleva a cabo por voluntad o por imposicion. Puede ser asignado a uno o varios usuarios.
- Permisos: Cada role puede tener permisos y tambien puede ser heredado por otros usuarios.
- Los permisos se pueden aplicar dentro de: 
  - Base de Datos 
  - Esquemas 
  - Tabla / Atributos
  - Funcion / Vistas 

## A escribir Codigo 

### Crear un usuario con 

``` sql 
    Create user analista With password 'analista123';
```

### Crear un rol (grupo sin acceso directo)

```sql
    Create role lectura;
```

### Agregar un usuario al rol 

```sql
    GRANT lectura to analista;
```


### Asignar permisos a una tabla 

conceder solo lectura sobre una tabla especifica 
```sql
    GRANT SELECT on table cliente to lectura;
```

revocar escritura
```sql 
revoke insert, update, delete on table cliente from lectura;
```

### Permitir uso de esquemas 

para que un rol pueda acceder a objetos en un esquma

```sql 
grant usage on schema public to lectura;
```

### Permisos sobre todas las tablas del esquema 

```sql 
Grant select on all tables in schema public to lectura;
```

### Permisos predeterminados para nuevas tablas 

```sql
alter default privileges in schema public
grant select on tables to lectura;
```

### Eliminar permisos y usuarios 
revocar permisos:
```sql 
revoke select on cliente from lectura;
```
eliminar usuario 
```sql
drop user analista;
```

eliminar rol 
```
drop role lectura;
```


