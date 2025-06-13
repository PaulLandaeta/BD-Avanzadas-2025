# Taller REDIS y MongoDB

## Parte 1 - Redis 

Crear una pequeña app con NodeJS que guarde y consulte informacion de un usuario en Redis. 

- Guardar informacion de un usuario en Redis: nombre, correo, ciudad, permisos, roles.
- Obtener informacion por user_id 
- Establecer expiracion de 5 minutos.
- Contar cuantas veces se ha solicitado ese usuario. 
- en la base de datos se debe tener las tablas, user, roles, permisos. 

### Resultados esperados 

- Levantar Redis y PostgreSQL con Docker 
- Crear 10 registros de usuarios en la tabla user
- crear al menos 5 permisos. 
- Crear al menos 2 roles. 
- Sacar una captura de cada valor en Redis y la expiracion de la data.

## Parte 2 - MongoDB 

Modelar una BD con embebidos y referencias. 

### Sistema de turnos y pacientes en centros medicos

Son las 8:00 a.m. en el Hospital Vida Sana, y el Dr. Miguel Gómez, jefe de medicina general, se presenta en tu oficina.

- Necesito revisar mis turnos del 15 de junio de 2025. Solo los confirmados.
- Quiero ver todos los comentarios médicos registrados en esos turnos.
- ¿Cuántos pacientes tengo con más de 40 años y al menos dos teléfonos registrados?
- Necesito ver los pacientes que tienen turnos pendientes aún sin atender.