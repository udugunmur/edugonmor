# Guía de Configuración de Linux

Este documento describe las configuraciones aplicadas por el proyecto linux.

## Índice

1. [CPU Performance Mode](#cpu-performance-mode)
2. [Deshabilitación de Suspensión](#deshabilitación-de-suspensión)
3. [Configuración de GNOME](#configuración-de-gnome)
4. [Optimizaciones de Kernel](#optimizaciones-de-kernel)

---

## CPU Performance Mode

### ¿Qué hace?

Configura el governor de CPU en modo `performance`, lo que mantiene la CPU funcionando a máxima frecuencia en todo momento.

### ¿Por qué?

- Mejor rendimiento en tareas de desarrollo
- Compilaciones más rápidas
- Menor latencia en operaciones

### ¿Cómo funciona?

Se crea un servicio systemd (`cpu-performance.service`) que ejecuta:

```bash
echo performance > /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor
```

### Verificación

```bash
cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor
# Debería mostrar: performance
```

### Deshacer

```bash
sudo systemctl stop cpu-performance.service
sudo systemctl disable cpu-performance.service
```

---

## Deshabilitación de Suspensión

### ¿Qué hace?

Deshabilita completamente sleep, suspend e hibernate a nivel de systemd.

### ¿Por qué?

- Servidores/workstations no deben suspenderse
- Evita interrupciones en procesos largos
- Mantiene conexiones de red activas

### ¿Cómo funciona?

Utiliza `systemctl mask` para prevenir la activación de:

- `sleep.target`
- `suspend.target`
- `hibernate.target`
- `hybrid-sleep.target`

### Verificación

```bash
systemctl status sleep.target
# Debería mostrar: masked
```

### Deshacer

```bash
sudo systemctl unmask sleep.target suspend.target hibernate.target hybrid-sleep.target
```

---

## Configuración de GNOME

### ¿Qué hace?

Aplica configuraciones de GNOME optimizadas para desarrollo.

### Configuraciones aplicadas

| Setting | Valor | Descripción |
|---------|-------|-------------|
| `sleep-inactive-ac-type` | nothing | No suspender con AC |
| `sleep-inactive-battery-type` | nothing | No suspender con batería |
| `idle-delay` | 0 | No apagar pantalla |
| `lock-enabled` | false | No bloquear pantalla |
| `show-hidden-files` | true | Mostrar archivos ocultos |
| `report-technical-problems` | false | No enviar informes |

### Aplicar manualmente

```bash
./config/gnome-settings.sh
```

**Importante**: Ejecutar como usuario normal, NO como root.

### Verificación

```bash
gsettings get org.gnome.settings-daemon.plugins.power sleep-inactive-ac-type
# Debería mostrar: 'nothing'
```

---

## Optimizaciones de Kernel

### vm.swappiness

**Valor**: 10 (default: 60)

Reduce el uso de swap, priorizando RAM.

```bash
echo "vm.swappiness = 10" >> /etc/sysctl.conf
sysctl -p
```

### fs.file-max

**Valor**: 2097152

Aumenta el límite de archivos abiertos simultáneamente.

```bash
echo "fs.file-max = 2097152" >> /etc/sysctl.conf
sysctl -p
```

### Verificación

```bash
cat /proc/sys/vm/swappiness
cat /proc/sys/fs/file-max
```

---

## Troubleshooting

### CPU Governor no cambia

Si el governor no cambia a performance:

1. Verificar que el driver de CPU soporta performance:
   ```bash
   cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_available_governors
   ```

2. Algunos laptops bloquean performance en batería. Conectar a AC.

### GNOME settings no se aplican

1. Verificar que estás ejecutando como usuario normal
2. Verificar que estás en sesión GNOME (no Wayland issues)
3. Algunos schemas pueden variar según versión de Linux

### Servicio no inicia

```bash
# Ver logs
sudo journalctl -u cpu-performance.service

# Recargar systemd
sudo systemctl daemon-reload
```

---

## Referencias

- [Linux/Ubuntu Server Guide - Performance Tuning](https://ubuntu.com/server/docs/performance-tuning)
- [GNOME Settings](https://help.gnome.org/users/gnome-help/stable/)
- [Linux Kernel Documentation](https://www.kernel.org/doc/html/latest/)
