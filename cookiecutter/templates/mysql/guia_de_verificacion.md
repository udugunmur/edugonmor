# 🧪 Guía de Verificación y Testing (CI/CD Local) - MySQL

Esta guía detalla los pasos para realizar una prueba completa del ciclo de vida de este proyecto MySQL, desde su generación hasta su eliminación. Cubre generación silenciosa, instalación, pruebas de permisos, backup y limpieza.

## 📋 Prerrequisitos
- **Docker** y **Docker Compose** instalados y corriendo.
- **Cookiecutter** instalado: `pip install cookiecutter`
- Usuario actual con permisos para ejecutar `docker` (sin sudo preferiblemente).

---

## 🛠️ Paso 1: Generación Silenciosa (Non-Interactive)
Genera el proyecto usando los valores por defecto definidos en `cookiecutter.json`. Esto simula un entorno de CI/CD o automatización.

```bash
# Ejecutar desde el directorio que contiene la carpeta 'cookiecutter'
cookiecutter ./cookiecutter/templates/mysql --no-input -f -o verification_output
```

**Resultado esperado:**
- Se crea el directorio `verification_output/mysql_project`.
- No se solicita ninguna confirmación al usuario.

---

## 🚀 Paso 2: Instalación y Prueba de Permisos
Levanta el stack y verifica que el usuario actual tenga control sobre los archivos generados.

```bash
cd verification_output/mysql_project

# 1. Verificar permisos de archivos generados
ls -l .env docker-compose.yml

# 2. Levantar servicios
docker compose up -d --build
```

**Resultado esperado:**
- Contenedores `mysql_project_mysql_services` y `mysql_project_backup` iniciados (`Up`).
- No hay errores de permisos al leer `.env`.

---

## 🏥 Paso 3: Pruebas de Salud (Healthcheck)
Verifica que la base de datos esté aceptando conexiones.

```bash
# Esperar unos segundos a que la DB inicie...
sleep 15

# Verificar estado de los contenedores
docker compose ps

# Comprobar logs si hay reinicios
docker compose logs mysql_project_mysql_services
```

**Healthcheck manual:**
```bash
docker exec -it mysql_project_mysql_services healthcheck.sh --connect --innodb_initialized
```
*O alternativamente ping de mysqladmin:*
```bash
docker exec -it mysql_project_mysql_services mysqladmin ping -h localhost -u root -proot_password_dev
```

---

## 💾 Paso 4: Prueba Funcional y Backup
Ejecuta un backup manual para validar la integración con los scripts y el volumen de backups.

```bash
# Ejecutar script de backup manualmente dentro del contenedor de backup
docker exec mysql_project_backup /usr/local/bin/backup.sh
```

**Validar creación del archivo:**
```bash
# Listar contenido del volumen de backups (mapeado localmente)
ls -R ../../rclone/docker/volumes/rclone_local_backup_volumen/mysql_project/mysql/
```
*Deberías ver un archivo `.sql.gz` con la fecha actual.*

---

## 📝 Paso 5: Reporte de Resultados

| Paso | Prueba | Estado | Notas |
|------|--------|--------|-------|
| 1 | Generación silenciosa `--no-input` | [ ] | Directorio creado sin prompts |
| 2 | Despliegue `docker compose up` | [ ] | Contenedores 'Up' |
| 3 | Healthcheck (puerto 3306) | [ ] | Conexión exitosa |
| 4 | Backup Manual ejecutado | [ ] | Archivo .sql.gz generado |
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
rm -rf verification_output/mysql_project
```
