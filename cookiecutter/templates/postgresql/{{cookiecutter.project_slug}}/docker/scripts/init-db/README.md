# Scripts de Inicialización

Scripts SQL ejecutados automáticamente durante la primera inicialización de PostgreSQL.

## Documentación

Según FVO PostgreSQL: https://www.postgresql.org/docs/16/

Los scripts en `/docker-entrypoint-initdb.d/` se ejecutan en orden alfabético **solo** cuando se crea una nueva base de datos (volumen vacío).

## Scripts Disponibles

### `01-init.sql`
Script de inicialización base que:
- Crea extensiones comunes (`uuid-ossp`, `pg_stat_statements`)
- Incluye ejemplos comentados para crear usuarios y bases de datos
- Registra información de inicialización

## Uso

### Aplicar en Nueva Instalación

1. Los scripts se copian automáticamente durante el build del Dockerfile
2. Se ejecutan automáticamente en el primer `docker-compose up`

### Re-ejecutar Inicialización

Si necesitas re-inicializar (⚠️ **ELIMINA TODOS LOS DATOS**):

```bash
docker-compose down -v
docker-compose up -d
```

## Crear Scripts Personalizados

Nombra tus scripts con prefijo numérico para controlar el orden:

```
01-init.sql           # Primero
02-create-schemas.sql # Segundo
03-seed-data.sql      # Tercero
```

**Formato:**
```sql
#!/bin/bash
set -e

psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<-EOSQL
    -- Tu SQL aquí
EOSQL
```

## Referencias

- [PostgreSQL Initialization Scripts](https://github.com/docker-library/docs/blob/master/postgres/README.md#initialization-scripts)
- [PostgreSQL Extensions](https://www.postgresql.org/docs/16/contrib.html)
