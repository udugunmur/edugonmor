# 🏗️ Edugonmor Infrastructure

Repositorio centralizado de infraestructura y servicios Docker para el ecosistema Edugonmor.

## 📂 Estructura del Repositorio

| Directorio | Descripción | Estado |
|------------|-------------|--------|
| `bookstack/` | Wiki y documentación | ✅ Activo |
| `cookiecutter/` | 🔑 **Sistema de plantillas centralizado** | ✅ Activo |
| `gitlab/` | Servidor Git local | ✅ Activo |
| `mongodb/` | Base de datos NoSQL | ✅ Activo |
| `nexus/` | Registro Docker privado | ✅ Activo |
| `nginx/` | Proxy inverso y servidor web | ✅ Activo |
| `penpot/` | Diseño y prototipado | ✅ Activo |
| `postgresql/` | Base de datos SQL | ✅ Activo |
| `rabbitmq/` | Cola de mensajes | ✅ Activo |
| `rclone/` | 🛡️ Sistema de backups centralizado | ✅ Activo |
| `redis/` | Cache en memoria | ✅ Activo |
| `storybook/` | Componentes UI Web | ✅ Activo |
| `tools/` | Portainer + utilidades de gestión | ✅ Activo |
| `ubuntu/` | Configuración de sistema operativo | ✅ Activo |
| `widgetbook/` | Componentes UI Flutter | ✅ Activo |
| `windows/` | Configuración Windows/WSL | ✅ Activo |

## 🚀 Añadir Nuevos Proyectos

Este repositorio utiliza **Cookiecutter** como sistema de plantillas. Para añadir un nuevo proyecto:

### Plantillas Disponibles

```bash
# MariaDB
cookiecutter ./cookiecutter/templates/mariadb -o ./

# MySQL
cookiecutter ./cookiecutter/templates/mysql -o ./
```

### Documentación de Plantillas

- **[Arquitectura de Plantillas](cookiecutter/docs/arquitectura_plantilla.md)**
- **[Guía de Ejecución](cookiecutter/docs/guia_de_ejecucion.md)**
- **[Protocolo para IA](cookiecutter/AGENTS.md)**

## 📋 Estándares del Proyecto

Cada servicio DEBE seguir el **Edugonmor Pattern**:

| Elemento | Convención | Ejemplo |
|----------|------------|---------|
| Servicio Principal | `proyecto_services` | `postgresql_services` |
| Servicio Backup | `proyecto_backup` | `postgresql_backup` |
| Contenedor | `proyecto_<rol>` | `postgresql_services` |
| Volumen Datos | `proyecto_volumen` | `postgresql_volumen` |
| Volumen Backups | `proyecto_backups` | `postgresql_backups` |
| Red | `proyecto_network` | `postgresql_network` |

## 🔧 Configuración Obligatoria

- **Variables de entorno:** Uso obligatorio de archivo `.env` (Tracked)
- **Docker Secrets:** Prohibido el uso de `secrets:`
- **Credenciales:** Inyectadas vía variables de entorno

## 📚 Documentación por Servicio

Cada directorio contiene su propia documentación:

- `README.md` - Manual técnico para humanos
- `agent.md` - Protocolo para agentes IA

## 🛡️ Sistema de Backups

El servicio `rclone/` gestiona los backups centralizados de todos los volúmenes persistentes.

---

**Edugonmor Infrastructure** - Mantenido bajo Protocolo Maestro
