# 📋 Guía de Verificación - {{cookiecutter._project_name}}

## Pasos para Verificar la Plantilla MariaDB

### 1. Limpieza de Entorno
Antes de iniciar, asegurarse de que no haya restos de despliegues anteriores:
```bash
docker compose down -v
rm -rf docker/volumes
rm -rf {{cookiecutter._host_backup_path}}/{{cookiecutter.project_slug}}/mariadb
```

### 2. Crear directorio de salida para backups (requerido por el volumen)

```bash
mkdir -p {{cookiecutter._host_backup_path}}/{{cookiecutter.project_slug}}/mariadb
```

### 2. Verificar sintaxis de docker-compose

```bash
docker compose config --quiet && echo "✅ MariaDB docker-compose OK"
```

### 3. Crear red compartida si no existe

```bash
docker network create {{cookiecutter._network_name}} 2>/dev/null || echo "Red ya existe"
```

### 4. Construir y levantar servicios

```bash
docker compose up -d --build
```

### 5. Verificar conexión a MariaDB

```bash
docker exec {{cookiecutter.project_slug}}_mariadb_services mariadb-admin ping -h localhost
```

### 6. Verificar que el usuario root tiene permisos

```bash
docker exec {{cookiecutter.project_slug}}_mariadb_services mariadb -u root -p{{cookiecutter._db_root_password}} -e "SHOW DATABASES;"
```

### 7. Probar backup manual

```bash
docker exec {{cookiecutter.project_slug}}_backup /usr/local/bin/backup.sh
```

### 8. Verificar archivo de backup creado

```bash
ls -la {{cookiecutter._host_backup_path}}/{{cookiecutter.project_slug}}/mariadb/
```

---

## 🔧 Si hay errores

**Error de volumen no encontrado:**
```bash
# Crear directorio de backups manualmente
mkdir -p {{cookiecutter._host_backup_path}}/{{cookiecutter.project_slug}}/mariadb
```

**Error de red no encontrada:**
```bash
docker network create {{cookiecutter._network_name}}
```

**Error de conexión a MariaDB:**
```bash
# Verificar logs del servicio
docker compose logs {{cookiecutter.project_slug}}_mariadb_services
```

---

## 🧪 Comandos de Prueba Adicionales

### Listar bases de datos
```bash
docker exec {{cookiecutter.project_slug}}_mariadb_services mariadb -u root -p{{cookiecutter._db_root_password}} -e "SHOW DATABASES;"
```

### Verificar usuarios
```bash
docker exec {{cookiecutter.project_slug}}_mariadb_services mariadb -u root -p{{cookiecutter._db_root_password}} -e "SELECT user, host FROM mysql.user;"
```

### Ver logs del servicio
```bash
docker compose logs -f {{cookiecutter.project_slug}}_mariadb_services
```

### Ver logs del backup
```bash
docker compose logs -f {{cookiecutter.project_slug}}_backup
```

### Restaurar backup
```bash
# Restaurar el último backup
docker exec -it {{cookiecutter.project_slug}}_backup /usr/local/bin/restore.sh

# Restaurar un backup específico
docker exec -it {{cookiecutter.project_slug}}_backup /usr/local/bin/restore.sh mariadb_backup_20251205_030000.sql.gz
```

### Detener servicios
```bash
docker compose down
```

### Detener y eliminar volúmenes (⚠️ ELIMINA DATOS)
```bash
docker compose down -v
```

---

## 📚 Documentación Oficial

- **MariaDB**: https://mariadb.com/docs/server/
- **mariadb-dump**: https://mariadb.com/kb/en/mariadb-dump/
- **Backup Overview**: https://mariadb.com/docs/server/server-usage/backup-and-restore/backup-and-restore-overview/
- **Docker MariaDB**: https://hub.docker.com/_/mariadb

---

## 🛡️ Opciones de Backup (Best Practices)

El script `backup.sh` utiliza las siguientes opciones recomendadas por la documentación oficial:

| Opción | Propósito |
|--------|----------|
| `--single-transaction` | Backup consistente sin bloquear tablas InnoDB |
| `--quick` | Evita bufferear tablas grandes en memoria |
| `--routines` | Incluye stored procedures y functions |
| `--triggers` | Incluye triggers |
| `--events` | Incluye eventos programados |
| `--add-drop-database` | Limpia antes de restaurar |
| `--add-drop-table` | Limpia tablas antes de restaurar |
| `--add-drop-trigger` | Limpia triggers antes de restaurar |
| `--flush-privileges` | Recarga privilegios tras restaurar mysql db |
| `--hex-blob` | Portabilidad de datos binarios |
| `--default-character-set=utf8mb4` | Encoding explícito |

> 📚 **Referencia**: https://mariadb.com/kb/en/mariadb-dump/
