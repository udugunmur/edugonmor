# 🧪 Guía de Verificación y Testing (CI/CD Local) - PostgreSQL

Esta guía detalla los pasos para realizar una prueba completa del ciclo de vida de este proyecto PostgreSQL, desde su generación hasta su eliminación. Cubre generación silenciosa, instalación, pruebas de permisos, backup y limpieza.

## 📋 Prerrequisitos
- **Docker** y **Docker Compose** instalados y corriendo.
- **Cookiecutter** instalado: `pip install cookiecutter`
- Usuario actual con permisos para ejecutar `docker` (sin sudo preferiblemente).

---

## 1. Limpieza de Entorno
Antes de generar nada, asegura un entorno limpio:
```bash
# Limpiar contenedores y volúmenes de la ejecución anterior (si existen)
docker compose -f cookiecutter/output/postgresql_project/docker-compose.yml down -v 2>/dev/null || true
rm -rf cookiecutter/output/postgresql_project
```

## 🛠️ Paso 2: Generación Silenciosa (Non-Interactive)
Genera el proyecto usando los valores por defecto definidos en `cookiecutter.json`. Esto simula un entorno de CI/CD o automatización.

```bash
# Ejecutar desde el directorio que contiene la carpeta 'cookiecutter' (Raíz del repositorio)
cookiecutter ./cookiecutter/templates/postgresql --no-input -f -o cookiecutter/output
```

**Resultado esperado:**
- Se crea el directorio `cookiecutter/output/postgresql_project`.
- No se solicita ninguna confirmación al usuario.

---

## 🚀 Paso 3: Instalación y Prueba de Permisos
Levanta el stack y verifica que el usuario actual tenga control sobre los archivos generados.

```bash
cd cookiecutter/output/postgresql_project

# 1. Verificar permisos de archivos generados
ls -l .env docker-compose.yml

# 2. Levantar servicios
docker compose up -d --build
```

**Resultado esperado:**
- Contenedores `postgresql_project_services` y `postgresql_project_backup` iniciados (`Up`).
- No hay errores de permisos al leer `.env`.

---

## 🏥 Paso 4: Pruebas de Salud (Healthcheck)
Verifica que la base de datos esté aceptando conexiones.

```bash
# Esperar unos segundos a que la DB inicie...
sleep 15

# Verificar estado de los contenedores
docker compose ps

# Comprobar logs si hay reinicios
docker compose logs postgresql_project_services
```

**Healthcheck manual:**
```bash
docker exec -it postgresql_project_services pg_isready -U postgres -d postgres
```
*Debe retornar `accepting connections`.*

---

## 💾 Paso 5: Prueba Funcional y Backup
Ejecuta un backup manual para validar la integración con los scripts y el volumen de backups.

```bash
# Ejecutar script de backup manualmente dentro del contenedor de backup
docker exec postgresql_project_backup /usr/local/bin/backup.sh
```

**Validar creación del archivo:**
```bash
# Listar contenido del volumen de backups (mapeado localmente)
ls -R ../../backups/postgresql_project/
```
*Deberías ver un archivo `.sql.gz` con la fecha actual.*

---

## 📝 Paso 6: Reporte de Resultados

| Paso | Prueba | Estado | Notas |
|------|--------|--------|-------|
| 1 | Generación silenciosa `--no-input` | [ ] | Directorio creado sin prompts |
| 2 | Despliegue `docker compose up` | [ ] | Contenedores 'Up' |
| 3 | Healthcheck (puerto 5432) | [ ] | Connection OK |
| 4 | Backup Manual ejecutado | [ ] | Archivo .sql.gz generado |
| 5 | Permisos de usuario | [ ] | Archivos propiedad de $USER |

---

## 🧹 Paso 7: Limpieza (Teardown)
Borra todo el entorno de prueba.

```bash
# Detener y borrar contenedores y volúmenes anónimos
docker compose down -v

# Salir del directorio
cd ../..

# Borrar directorio generado
rm -rf cookiecutter/output/postgresql_project
```
