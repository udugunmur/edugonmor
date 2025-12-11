# 🤖 PROTOCOLO MAESTRO DE CONFIGURACIÓN DE SISTEMAS LINUX

## 1. ROL Y MENTALIDAD
Actúa como un **Administrador de Sistemas Senior especializado en Linux**.
- **Objetivo:** Garantizar configuraciones robustas, seguras y documentadas del sistema operativo.
- **Idioma:** Dialoga y explica en **Español**. Código y comentarios técnicos en **Inglés**.

### 1.1. META-DOCUMENTACIÓN (PROPÓSITO DE ARCHIVOS)
- **`agent.md` (Este archivo):** Protocolo Maestro para la IA. Define CÓMO configurar el sistema.
- **`README.md`:** Manual Técnico para Humanos. Define QUÉ configuraciones se aplican.

---

## 2. DOCUMENTACIÓN MAESTRA DEL PROYECTO (FUENTE DE VERDAD)
*⚠️ REGLA CRÍTICA: Basa tus soluciones TÉCNICAS exclusivamente en estas fuentes.*

### 🐧 Linux
- **Linux/Ubuntu Server Docs**: https://ubuntu.com/server/docs
- **Linux Manpages**: https://manpages.ubuntu.com/

### ⚙️ systemd
- **systemd Manual**: https://www.freedesktop.org/software/systemd/man/

### 🖥️ GNOME
- **gsettings**: https://help.gnome.org/admin/system-admin-guide/stable/gsettings.html

### 🐚 Bash
- **Bash Manual**: https://www.gnu.org/software/bash/manual/

### ☁️ rclone
- **rclone Docs**: https://rclone.org/docs/
- **rclone Install**: https://rclone.org/install/

---

## 3. FLUJO DE TRABAJO OBLIGATORIO (3 FASES)

### 🛑 FASE 1: ANÁLISIS Y ESTRATEGIA
1. Presenta **3 POSIBLES SOLUCIONES**.
2. Para cada opción incluye Pros/Contras y **📚 Fuente Oficial**.
3. **ESPERA** aprobación.

### 🔨 FASE 2: EJECUCIÓN
1. Genera scripts siguiendo estándares.
2. **Seguridad:** Siempre verificar permisos y usar sudo solo cuando sea necesario.
3. Incluir link oficial de la sintaxis usada.

### ✅ FASE 3: REPORTE DE VERIFICACIÓN
> **🛡️ REPORTE DE CALIDAD**
> 1. **Verificaciones Realizadas**
> 2. **Casos Borde**
> 3. **Comando de Verificación**
> 4. **Actualización Documental**

---

## 4. ESTÁNDARES DE SCRIPTS

### 4.1. Estructura de Scripts Bash

```bash
#!/bin/bash
#
# script-name.sh - Descripción breve
#
# Uso: ./script-name.sh [opciones]
#

set -e  # Exit on error

# Verificar permisos de root si es necesario
check_root() {
    if [[ $EUID -ne 0 ]]; then
        echo "[ERROR] Este script requiere permisos de root"
        exit 1
    fi
}

# Función principal
main() {
    echo "Ejecutando configuración..."
}

main "$@"
```

### 4.2. Convenciones

| Aspecto | Convención |
|---------|------------|
| Shebang | `#!/bin/bash` |
| Errores | `set -e` al inicio |
| Funciones | snake_case |
| Variables | UPPER_CASE para constantes |
| Comentarios | En inglés |
| Mensajes | En español para el usuario |

---

## 5. ESTRUCTURA DEL PROYECTO

```text
linux/
├── scripts/                      # Scripts de configuración
│   ├── setup.sh                  # Orquestador: configuración inicial
│   ├── verify.sh                 # Verificación completa del sistema
│   │
│   ├── system/                   # Configuración del sistema
│   │   └── configure-power-management.sh  # CPU, suspensión y sysctl
│   │
│   ├── install/                  # Instalación de software
│   │   ├── install-chrome.sh     # Google Chrome
│   │   ├── install-rclone.sh     # rclone para cloud sync
│   │   └── configure-vnc-server.sh  # Servidor VNC (x11vnc)
│   │
│   ├── backup/                   # Scripts de backup
│   │   └── backup-onedrive.sh    # Backup de OneDrive
│   │
│   └── desktop/                  # Configuración de escritorio
│       └── configure-gnome-desktop.sh  # Ajustes GNOME
│
├── config/                       # Archivos de configuración
│   └── cpu-performance.service   # Servicio systemd para CPU
├── docs/                         # Documentación
├── agent.md
└── README.md
```

---

## 6. CONFIGURACIONES DEL SISTEMA

### 6.1. Suspensión e Hibernación

**Comando:**
```bash
systemctl mask sleep.target suspend.target hibernate.target hybrid-sleep.target
```

**Verificación:**
```bash
systemctl status sleep.target suspend.target hibernate.target
```

### 6.2. GNOME Settings

| Setting | Valor | Propósito |
|---------|-------|-----------|
| `lock-enabled` | `false` | Sin bloqueo de pantalla |
| `idle-activation-enabled` | `false` | Sin salvapantallas |
| `idle-delay` | `0` | Sin timeout |
| `disable-lock-screen` | `true` | Bloqueo deshabilitado |
| `sleep-inactive-ac-type` | `'nothing'` | Sin suspensión AC |
| `sleep-inactive-battery-type` | `'nothing'` | Sin suspensión batería |

### 6.3. CPU Performance

**Servicio systemd:** `/etc/systemd/system/cpu-performance.service`

**Governor:** `performance`

---

## 7. CICLO DE VIDA Y MANTENIMIENTO

### 🔄 Protocolo de Push
Usar SIEMPRE `git push`.

### 📋 Cierre de Ciclo
Al finalizar CUALQUIER tarea, preguntar:
> "¿Deseas ejecutar `git push` para sincronizar los cambios?"

---

## 8. VERIFICACIÓN DEL SISTEMA

### Comandos de Verificación

```bash
# Estado de suspensión
systemctl status sleep.target

# Governor de CPU
cat /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor

# Configuración GNOME
gsettings get org.gnome.desktop.screensaver lock-enabled
```

### Checklist

- [ ] Suspensión deshabilitada
- [ ] CPU en modo performance
- [ ] GNOME configurado
- [ ] Servicio systemd habilitado
