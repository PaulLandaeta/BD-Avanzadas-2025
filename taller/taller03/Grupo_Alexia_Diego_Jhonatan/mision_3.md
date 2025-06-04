Taller 3: Restaurar desde un Respaldo

Cargar nuevamente la base de datos utilizando el respaldo más reciente disponible.

Instrucciones Básicas
Primero, nos aseguramos de tener una base de datos destino vacía, por ejemplo:
docker exec -u postgres bdavanzada-postgres createdb -U grupoalexiadiegojhonatan hash_dvdrental

Luego, utilizamos pg_restore para importar los datos:
docker exec -u postgres bdavanzada-postgres \
pg_restore -U grupoalexiadiegojhonatan -d hash_dvdrental /tmp/backup_2025-06-04.dump


