# Roles y Permisos
Eres el DBA de la UPB para la cual te dieron la siguiente tarea: 
Crear una estructura de usuarios para separar el acceso de estudiantes, docentes y personal administrativo.
Crear la base de datos en el esquema public: 
- estudiantes
- notas 
- profesorres
- pagos 
- usuarios

## Ejercicio 1 
- Crear tres roles: rol_lectura, rol_escritura, rol_admin
- Crear los siguientes usuarios:
  - pepito_est (estudiante)
  - marcelo_doc (docente)
  - alexis_admin (administrador)
- Asigna a cada usuario el rol correspondiente

## Ejercicio 2 Asignar Permisos 
- el rol_lectura debe poner leer unicamente estudiantes y notas. 
- el rol_escritura debe poder insertar y actualiza en notas.
- el rol_admin debe tener todos los permisos sobre todas las tablas.

## Verificar Permisos 
- Validar que cada usuario solo acceda a lo necesario.