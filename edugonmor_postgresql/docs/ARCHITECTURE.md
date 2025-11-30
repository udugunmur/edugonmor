# Documentación PostgreSQL

Documentación técnica del proyecto PostgreSQL 16 con Docker.

## Arquitectura

```
┌─────────────────────────────────────┐
│   Aplicación Cliente                │
│   (psql, pgAdmin, app)              │
└───────────────┬─────────────────────┘
                │ Puerto 5432
┌───────────────▼─────────────────────┐
│   Docker Network                    │
│   edugonmor_postgresql_network      │
└───────────────┬─────────────────────┘
                │
┌───────────────▼─────────────────────┐
│   Container PostgreSQL 16           │
│   edugonmor_postgresql_services     │
│                                     │
│   - PostgreSQL 16                   │
│   - Custom entrypoint               │
│   - Custom healthcheck              │
│   - Config personalizada            │
└───────────────┬─────────────────────┘
                │
┌───────────────▼─────────────────────┐
│   Volumen Persistente               │
│   /var/lib/postgresql/data          │
│   → ./volumes/...                   │
└─────────────────────────────────────┘
```

## Configuración

### Variables de Entorno

Según FVO PostgreSQL: https://www.postgresql.org/docs/16/

| Variable | Descripción | Default | Requerido |
|----------|-------------|---------|-----------|
| `POSTGRES_USER` | Usuario administrador | `postgres` | Sí |
| `POSTGRES_PASSWORD` | Contraseña del usuario | - | Sí |
| `POSTGRES_DB` | Base de datos inicial | `postgres` | No |
| `TZ` | Zona horaria | `Europe/Madrid` | No |

### Configuración Dinámica (DL-001)

El proyecto utiliza un sistema de configuración avanzado basado en JSON para gestionar usuarios y bases de datos adicionales.

- **Archivo de Configuración**: `config/init-data.json`
- **Mecanismo**: 
  1. El archivo se monta en `/etc/postgresql-custom/init-data.json`.
  2. El script `sync-db-config` (en el path) procesa este archivo.
  3. Se utiliza `envsubst` para inyectar secretos desde variables de entorno (ej. `${ANALYST_PASSWORD}`).
  4. Se utiliza `jq` para parsear la estructura y `psql` para aplicar cambios.

Este sistema permite añadir usuarios y bases de datos en caliente ejecutando `docker exec -it <container> sync-db-config`.

### Recursos del Contenedor

Según configuración en `docker-compose.yml`:

- **CPU Límite**: 2 cores
- **CPU Reserva**: 0.5 cores
- **Memoria Límite**: 2GB
- **Memoria Reserva**: 512MB

### PostgreSQL Configuration

Archivo: `postgresql.conf`

**Configuraciones principales:**
- `max_connections = 200`
- `shared_buffers = 256MB`
- `effective_cache_size = 768MB`
- `listen_addresses = '*'`

**Logging:**
- `logging_collector = on`
- `log_min_duration_statement = 1000ms`
- Log rotación diaria o 100MB

## Seguridad

### Autenticación

Método configurado: **scram-sha-256** (más seguro que MD5)

Documentación: https://www.postgresql.org/docs/16/auth-password.html

### Network Security

⚠️ **IMPORTANTE**: `listen_addresses = '*'` expone PostgreSQL a todas las interfaces.

**Recomendaciones producción:**
1. Usar firewall para limitar acceso
2. Configurar `pg_hba.conf` para IPs específicas
3. Usar SSL/TLS para conexiones remotas
4. No exponer puerto 5432 públicamente

### Gestión de Contraseñas

- Nunca versionar archivo `.env` con credenciales
- Usar contraseñas fuertes (mínimo 16 caracteres)
- Rotar contraseñas periódicamente
- Usar gestores de secretos en producción (Vault, AWS Secrets Manager)

## Mantenimiento

### Backups

Ver script: `scripts/backup.sh`

**Backup completo:**
```bash
./scripts/backup.sh
```

**Restauración:**
```bash
cat backup_YYYYMMDD_HHMMSS.sql | docker exec -i edugonmor_postgresql_services psql -U postgres -d postgres
```

### Monitoreo

**Healthcheck configurado:**
- Intervalo: 30s
- Timeout: 5s
- Reintentos: 5
- Start period: 30s

**Comandos útiles:**
```bash
# Ver estado
docker-compose ps

# Ver logs
docker-compose logs -f

# Estadísticas en tiempo real
docker stats edugonmor_postgresql_services
```

## Referencias

- [PostgreSQL 16 Documentation](https://www.postgresql.org/docs/16/)
- [Docker Official Images - PostgreSQL](https://hub.docker.com/_/postgres)
- [Docker Compose Documentation](https://docs.docker.com/compose/)

## Troubleshooting

### Problema: Contenedor no inicia

1. Verificar logs: `docker-compose logs`
2. Verificar permisos del volumen
3. Verificar variables de entorno en `.env`

### Problema: No acepta conexiones

1. Verificar puerto: `netcat -zv localhost 5432`
2. Verificar healthcheck: `docker inspect edugonmor_postgresql_services`
3. Revisar `listen_addresses` en `postgresql.conf`

### Problema: Rendimiento lento

1. Revisar recursos: `docker stats`
2. Ajustar `shared_buffers` y `work_mem`
3. Analizar queries lentas en logs (>1000ms)
