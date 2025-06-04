# Taller 3: DevOps vs Hacker - Defender la Base de Datos

La base de datos esta siendo accedida por un hacker desconocido. Todos piensan que es un Hindu o el Huguito que no aprobo la materia con 100 y se quiere 
vengar de Paul, los logs estan mostrando accesos sospechosos y modificaciones no autorizadas. Estas a cargo de proteger y mantener la integridad de la base 
de datos. 


## Mision 1 Backups automatizados 
Crear un script en Node.js que realice un pg_dump de la base de datos dvdrental y lo guarde con timestamp.

## Mision 2 Ofuscamiento de la base de datos 

Crear un script en SQL que anonimice campos clave de todas las tablas de dvdrental.

guardar el script en .sql para ejecutar en caso que hugo dire el hindu acceda a la base de datos.

## Mision 3 Restauracion desde backups 

usar pg_restore apuntando al ultimo backup creado
documentar este paso en un readme para que se pueda restaurar la BD.

## Mision 4 Limpieza automatica cada 2 dias 

Skynet esta muy saturado con varios backups asi que no podemos darnos el lujo de guardar muchos backups 
crear un script que elimine los archivos que estan mas de 2 dias, este paso debe ejecutarse con un cron que corra cada 2 dias. 
