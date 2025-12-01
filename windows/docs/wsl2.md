# Configuración de WSL2

Guía para instalar y configurar Windows Subsystem for Linux 2.

## Requisitos

- Windows 10 versión 2004+ o Windows 11
- Virtualización habilitada en BIOS
- 4GB+ de RAM recomendado

## Instalación

### 1. Habilitar WSL

```powershell
# Ejecutar como Administrador
wsl --install
```

Esto instalará:
- WSL2
- Ubuntu (distribución predeterminada)
- Kernel de Linux para Windows

### 2. Reiniciar el Sistema

Después de la instalación, reinicia Windows.

### 3. Configurar Usuario

Al iniciar Ubuntu por primera vez:
1. Crear nombre de usuario
2. Crear contraseña

## Configuración Avanzada

### Archivo .wslconfig

Crear `C:\Users\<usuario>\.wslconfig`:

```ini
[wsl2]
# Límites de recursos
memory=8GB
processors=4
swap=2GB

# Networking
localhostForwarding=true

# Otras opciones
guiApplications=true
```

### Archivo wsl.conf

Dentro de la distribución Linux, crear `/etc/wsl.conf`:

```ini
[automount]
enabled=true
root=/mnt/
options="metadata,umask=22,fmask=11"

[network]
generateResolvConf=true
hostname=wsl-dev

[interop]
enabled=true
appendWindowsPath=true

[boot]
systemd=true
```

## Comandos Útiles

### Gestión de Distribuciones

```powershell
# Listar distribuciones instaladas
wsl --list --verbose

# Establecer versión WSL
wsl --set-version Ubuntu 2

# Establecer distribución predeterminada
wsl --set-default Ubuntu

# Terminar todas las distribuciones
wsl --shutdown

# Exportar distribución
wsl --export Ubuntu ubuntu-backup.tar

# Importar distribución
wsl --import Ubuntu-Dev C:\WSL\Ubuntu-Dev ubuntu-backup.tar
```

### Acceso a Archivos

```bash
# Desde WSL, acceder a Windows
cd /mnt/c/Users/

# Desde Windows, acceder a WSL
\\wsl$\Ubuntu\home\
```

## Integración con VS Code

### 1. Instalar Extensión

Instalar "Remote - WSL" en VS Code.

### 2. Abrir Proyecto en WSL

```bash
# Desde WSL
code .

# Desde Windows
code --remote wsl+Ubuntu /home/usuario/proyecto
```

## Integración con Docker

### Opción 1: Docker Desktop

1. Instalar Docker Desktop para Windows
2. Settings → Resources → WSL Integration
3. Habilitar integración con tu distribución

### Opción 2: Docker dentro de WSL

```bash
# Instalar Docker en Ubuntu
sudo apt update
sudo apt install docker.io docker-compose
sudo usermod -aG docker $USER

# Iniciar servicio (si systemd está habilitado)
sudo systemctl enable docker
sudo systemctl start docker
```

## Optimización

### Reducir Uso de Memoria

WSL2 puede consumir mucha memoria. Limitar en `.wslconfig`:

```ini
[wsl2]
memory=4GB
```

### Reclamar Memoria

```powershell
wsl --shutdown
```

### Ubicación de Archivos

Para mejor rendimiento, mantén archivos de proyecto **dentro** del sistema de archivos de Linux (`/home/usuario/`) en lugar de `/mnt/c/`.

## Solución de Problemas

### Error de Virtualización

```powershell
# Verificar virtualización
systeminfo | find "Virtualization"
```

Si no está habilitada, habilitar en BIOS/UEFI.

### DNS no Funciona

Editar `/etc/wsl.conf`:

```ini
[network]
generateResolvConf=false
```

Crear `/etc/resolv.conf`:

```
nameserver 8.8.8.8
nameserver 1.1.1.1
```

### Problema de Permisos

```bash
# Remontar con permisos correctos
sudo umount /mnt/c
sudo mount -t drvfs C: /mnt/c -o metadata
```
