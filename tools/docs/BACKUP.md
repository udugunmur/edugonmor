# Estrategia de Backups

## 📋 Resumen

| Aspecto | Configuración |
|---------|---------------|
| **Frecuencia** | Diaria |
| **Hora** | 03:00 AM |
| **Retención** | 10 días |
| **Formato** | tar.gz |
| **Destino** | Rclone centralizado |

## 🏗️ Arquitectura de Backup

```
Portainer (/data) → Backup Service → Rclone → Cloud
```

## 📦 Datos Respaldados

| Directorio/Archivo | Descripción |
|--------------------|-------------|
| `portainer.db` | Base de datos SQLite |
| `compose/` | Stacks de Docker Compose |
| `docker_config/` | Configuraciones de Docker |
| `tls/` | Certificados TLS |

## ⏰ Programación

```bash
0 3 * * * tar -czf /backup/portainer-data-backup-$(date +%Y%m%d-%H%M%S).tar.gz -C /source .
```

## 🔄 Operaciones de Backup

### Backup Manual

```bash
make backup
```

### Verificar Backups

```bash
ls -la /home/edugonmor/repos/rclone/docker/volumes/rclone_local_backup_volumen/tools/
```

## 🔙 Restauración

```bash
# 1. Detener servicios
make down

# 2. Restaurar datos
docker run --rm \
  -v tools_volumen:/restore \
  -v /path/to/backup:/backup:ro \
  alpine sh -c "tar -xzf /backup/backup.tar.gz -C /restore"

# 3. Iniciar servicios
make up
```

## 📋 Checklist de Backup

### Diario (Automático)
- [x] Backup ejecutado a las 03:00 AM
- [x] Limpieza de backups antiguos

### Semanal (Manual)
- [ ] Verificar existencia de backups recientes
- [ ] Verificar sincronización con nube
