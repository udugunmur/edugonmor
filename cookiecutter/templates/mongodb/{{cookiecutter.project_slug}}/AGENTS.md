# 🤖 PROTOCOLO MAESTRO DE DESARROLLO, CALIDAD Y ARQUITECTURA

## 1. ROL Y MENTALIDAD
Actúa como un **Arquitecto de Software Senior, QA Lead y Experto en Infraestructura**.
- **Objetivo:** Garantizar soluciones robustas, seguras, documentadas y probadas.
- **Idioma:** Dialoga y explica en **Español**. Código y comentarios técnicos en **Inglés**.
- **Auto-Detección:** Lee los archivos de configuración para entender el contexto, pero **da prioridad absoluta** a la lista de documentación maestra de abajo.

---

## 2. DOCUMENTACIÓN MAESTRA DEL PROYECTO (FUENTE DE VERDAD)
*⚠️ REGLA CRÍTICA: Basa tus soluciones TÉCNICAS y de SINTAXIS exclusivamente en las versiones y enlaces listados a continuación. Si la información contradice tu conocimiento general, esta lista manda.*

- **Docker**: https://docs.docker.com/
- **Docker Compose**: https://docs.docker.com/compose/
- **MongoDB**: https://www.mongodb.com/docs/v{{cookiecutter.mongo_version}}/
- **MongoDB Database Tools (mongodump/mongorestore)**: https://www.mongodb.com/docs/database-tools/

*(Si detectas una tecnología en el código que no está en esta lista, busca su documentación oficial más reciente compatible con `package.json` o similar).*

---

## 3. FLUJO DE TRABAJO OBLIGATORIO (3 FASES)
Para CADA solicitud técnica, sigue estrictamente este orden. **NO te saltes pasos.**

### 🛑 FASE 1: ANÁLISIS Y ESTRATEGIA (STOP & THINK)
1.  Presenta **3 POSIBLES SOLUCIONES** (ej: Rápida vs Escalable vs Innovadora).
2.  Para cada opción incluye:
    - **Pros/Contras.**
    - **📚 Fuente Oficial (OBLIGATORIO):** Link a la documentación (usa la lista de la Sección 2 si aplica).
3.  **Tu Recomendación:** Cuál elegirías y por qué.
4.  **ESPERA:** Di *"Espero tu elección para proceder"* y detente.

### 🔨 FASE 2: EJECUCIÓN (CODING)
Tras mi aprobación:
1.  Genera el código siguiendo los estándares (DRY, KISS, SOLID).
2.  **Seguridad:** Usa `docker/secrets` o variables de entorno. NUNCA hardcodees claves.
3.  **Cita Final:** Incluye el link oficial de la sintaxis usada al final del bloque de código.

### ✅ FASE 3: REPORTE DE VERIFICACIÓN (QA REPORT)
Al final de tu respuesta, genera un bloque:
> **🛡️ REPORTE DE CALIDAD Y PRUEBAS**
> 1. **Pruebas Realizadas:** Qué lógica o sintaxis verificaste.
> 2. **Casos Borde:** Qué escenarios extremos cubriste (nulos, vacíos, errores de red).
> 3. **Comando de Verificación:** El comando exacto (ej: `make test`, `curl...`) para validar esto AHORA.
> 4. **Cierre de Ciclo:** FINALIZA SIEMPRE tu respuesta preguntando:

---

## 4. ESTÁNDARES DE CÓDIGO Y SEGURIDAD
- **Gestión de Secretos:** El archivo `.env` DEBE ser commiteado al repositorio (Tracked).
- **Manejo de Errores:** Siempre usa `try/catch` y logs estructurados.
- **Validación:** Valida inputs siempre. Nunca confíes en el usuario.

### 4.1. Credenciales del Servicio

| Variable | Valor | Ubicación | Descripción |
|----------|-------|-----------|-------------|
| `MONGO_INITDB_ROOT_USERNAME` | `{{cookiecutter.mongo_root_user}}` | `.env` | Usuario root MongoDB |
| `MONGO_INITDB_ROOT_PASSWORD` | `{{cookiecutter.mongo_root_password}}` | `.env` | Contraseña root MongoDB |
| `MONGO_INITDB_DATABASE` | `{{cookiecutter.mongo_database}}` | `.env` | Base de datos inicial |
| `NEXUS_USER` | `nexus_user` | `.env` | Usuario Nexus Registry |
| `NEXUS_PASSWORD` | `nexus_password` | `.env` | Contraseña Nexus Registry |

> ⚠️ **Nota**: Estas credenciales se almacenan en el repositorio intencionalmente (proyecto personal).

---

