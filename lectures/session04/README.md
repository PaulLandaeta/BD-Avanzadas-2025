# Transacciones en PostgreSQL

Una **transacción** es un bloque de instrucciones que se ejecuta de forma atómica para garantizar la integridad de los datos. En PostgreSQL podemos controlar la forma en que una transacción ve los cambios de otras mediante **niveles de aislamiento**.

## Niveles de aislamiento

PostgreSQL soporta cuatro niveles de aislamiento que determinan el tipo de fenómenos que pueden ocurrir al leer datos mientras otros procesos realizan escrituras.

1. **READ UNCOMMITTED**
   - No garantiza consistencia entre lecturas; no se recomienda y PostgreSQL lo trata como READ COMMITTED.
   ```sql
   BEGIN TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
   -- operaciones aquí
   COMMIT;
   ```
2. **READ COMMITTED** (por defecto)
   - Cada consulta dentro de la transacción ve solo los datos confirmados antes de que la consulta inicie.
   ```sql
   BEGIN;
   -- Todas las SELECT verán sólo datos confirmados
   COMMIT;
   ```
3. **REPEATABLE READ**
   - Todas las consultas ven una foto consistente tomada al inicio de la transacción.
   ```sql
   BEGIN TRANSACTION ISOLATION LEVEL REPEATABLE READ;
   -- múltiples consultas siempre verán el mismo estado de los datos
   COMMIT;
   ```
4. **SERIALIZABLE**
   - El nivel más estricto; fuerza a que la ejecución concurrente sea equivalente a alguna ejecución secuencial.
   ```sql
   BEGIN TRANSACTION ISOLATION LEVEL SERIALIZABLE;
   -- en caso de conflicto puede abortar con error
   COMMIT;
   ```

## Ejemplo completo

```sql
BEGIN TRANSACTION ISOLATION LEVEL REPEATABLE READ;
  UPDATE cuenta SET saldo = saldo - 100 WHERE id = 1;
  UPDATE cuenta SET saldo = saldo + 100 WHERE id = 2;
COMMIT;
```

En caso de ocurrir un problema, puede revertirse con `ROLLBACK` en lugar de `COMMIT`.
