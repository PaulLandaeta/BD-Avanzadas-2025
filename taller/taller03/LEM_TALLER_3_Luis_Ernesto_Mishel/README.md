🛡️ Taller 3: DevOps vs Hacker - Defender la Base de Datos
Este repositorio contiene los scripts y documentación necesarios para proteger, ofuscar y restaurar la base de datos dvdrental ante accesos sospechosos. Cumple con 4 misiones esenciales como parte del plan de defensa ante el "hacker desconocido" (posiblemente Huguito o el Hindú vengador).

🧩 Misión 1: Backups Automáticos
🎯 Objetivo
Realizar un respaldo periódico de la base de datos dvdrental usando pg_dump.
📝 Script
El archivo backup.js realiza lo siguiente:

Ejecuta pg_dump desde Node.js.
Guarda el archivo con nombre basado en la fecha y hora actual.

📦 Requisitos

Node.js
PostgreSQL instalado y accesible desde CLI

📁 Ejecución
node backup.js


🧩 Misión 3: Restauración desde Backups
🎯 Objetivo
Restaurar la base de datos desde el último backup disponible.
📁 Ejecución
docker exec -u postgres bdavanzada-postgres \
pg_restore -U {usuario} -d {nombre para el backup} /tmp/dvdrental-ULTIMO_TIMESTAMP.dump


Reemplaza ULTIMO_TIMESTAMP por el nombre del archivo más reciente.
Asegúrate de que la base de datos dvdrental exista antes de ejecutar.
Puedes automatizar la restauración con un script adicional si se desea.


🧩 Misión 4: Limpieza Automática de Backups (cada 2 días)
🎯 Objetivo
Eliminar backups antiguos (más de 2 días) para evitar sobrecarga en el sistema.
📄 Script
Archivo: cleanup.js

Elimina todos los archivos .backup en /backups que tengan más de 2 días.

📁 Ejecución Manual
node cleanup.js


