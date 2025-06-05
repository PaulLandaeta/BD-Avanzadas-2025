# Taller 3: DevOps vs Hacker - Protección de la Base de Datos

Este repositorio contiene los scripts y la documentación necesarios para proteger, ofuscar y restaurar la base de datos dvdrental frente a accesos no autorizados. Incluye cuatro misiones clave diseñadas para fortalecer la seguridad contra posibles amenazas, como el "hacker desconocido".

## Misión 1: Respaldo Automático
### Objetivo
Implementar un sistema de respaldo periódico para la base de datos dvdrental utilizando pg_dump.

### Script
El archivo backup.js realiza las siguientes tareas:
- Ejecuta el comando pg_dump desde Node.js.
- Almacena el respaldo con un nombre basado en la fecha y hora actuales.

### Requisitos
- Node.js instalado.
- PostgreSQL instalado y accesible desde la línea de comandos.

### Ejecución
bash
node backup.js


## Misión 2: Restauración desde Respaldo
### Objetivo
Restaurar la base de datos dvdrental utilizando el respaldo más reciente.

### Ejecución
Ejecuta el siguiente comando en el contenedor Docker:
bash
docker exec -u postgres bdavanzada-postgres pg_restore -U {usuario} -d {nombre_base_datos} /tmp/dvdrental-ULTIMO_TIMESTAMP.dump


### Notas
- Reemplaza ULTIMO_TIMESTAMP con el nombre del archivo de respaldo más reciente.
- Asegúrate de que la base de datos dvdrental exista antes de ejecutar el comando.
- Opcionalmente, puedes automatizar este proceso con un script adicional.

## Misión 3: Limpieza Automática de Respaldos
### Objetivo
Eliminar automáticamente los respaldos antiguos (con más de 2 días) para optimizar el espacio en el sistema.

### Script
El archivo deleteV2.js realiza las siguientes tareas:
- Elimina todos los archivos con extensión .backup en el directorio /backups que tengan más de 2 días de antigüedad.

### Ejecución
bash
node deleteV2.js
