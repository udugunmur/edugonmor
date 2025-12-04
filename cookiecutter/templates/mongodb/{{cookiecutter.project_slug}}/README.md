# 🍃 {{cookiecutter.project_name}}

> MongoDB {{cookiecutter.mongo_version}} - Base de datos NoSQL documental

[![MongoDB](https://img.shields.io/badge/MongoDB-{{cookiecutter.mongo_version}}-green?style=flat-square&logo=mongodb)](https://www.mongodb.com/)
[![Docker](https://img.shields.io/badge/Docker-Compose-blue?style=flat-square&logo=docker)](https://docs.docker.com/compose/)
[![License](https://img.shields.io/badge/License-MIT-yellow?style=flat-square)](LICENSE)

## 📋 Descripción

Proyecto de base de datos MongoDB {{cookiecutter.mongo_version}} containerizada con Docker, incluyendo:
- 🍃 MongoDB {{cookiecutter.mongo_version}} (imagen oficial)
- 🔄 Sistema de backups automáticos con `mongodump`
- 🔒 Configuración segura con variables de entorno
- 📊 Healthchecks integrados

## 🚀 Quick Start

### Requisitos Previos
- Docker >= 24.0
- Docker Compose >= 2.20

### Levantar el Servicio

```bash
# Clonar y entrar al directorio
cd {{cookiecutter.project_slug}}

# Configurar variables de entorno
cp .env.example .env
# Editar .env con tus credenciales

# Levantar servicios
docker compose up -d

# Verificar estado
docker compose ps
```

## 🔌 Conexión

### Cadena de Conexión

```
mongodb://{{cookiecutter.mongo_root_user}}:{{cookiecutter.mongo_root_password}}@localhost:{{cookiecutter.mongo_port}}/{{cookiecutter.mongo_database}}?authSource=admin
```

### Conexión con mongosh

```bash
# Conectar al contenedor
docker exec -it {{cookiecutter.project_slug}}_services mongosh \
  -u {{cookiecutter.mongo_root_user}} \
  -p {{cookiecutter.mongo_root_password}} \
  --authenticationDatabase admin
```

### Conexión desde Aplicación (Node.js)

```javascript
const { MongoClient } = require('mongodb');

const uri = 'mongodb://{{cookiecutter.mongo_root_user}}:{{cookiecutter.mongo_root_password}}@localhost:{{cookiecutter.mongo_port}}/{{cookiecutter.mongo_database}}?authSource=admin';
const client = new MongoClient(uri);

async function run() {
  await client.connect();
  console.log('Connected to MongoDB');
}
```

## 📁 Estructura del Proyecto

```
{{cookiecutter.project_slug}}/
├── config/
│   └── init-data.json           # Configuración inicial
├── docker/
│   ├── scripts/
│   │   ├── backup.sh            # Script de backup
│   │   ├── restore.sh           # Script de restauración
│   │   ├── entrypoint-backup.sh # Entrypoint backup service
│   │   └── init-db.sh           # Inicialización BD
│   ├── backups/                 # Backups locales
│   └── volumes/                 # Datos persistentes
├── .env                         # Variables de entorno
├── .env.example                 # Plantilla de variables
├── Dockerfile                   # Imagen MongoDB
├── Dockerfile.backup            # Imagen backup
├── docker-compose.yml           # Orquestación
├── AGENTS.md                    # Protocolo de desarrollo
└── README.md                    # Este archivo
```

## 🔄 Sistema de Backups

### Backup Automático
Los backups se ejecutan automáticamente según el cron configurado: `{{cookiecutter.cron_schedule}}`

```bash
# Backup manual
docker exec {{cookiecutter.project_slug}}_backup /scripts/backup.sh

# Ver backups disponibles
ls -la docker/backups/
```

### Restauración

```bash
# Restaurar último backup
docker exec -it {{cookiecutter.project_slug}}_backup /scripts/restore.sh

# Restaurar backup específico
docker exec -it {{cookiecutter.project_slug}}_backup /scripts/restore.sh mongodb_backup_20250101_030000.gz
```

### Retención
Los backups se retienen por **{{cookiecutter.backup_retention}} días** antes de ser eliminados automáticamente.

## ⚙️ Configuración

### Variables de Entorno

| Variable | Descripción | Default |
|----------|-------------|---------|
| `MONGO_INITDB_ROOT_USERNAME` | Usuario root | `{{cookiecutter.mongo_root_user}}` |
| `MONGO_INITDB_ROOT_PASSWORD` | Contraseña root | `{{cookiecutter.mongo_root_password}}` |
| `MONGO_INITDB_DATABASE` | Base de datos inicial | `{{cookiecutter.mongo_database}}` |
| `TZ` | Zona horaria | `Europe/Madrid` |

### Puertos

| Puerto | Servicio | Descripción |
|--------|----------|-------------|
| `{{cookiecutter.mongo_port}}` | MongoDB | Conexiones cliente |

## 🧪 Verificación

```bash
# Verificar configuración
docker compose config --quiet && echo "✅ Configuración válida"

# Healthcheck
docker exec {{cookiecutter.project_slug}}_services mongosh --eval "db.adminCommand('ping')"

# Listar bases de datos
docker exec {{cookiecutter.project_slug}}_services mongosh \
  -u {{cookiecutter.mongo_root_user}} \
  -p {{cookiecutter.mongo_root_password}} \
  --authenticationDatabase admin \
  --eval "show dbs"
```

## 🛠️ Comandos Útiles

```bash
# Ver logs
docker compose logs -f {{cookiecutter.project_slug}}_services

# Reiniciar servicios
docker compose restart

# Detener servicios
docker compose down

# Detener y eliminar volúmenes (⚠️ ELIMINA DATOS)
docker compose down -v

# Acceder al shell del contenedor
docker exec -it {{cookiecutter.project_slug}}_services bash
```

## 📚 Documentación

- [MongoDB {{cookiecutter.mongo_version}} Documentation](https://www.mongodb.com/docs/v{{cookiecutter.mongo_version}}/)
- [MongoDB Database Tools](https://www.mongodb.com/docs/database-tools/)
- [Docker MongoDB Official Image](https://hub.docker.com/_/mongo)

## 🤝 Contribuir

1. Lee el archivo `AGENTS.md` para entender el protocolo de desarrollo
2. Sigue el flujo de trabajo de 3 fases
3. Asegúrate de que los tests pasen antes de hacer PR

## 📄 Licencia

Este proyecto está bajo la Licencia MIT - ver el archivo [LICENSE](LICENSE) para más detalles.

---

**Maintainer:** edugonmor  
**Generado con:** [Cookiecutter](https://cookiecutter.readthedocs.io/)
