# 🧪 Guía de Verificación y Testing (CI/CD Local) - MongoDB

Esta guía detalla los pasos para realizar una prueba completa del ciclo de vida de este proyecto MongoDB, desde su generación hasta su eliminación. Cubre generación silenciosa, instalación, pruebas de permisos, backup y limpieza.

## 📋 Prerrequisitos
- **Docker** y **Docker Compose** instalados y corriendo.
- **Cookiecutter** instalado: `pip install cookiecutter`
- Usuario actual con permisos para ejecutar `docker` (sin sudo preferiblemente).

---

## 🛠️ Paso 1: Generación Silenciosa (Non-Interactive)
Genera el proyecto usando los valores por defecto definidos en `cookiecutter.json`. Esto simula un entorno de CI/CD o automatización.

```bash
# Ejecutar desde el directorio que contiene la carpeta 'cookiecutter' (Raíz del repositorio)
cookiecutter ./cookiecutter/templates/mongodb --no-input -f -o cookiecutter/output
```

**Resultado esperado:**
- Se crea el directorio `cookiecutter/output/mongodb_project`.
- No se solicita ninguna confirmación al usuario.

---

## 🚀 Paso 2: Instalación y Prueba de Permisos
Levanta el stack y verifica que el usuario actual tenga control sobre los archivos generados.

```bash
cd cookiecutter/output/mongodb_project

# 1. Verificar permisos de archivos generados
ls -l .env docker-compose.yml

# 2. Levantar servicios
docker compose up -d --build
```

**Resultado esperado:**
- Contenedores `mongodb_project_services` y `mongodb_project_backup` iniciados (`Up`).
- No hay errores de permisos al leer `.env`.

---

## 🏥 Paso 3: Pruebas de Salud (Healthcheck)
Verifica que la base de datos esté aceptando conexiones.

```bash
# Esperar unos segundos a que inicie...
sleep 15

# Verificar estado de los contenedores
docker compose ps

# Comprobar logs si hay reinicios
docker compose logs mongodb_project_services
```

**Healthcheck manual:**
```bash
docker exec -it mongodb_project_services mongosh --eval "db.adminCommand('ping')"
```
*Debe retornar `{ ok: 1 }`.*

---

## 💾 Paso 4: Prueba Funcional y Backup
Ejecuta un backup manual para validar la integración con los scripts y el volumen de backups.

```bash
# Ejecutar script de backup manualmente dentro del contenedor de backup
docker exec mongodb_project_backup /usr/local/bin/backup.sh
```

**Validar creación del archivo:**
```bash
# Listar contenido del volumen de backups (mapeado localmente)
# Revisa la ruta en 'volumes' del docker-compose.yml si es diferente.
ls -R ../../backups/mongodb_project/
```
*Deberías ver un archivo `.archive` o `.gz` con la fecha actual.*

---

## 📝 Paso 5: Reporte de Resultados

| Paso | Prueba | Estado | Notas |
|------|--------|--------|-------|
| 1 | Generación silenciosa `--no-input` | [ ] | Directorio creado sin prompts |
| 2 | Despliegue `docker compose up` | [ ] | Contenedores 'Up' |
| 3 | Healthcheck (puerto 27017) | [ ] | Ping OK |
| 4 | Backup Manual ejecutado | [ ] | Archivo de backup generado |
| 5 | Permisos de usuario | [ ] | Archivos propiedad de $USER |

---

## 🧹 Paso 6: Limpieza (Teardown)
Borra todo el entorno de prueba.

```bash
# Detener y borrar contenedores y volúmenes anónimos
docker compose down -v

# Salir del directorio
cd ../..

# Borrar directorio generado
# Limpiar contenedores y volúmenes de la ejecución anterior (si existen)
docker compose -f cookiecutter/output/mongodb_project/docker-compose.yml down -v 2>/dev/null || true
# Eliminar carpeta con permisos de superusuario (necesario por archivos creados por Docker)
sudo rm -rf cookiecutter/output/mongodb_project
```
