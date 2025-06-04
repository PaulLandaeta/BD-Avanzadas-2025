# RESTAURACION DESDE BACKUP

> [!IMPORTANT]  
> Asegurate de tener el backup del contenedor de postgres que quieres restaurar.

> [!IMPORTANT]
> Reemplazar username, database y backup_filename por los valores correctos.

# Restaurar un backup de PostgreSQL
```bash
docker exec -u postgres bdavanza-postgres pg_restore -U {username} -d {database} /tmp/{backup_filename}.dump
```
Ejecutar este comando en la terminal de tu proyecto