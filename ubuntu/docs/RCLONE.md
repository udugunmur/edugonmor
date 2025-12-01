````markdown
# Guía de Rclone - Sincronización con la Nube

Este documento describe la instalación, configuración y uso de Rclone para sincronizar con Google Drive y OneDrive.

## Índice

1. [Instalación](#instalación)
2. [Configuración de Remotos](#configuración-de-remotos)
3. [Servicios de Montaje](#servicios-de-montaje)
4. [Sincronización con Docker](#sincronización-con-docker)
5. [Comandos Útiles](#comandos-útiles)
6. [Troubleshooting](#troubleshooting)

---

## Instalación

### Instalación Automática

```bash
sudo ./scripts/install-rclone.sh
```

Este script realiza:
- Instalación de dependencias (`fuse3`, `curl`, `unzip`)
- Instalación de rclone desde script oficial
- Creación de directorios de configuración (`~/.config/rclone`)
- Creación de directorios de montaje (`/mnt/disk2/rclone/`)
- Configuración de FUSE para permitir montajes

### Instalación Manual

```bash
# Instalar dependencias
sudo apt install fuse3 curl unzip

# Instalar rclone
curl https://rclone.org/install.sh | sudo bash

# Crear directorios
mkdir -p ~/.config/rclone
sudo mkdir -p /mnt/disk2/rclone/{gdrive,onedrive}
sudo chown -R $USER:$USER /mnt/disk2/rclone

# Configurar FUSE
echo "user_allow_other" | sudo tee -a /etc/fuse.conf
```

### Verificación

```bash
rclone version
```

---

## Configuración de Remotos

### Configuración Interactiva

```bash
./scripts/configure-rclone.sh
```

El script guía la configuración de:
- **Google Drive** (cuenta: udugunmur@gmail.com)
- **OneDrive** (cuenta: edugonmor@outlook.com)

### Configuración Manual de Google Drive

```bash
rclone config

# Opciones:
# n) New remote
# name> gdrive-udugunmur
# Storage> drive (o número correspondiente)
# client_id> (dejar vacío para usar el de rclone)
# client_secret> (dejar vacío)
# scope> drive (acceso completo)
# root_folder_id> (dejar vacío)
# service_account_file> (dejar vacío)
# Edit advanced config> n
# Use web browser> y (se abrirá navegador)
```

### Configuración Manual de OneDrive

```bash
rclone config

# Opciones:
# n) New remote
# name> onedrive-edugonmor
# Storage> onedrive (o número correspondiente)
# client_id> (dejar vacío)
# client_secret> (dejar vacío)
# region> global
# Edit advanced config> n
# Use web browser> y (se abrirá navegador)
# config_type> onedrive (personal)
```

### Verificar Remotos

```bash
# Listar remotos configurados
rclone listremotes

# Probar conexión
rclone lsd gdrive-udugunmur:
rclone lsd onedrive-edugonmor:
```

---

## Servicios de Montaje

### Habilitar Servicios

```bash
sudo ./scripts/enable-rclone-mount.sh
```

Este script:
- Instala servicios systemd (`rclone-gdrive.service`, `rclone-onedrive.service`)
- Crea archivos de log
- Habilita inicio automático
- Inicia los servicios

### Puntos de Montaje

| Remoto | Punto de Montaje | Servicio |
|--------|------------------|----------|
| gdrive-udugunmur | `/mnt/disk2/rclone/gdrive` | rclone-gdrive.service |
| onedrive-edugonmor | `/mnt/disk2/rclone/onedrive` | rclone-onedrive.service |

### Gestión de Servicios

```bash
# Estado
sudo systemctl status rclone-gdrive.service
sudo systemctl status rclone-onedrive.service

# Iniciar/Detener
sudo systemctl start rclone-gdrive.service
sudo systemctl stop rclone-onedrive.service

# Reiniciar
sudo systemctl restart rclone-gdrive.service

# Habilitar/Deshabilitar inicio automático
sudo systemctl enable rclone-gdrive.service
sudo systemctl disable rclone-gdrive.service

# Ver logs
sudo journalctl -u rclone-gdrive.service -f
sudo journalctl -u rclone-onedrive.service -f
```

### Verificar Montajes

```bash
# Verificar si están montados
mountpoint /mnt/disk2/rclone/gdrive
mountpoint /mnt/disk2/rclone/onedrive

# Listar contenido
ls -la /mnt/disk2/rclone/gdrive
ls -la /mnt/disk2/rclone/onedrive
```

### Opciones de Montaje

Los servicios están configurados con estas opciones optimizadas:

| Opción | Valor | Descripción |
|--------|-------|-------------|
| `--vfs-cache-mode` | writes | Cachea escrituras localmente |
| `--vfs-cache-max-age` | 24h | Tiempo máximo de caché |
| `--vfs-read-chunk-size` | 64M | Tamaño de chunk de lectura |
| `--buffer-size` | 64M | Tamaño del buffer |
| `--dir-cache-time` | 72h | Caché de directorios |
| `--poll-interval` | 15s | Intervalo de polling |
| `--allow-other` | - | Permite acceso a otros usuarios |

---

## Sincronización con Docker

El proyecto Docker de rclone (`/home/edugonmor/repos/edugonmor/rclone`) también usa la configuración de rclone.

### Sincronizar Configuración

```bash
./scripts/sync-rclone-config.sh
```

Este script copia `~/.config/rclone/rclone.conf` al proyecto Docker:
- Destino: `/home/edugonmor/repos/edugonmor/rclone/docker/config/rclone.conf`
- Crea backup del archivo anterior
- Establece permisos restrictivos (600)

### Flujo de Trabajo

1. Configura remotos en el host con `configure-rclone.sh`
2. Sincroniza con Docker usando `sync-rclone-config.sh`
3. Reinicia contenedores Docker para aplicar cambios

---

## Comandos Útiles

### Operaciones Básicas

```bash
# Listar archivos en remoto
rclone ls gdrive-udugunmur:

# Listar directorios
rclone lsd gdrive-udugunmur:

# Copiar archivo local a remoto
rclone copy archivo.txt gdrive-udugunmur:backup/

# Sincronizar directorio (espejo)
rclone sync /local/dir gdrive-udugunmur:remote/dir

# Copiar de remoto a local
rclone copy gdrive-udugunmur:docs /local/docs
```

### Información y Estadísticas

```bash
# Espacio usado
rclone about gdrive-udugunmur:

# Tamaño de directorio
rclone size gdrive-udugunmur:folder/

# Verificar integridad
rclone check /local/dir gdrive-udugunmur:remote/dir
```

### Montaje Manual

```bash
# Montar manualmente (sin servicio)
rclone mount gdrive-udugunmur: /mnt/disk2/rclone/gdrive \
    --vfs-cache-mode writes \
    --allow-other

# Desmontar
fusermount -uz /mnt/disk2/rclone/gdrive
```

---

## Troubleshooting

### Servicio no inicia

```bash
# Ver logs detallados
sudo journalctl -u rclone-gdrive.service -n 50 --no-pager

# Verificar configuración de rclone
rclone config show

# Probar montaje manual
rclone mount gdrive-udugunmur: /tmp/test --vfs-cache-mode off -v
```

### Token expirado

Los tokens de OAuth expiran periódicamente. Para renovar:

```bash
# Renovar token (se abrirá navegador)
rclone config reconnect gdrive-udugunmur:

# O reconfigurar desde cero
./scripts/configure-rclone.sh
```

### Montaje no responde

```bash
# Forzar desmontaje
sudo fusermount -uz /mnt/disk2/rclone/gdrive

# Reiniciar servicio
sudo systemctl restart rclone-gdrive.service
```

### Error "Transport endpoint is not connected"

```bash
# Limpiar montaje zombie
sudo umount -l /mnt/disk2/rclone/gdrive
sudo fusermount -uz /mnt/disk2/rclone/gdrive

# Recrear directorio
sudo rm -rf /mnt/disk2/rclone/gdrive
sudo mkdir -p /mnt/disk2/rclone/gdrive
sudo chown $USER:$USER /mnt/disk2/rclone/gdrive

# Reiniciar servicio
sudo systemctl restart rclone-gdrive.service
```

### Logs

| Servicio | Archivo de Log |
|----------|----------------|
| Google Drive | `/var/log/rclone-gdrive.log` |
| OneDrive | `/var/log/rclone-onedrive.log` |

```bash
# Ver logs en tiempo real
tail -f /var/log/rclone-gdrive.log
tail -f /var/log/rclone-onedrive.log
```

---

## Referencias

- [Documentación oficial de Rclone](https://rclone.org/docs/)
- [Rclone Mount](https://rclone.org/commands/rclone_mount/)
- [Google Drive backend](https://rclone.org/drive/)
- [OneDrive backend](https://rclone.org/onedrive/)
- [VFS Cache Mode](https://rclone.org/commands/rclone_mount/#vfs-file-caching)

---

**Última actualización:** 1 de diciembre de 2025
````