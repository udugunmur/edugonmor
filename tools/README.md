# 🛠️ tools

> **Herramientas de Gestión de Infraestructura Docker**
>
> Repositorio que centraliza Portainer CE y otras herramientas de administración de contenedores Docker.

## 📚 Sobre esta Documentación
- **`README.md` (Este archivo):** Manual técnico para **Humanos**. Explica uso, arquitectura y extensibilidad.
- **`agent.md`:** Protocolo Maestro para **Agentes IA**. Define reglas de desarrollo, flujo de trabajo y políticas de seguridad.

---

# 👤 GUÍA DE USUARIO (Quick Start)

## 🐳 Quick Start

```bash
# 1. Clonar repositorio
git clone https://github.com/edugonmor/tools.git
cd tools

# 2. Configurar variables de entorno
cp .env.example .env
# Editar .env con tus valores

# 3. Desplegar servicios
make up
```

## 🛠️ Comandos Comunes

| Comando | Descripción |
|---------|-------------|
| `make up` | Inicia todos los servicios |
| `make down` | Detiene todos los servicios |
| `make restart` | Reinicia los servicios |
| `make logs` | Muestra logs en tiempo real |
| `make status` | Estado de los contenedores |
| `make test` | Ejecuta tests de verificación |
| `make backup` | Fuerza backup manual |
| `make fclean` | Limpieza completa (elimina volúmenes) |
| `make stable` | Push a repositorio remoto |

## 🌐 Acceso a Portainer

| Protocolo | URL | Puerto |
|-----------|-----|--------|
| **HTTPS** (Recomendado) | https://localhost:9443 | 9443 |
| **HTTP** | http://localhost:9000 | 9000 |

> **Nota**: En el primer acceso deberás configurar la contraseña de administrador.

---

# 🏗️ GUÍA DE ARQUITECTO Y MANTENEDOR

> **Documentación Técnica para la Gestión de Herramientas Docker**
>
> Esta sección se enfoca en la arquitectura interna, diseño modular y extensibilidad.

## 📐 Filosofía Arquitectónica

Este proyecto sigue un enfoque **Docker-first** para la gestión de herramientas de infraestructura.

### 1. Servicios Incluidos

| Servicio | Imagen | Descripción |
|----------|--------|-------------|
| **Portainer CE** | `portainer/portainer-ce:latest` | Gestor visual de contenedores Docker |
| **Backup** | `alpine:3.19` | Servicio de backup automatizado |

### 2. Arquitectura de Red

> **⚠️ IMPORTANTE**: `tools` es el **proyecto maestro** que crea la red `shared_network`. Debe iniciarse **PRIMERO** antes que cualquier otro proyecto del ecosistema.

```
┌─────────────────────────────────────────────────────────────────┐
│                    tools                              │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │              shared_network (CREADOR)                 │   │
│  │                                                          │   │
│  │  ┌──────────────────────┐  ┌──────────────────────────┐ │   │
│  │  │  Portainer CE        │  │  Backup Service          │ │   │
│  │  │  (services)          │  │  (backup)                │ │   │
│  │  │                      │  │                          │ │   │
│  │  │  📊 Dashboard        │  │  🕐 Cron Job (03:00 AM)  │ │   │
│  │  │  🐳 Docker Mgmt     │  │  📦 Tar Compress         │ │   │
│  │  │  📈 Monitoring       │  │  🗑️ Retention (10 days)  │ │   │
│  │  │                      │  │                          │ │   │
│  │  │  Ports: 9443, 9000   │  │                          │ │   │
│  │  └──────────────────────┘  └──────────────────────────┘ │   │
│  │          │                           │                   │   │
│  └──────────┼───────────────────────────┼───────────────────┘   │
│             │                           │                       │
│  ┌──────────▼──────────┐     ┌──────────▼──────────┐           │
│  │ tools_    │     │ tools_    │           │
│  │ volumen             │────▶│ backups             │           │
│  │ (Datos Portainer)   │     │ (Rclone Mount)      │           │
│  └─────────────────────┘     └─────────────────────┘           │
└─────────────────────────────────────────────────────────────────┘
```

### 3. Red Unificada del Ecosistema

Todos los proyectos del ecosistema comparten una única red Docker llamada `shared_network`:

| Proyecto | Rol en la Red |
|----------|---------------|
| **tools** | 🏠 **CREADOR** - Debe iniciarse primero |
| mariadb | Externa |
| mysql | Externa |
| mongodb | Externa |
| postgresql | Externa |
| redis | Externa |
| rabbitmq | Externa |
| nginx | Externa |
| penpot | Externa |
| nexus | Externa |
| cookiecutter | Externa |
| storybook | Externa |
| widgetbook | Externa |
| rclone | Externa |