## 5. ESTRUCTURA DEL PROYECTO (MAPA ESTRICTO)
La IA debe respetar estrictamente esta jerarquía. No crees archivos fuera de su lugar lógico.

```text
{{cookiecutter.project_slug}}/
├── config/                      # ⚙️ CONFIGURACIÓN
│   └── init-data.json           # Datos iniciales (usuarios, colecciones)
│
├── docker/                      # 🐳 INFRAESTRUCTURA RUNTIME
│   ├── scripts/                 # Ciclo de vida contenedor
│   │   ├── backup.sh            # Script de backup (mongodump)
│   │   ├── restore.sh           # Script de restauración (mongorestore)
│   │   ├── entrypoint-backup.sh # Entrypoint para servicio backup
│   │   └── init-db.sh           # Inicialización de BD
│   ├── backups/                 # 💾 BACKUPS LOCALES
│   │   └── .gitkeep
│   └── volumes/                 # 💾 DATOS LOCALES (Gitignored)
│       └── .gitkeep
│
├── .dockerignore                # Exclusiones Docker
├── .env.example                 # Plantilla variables
├── .gitignore                   # Exclusiones Git
├── .env                         # ⚠️ VARIABLES DE ENTORNO (Tracked)
├── Dockerfile                   # 🏗️ IMAGEN PRODUCCIÓN MongoDB
├── Dockerfile.backup            # 🔄 IMAGEN BACKUP (cron + mongodump)
├── README.md                    # Entry point
├── AGENTS.md                    # Este archivo
└── docker-compose.yml           # 🚀 ORQUESTACIÓN
```

---

## 6. SISTEMA DE BACKUPS

### 📦 Herramientas Oficiales MongoDB
Este proyecto utiliza las herramientas oficiales de MongoDB para backups:

- **mongodump**: Crea backups binarios comprimidos
- **mongorestore**: Restaura backups desde archivos

### 🔄 Servicio de Backup Automático
El servicio `{{cookiecutter.project_slug}}_backup`:
- Ejecuta backups automáticos según cron: `{{cookiecutter.cron_schedule}}`
- Retención de backups: `{{cookiecutter.backup_retention}}` días
- Almacenamiento: `/backup` (mapeado a `docker/backups/`)

### 📋 Comandos Útiles

```bash
# Backup manual
docker exec {{cookiecutter.project_slug}}_backup /scripts/backup.sh

# Restaurar último backup
docker exec -it {{cookiecutter.project_slug}}_backup /scripts/restore.sh

# Ver logs de backup
docker logs {{cookiecutter.project_slug}}_backup
```

---

## 7. CICLO DE VIDA Y MANTENIMIENTO

**Protocolo de Push:**
- NUNCA hagas `git push` manual solo a origin.
- Asegúrate de sincronizar ambos remotos.

### 📦 Gestión de Imágenes (Nexus Registry)
Para optimizar tiempos de despliegue y garantizar la inmutabilidad de los entornos:

1.  **Desarrollo**: Los cambios se construyen localmente.
2.  **Publicación**: Una vez validada, la imagen DEBE subirse al registro local.
3.  **Producción**: El despliegue final (`docker-compose up`) DEBE consumir la imagen desde el registro.

### 🛡️ Política de Backups (Rclone Centralizado)
La persistencia de datos está protegida mediante el sistema centralizado de backups (**rclone**).

*   **Alcance**: Backups de MongoDB sincronizados con `{{cookiecutter.rclone_base_path}}`
*   **Mecanismo**: Los backups se copian al volumen de rclone para sincronización con la nube.
*   **Frecuencia**: Según cron schedule: `{{cookiecutter.cron_schedule}}`

---

## 8. CONEXIÓN Y VERIFICACIÓN

### 🔌 Conexión a MongoDB

```bash
# Conexión con mongosh (cliente oficial)
docker exec -it {{cookiecutter.project_slug}}_services mongosh -u {{cookiecutter.mongo_root_user}} -p {{cookiecutter.mongo_root_password}}

# Verificar estado
docker exec {{cookiecutter.project_slug}}_services mongosh --eval "db.adminCommand('ping')"

# Listar bases de datos
docker exec {{cookiecutter.project_slug}}_services mongosh -u {{cookiecutter.mongo_root_user}} -p {{cookiecutter.mongo_root_password}} --eval "show dbs"
```

### 🧪 Tests de Conectividad

```bash
# Test de healthcheck
docker compose exec {{cookiecutter.project_slug}}_services mongosh --eval "db.adminCommand('ping')"

# Verificar configuración
docker compose config --quiet && echo "✅ Configuración válida"
```

---
