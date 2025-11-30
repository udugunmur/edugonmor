# Optimización de Rendimiento en Windows

Guía para optimizar el rendimiento del sistema Windows.

## Servicios Innecesarios

Los siguientes servicios pueden deshabilitarse de forma segura en entornos de desarrollo:

| Servicio | Descripción | Impacto |
|----------|-------------|---------|
| DiagTrack | Telemetría de Windows | Reduce uso de CPU/red |
| dmwappushservice | WAP Push Message | Reduce uso de red |
| MapsBroker | Mapas de Windows | Libera memoria |
| lfsvc | Geolocalización | Reduce uso de CPU |
| RemoteRegistry | Registro remoto | Mejora seguridad |
| XblAuthManager | Xbox Live | Libera recursos |

### Deshabilitar Servicios

```powershell
.\scripts\services.ps1 -Action disable-bloat
```

### Restaurar Servicios

```powershell
.\scripts\services.ps1 -Action enable-all
```

## Configuración de CPU

### Plan de Energía Alto Rendimiento

```powershell
powercfg /setactive 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c
```

### Verificar Plan Activo

```powershell
powercfg /getactivescheme
```

## Optimización de Disco

### Desactivar Indexación (SSD)

1. Abrir "Este equipo"
2. Clic derecho en C: → Propiedades
3. Desmarcar "Permitir que se indexe el contenido..."

### TRIM para SSD

```powershell
# Verificar si TRIM está habilitado
fsutil behavior query DisableDeleteNotify
# 0 = TRIM habilitado
```

## Optimización de Memoria

### Archivo de Paginación

Para sistemas con 16GB+ de RAM:

1. Panel de Control → Sistema → Configuración avanzada
2. Rendimiento → Configuración → Opciones avanzadas
3. Memoria virtual → Cambiar
4. Tamaño personalizado: Inicial 4096 MB, Máximo 8192 MB

## Optimización de Red

### Desactivar Algoritmo de Nagle

Reduce latencia en conexiones TCP:

```powershell
# Se aplica automáticamente con optimize.ps1
```

### Configuración DNS

Usar DNS rápidos:

```powershell
# Google DNS
netsh interface ip set dns "Ethernet" static 8.8.8.8
netsh interface ip add dns "Ethernet" 8.8.4.4 index=2

# Cloudflare DNS
netsh interface ip set dns "Ethernet" static 1.1.1.1
netsh interface ip add dns "Ethernet" 1.0.0.1 index=2
```

## Efectos Visuales

### Desactivar Animaciones

1. Tecla Windows + R
2. Escribir `sysdm.cpl`
3. Pestaña "Opciones avanzadas"
4. Rendimiento → Configuración
5. Seleccionar "Ajustar para obtener el mejor rendimiento"

## Mantenimiento Regular

### Limpieza Semanal

```powershell
.\scripts\cleanup.ps1
```

### Verificación Mensual

```powershell
.\tests\verify.ps1
```

## Monitoreo de Rendimiento

### Task Manager Avanzado

- Ctrl + Shift + Esc
- Más detalles → Rendimiento

### Resource Monitor

```powershell
resmon
```

### Performance Monitor

```powershell
perfmon
```
