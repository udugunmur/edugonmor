# 🤖 GitHub Copilot Instructions - Edugonmor Infrastructure

## 📋 Visión General del Proyecto
Este repositorio contiene configuraciones de infraestructura DevOps para múltiples servicios. Cada servicio tiene su propia carpeta con docker-compose, documentación y archivos de configuración.

## 🌐 Idioma
- **Documentación y comentarios**: Español
- **Código y nombres de variables**: Inglés

## 📂 Estructura del Repositorio

```
edugonmor/
├── bookstack/          # Wiki interna
├── cookiecutter/       # Plantillas de proyectos
├── gitlab/             # Configuración GitLab
├── mongodb/            # Base de datos MongoDB
├── nexus/              # Registry de artefactos
├── nginx/              # Proxy reverso
├── penpot/             # Diseño UI/UX
├── postgresql/         # Base de datos PostgreSQL
├── rabbitmq/           # Message broker
├── rclone/             # Backup a la nube
├── redis/              # Cache en memoria
├── storybook/          # Documentación de componentes
├── template_mariadb/   # Plantilla MariaDB
├── tools/              # Herramientas auxiliares
├── ubuntu/             # Configuración Ubuntu
├── widgetbook/         # Componentes Flutter
└── windows/            # Scripts Windows
```

## 📚 Archivos Importantes por Servicio

Cada servicio sigue esta estructura:
- `agent.md` - Instrucciones específicas para el agente IA (LEER SIEMPRE PRIMERO)
- `README.md` - Documentación principal del servicio
- `docker-compose.yml` - Orquestación base
- `docker-compose.override.yml` - Configuración de desarrollo (tracked)
- `docker-compose.prod.yml` - Configuración de producción
- `.env` - Variables de entorno (tracked intencionalmente)

## ⚠️ Reglas Críticas

### Gestión de Secretos
- El archivo `.env` SE COMMITEA al repositorio (decisión intencional - proyecto personal)
- Los secretos MÁS sensibles (como contraseñas de producción) van en `docker/secrets/`
- NUNCA hardcodear contraseñas directamente en docker-compose.yml u otros archivos de configuración - usar siempre variables de entorno o archivos de secretos

### Flujo de Trabajo
1. Antes de cualquier cambio, LEE el `agent.md` del servicio
2. Presenta 3 opciones de solución con pros/contras
3. Espera aprobación antes de implementar
4. Incluye el reporte de pruebas al finalizar

### Convenciones de Código
- Sigue los estándares DRY, KISS, SOLID
- Usa manejo de errores con try/catch
- Valida siempre los inputs del usuario
- Incluye logs estructurados

## 🔧 Comandos Comunes

```bash
# Levantar un servicio
cd <servicio>
docker compose up -d

# Ver logs
docker compose logs -f

# Verificar estado
docker compose ps
```

## 📦 Registro de Imágenes

Las imágenes se publican en Nexus Registry:
- URL: `nexus.edugonmor.com/repository/docker-hosted`
- El deploy en producción CONSUME imágenes del registry

## 🛡️ Backups

Todos los servicios usan el sistema centralizado de backup con **rclone**:
- Los volúmenes se montan en modo lectura `:ro`
- Las copias se sincronizan automáticamente a la nube

## 📖 Documentación de Referencia

- **Docker**: https://docs.docker.com/
- **Docker Compose**: https://docs.docker.com/compose/
- Consultar la documentación específica de cada servicio en su `agent.md`

---
**Última actualización**: Diciembre 2024