**Orden de Arranque Recomendado:**
```bash
# 1. Primero: tools (crea la red)
cd tools && make up

# 2. Después: cualquier otro proyecto
cd ../postgresql && make up
cd ../redis && make up
# ... etc
```

## 🗺️ Estructura del Código Fuente

```text
tools/
├── config/                    # ⚙️ Configuraciones de servicios
│   └── portainer.json        # Configuración de Portainer
│
├── docker/                    # 🐳 Configuración Docker
│   ├── scripts/              # Scripts de inicialización
│   │   ├── init-portainer.sh # Inicialización de Portainer
│   │   └── backup.sh         # Script de backup manual
│   ├── secrets/              # Credenciales (solo desarrollo)
│   │   └── portainer_password.txt
│   └── volumes/              # Datos persistentes (ignorado)
│
├── docs/                      # 📖 Documentación
│   ├── ARCHITECTURE.md       # Arquitectura del sistema
│   ├── BACKUP.md             # Estrategia de backups
│   └── SECURITY.md           # Políticas de seguridad
│
├── tests/                     # 🧪 Tests de verificación
│   ├── README.md             # Documentación de tests
│   ├── test-connection.sh    # Test de conectividad
│   └── test-portainer.sh     # Test de Portainer
│
├── .dockerignore              # Exclusiones Docker
├── .env.example               # Variables de entorno ejemplo
├── .gitignore                 # Archivos ignorados
├── agent.md                   # 🤖 Protocolo para IA
├── docker-compose.yml         # 📦 Definición de servicios
├── Makefile                   # 🕹️ Comandos de automatización
└── README.md                  # 📚 Este archivo
```

## 🔧 Componentes Detallados

### 1. Portainer CE (`tools_services`)

| Aspecto | Detalle |
|---------|---------|
| **Imagen** | `portainer/portainer-ce:latest` |
| **Puertos** | 9443 (HTTPS), 9000 (HTTP) |
| **Función** | Gestión visual de contenedores Docker |

**Características:**
- Dashboard de monitorización
- Gestión de stacks y compose files
- Administración de volúmenes y redes
- Terminal web a contenedores
- Logs en tiempo real

### 2. Servicio de Backup (`tools_backup`)

| Aspecto | Detalle |
|---------|---------|
| **Imagen** | `alpine:3.19` |
| **Programación** | Diario a las 03:00 AM |
| **Retención** | 10 días |

**Proceso:**
1. Cron job se ejecuta a las 03:00 AM
2. Comprime datos de Portainer en tar.gz
3. Almacena en volumen conectado a Rclone
4. Elimina backups con más de 10 días

## 🛠️ Flujo de Desarrollo

### Prerrequisitos
- Docker 24.0+
- Docker Compose v2+
- Make

### Tareas Comunes

**1. Desplegar Servicios**
```bash
make up
```

**2. Ver Logs**
```bash
make logs
```

**3. Ejecutar Tests**
```bash
make test
```

## 🧩 Extender el Sistema

### Añadir Nuevo Servicio

1. Definir servicio en `docker-compose.yml`
2. Seguir convención de nombres: `tools_<nombre>`
3. Crear documentación en `docs/`
4. Añadir tests en `tests/`

### Ejemplo de Nuevo Servicio

```yaml
services:
  tools_nuevo:
    image: imagen:tag
    container_name: tools_nuevo
    restart: unless-stopped
    networks:
      - shared_network
```

## 📚 Documentación de Referencia

- **Portainer**: https://docs.portainer.io/
- **Docker**: https://docs.docker.com/
- **Docker Compose**: https://docs.docker.com/compose/

## 🏗️ Estándar de Infraestructura

Este proyecto sigue el **Edugonmor Pattern**:

| Elemento | Convención |
|----------|------------|
| Servicio Principal | `proyecto_services` |
| Servicio Backup | `proyecto_backup` |
| Volumen Datos | `proyecto_volumen` |
| Volumen Backups | `proyecto_backups` |
| Red | `shared_network` (compartida) |

**Configuración:**
- Uso obligatorio de archivo `.env`
- Prohibido el uso de Docker Secrets (`secrets:`)
- Credenciales inyectadas vía variables de entorno

---

**Repositorio:** `/home/edugonmor/repos/tools`  
**Última actualización:** 29 de noviembre de 2025
