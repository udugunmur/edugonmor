# Tests PostgreSQL

Scripts de prueba para el servicio PostgreSQL.

## Scripts Disponibles

### `test-connection.sh`
Script para verificar la conexión y funcionalidad básica de PostgreSQL.

**Uso:**
```bash
cd test
chmod +x test-connection.sh
./test-connection.sh
```

**Tests realizados:**
1. Verificar puerto accesible
2. PostgreSQL responde (pg_isready)
3. Ejecución de consulta SQL
4. Verificar extensiones disponibles

### `test-security.sh`
Script para validar la implementación de seguridad (RBAC y Auditoría).

**Uso:**
```bash
cd test
chmod +x test-security.sh
./test-security.sh
```

**Tests realizados:**
1. Existencia de roles `app_reader` y `app_writer`.
2. Asignación correcta de roles a usuarios.
3. Verificación de parámetros de logging en tiempo de ejecución.

## Requisitos

- Docker y Docker Compose corriendo
- Contenedor `postgresql_services` iniciado
- `netcat` (nc) instalado para test de puertos

## Crear Tests Adicionales

Los tests deben seguir las FVO de PostgreSQL:
- https://www.postgresql.org/docs/16/

Ejemplo de test SQL:
```bash
docker exec postgresql_services psql -U postgres -d postgres -c "SELECT 1;"
```
