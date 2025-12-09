# Guía de Verificación - Penpot

## 1. Limpieza de Entorno
**PRERREQUISITO**: Ejecutar todos los comandos desde la raíz del repositorio (ej. `~/repos/edugonmor/`).

Antes de generar nada, asegura un entorno limpio para evitar conflictos o archivos obsoletos:
```bash
# IMPORTANTE: Borrar la carpeta generada anteriormente
# Limpiar contenedores y volúmenes de la ejecución anterior (si existen)
docker compose -f cookiecutter/output/penpot_project/docker-compose.yml down -v 2>/dev/null || true

# Eliminar carpeta con permisos de superusuario (necesario por archivos creados por Docker)
sudo rm -rf cookiecutter/output/penpot_project
```

## 2. Generación Silenciosa (Non-Interactive)
Genera el proyecto de nuevo variables por defecto:
```bash
cookiecutter ./cookiecutter/templates/penpot --output-dir cookiecutter/output --no-input
cd cookiecutter/output/penpot_project
```

## 3. Despliegue de Servicios
Levantar los servicios en segundo plano:
```bash
docker compose up -d --build
```

## 4. Estado de Contenedores y Red
### Contenedores
Ejecutar:
```bash
docker compose ps
```
Verificar que todos están en estado `Up` (o `Up (healthy)` si aplica):
- `{{cookiecutter.project_slug}}_frontend`
- `{{cookiecutter.project_slug}}_backend`
- `{{cookiecutter.project_slug}}_exporter`
- `{{cookiecutter.project_slug}}_backup`

### Puertos
Verificar que el puerto configurado está escuchando en el host:
```bash
netstat -tulpn | grep {{cookiecutter._penpot_port}}
```

## 5. Logs y Conectividad
### Backend y Base de Datos
Verificar que el backend ha inicializado correctamente y conectado a PostgreSQL/Redis:
```bash
docker compose logs penpot_backend | grep -i "welcome to penpot"
```
*Debe aparecer el mensaje "hint=\"welcome to penpot\"". Esto confirma que el backend ha arrancado y conectado con la BBDD.*

### Frontend
Verificar que el servidor web interno ha arrancado:
```bash
docker compose logs penpot_frontend
```
> **Nota:** Es normal que el log de frontend esté vacío o tenga pocas líneas si no ha recibido peticiones. Lo importante es que el puerto 9001 esté escuchando (verificado en paso 4). Si no hay errores ("panic", "fatal") en el log, procede al siguiente paso.

## 6. Acceso y Funcionalidad Web
1.  **Acceso**: Navegar a `{{cookiecutter._penpot_public_uri}}`.
2.  **Carga**: Debe mostrarse la pantalla de Login/Registro.
3.  **Crear Usuario (CLI)**:
    Si el registro está deshabilitado, crear el primer usuario administrador vía CLI:

    docker exec -it {{cookiecutter.project_slug}}_backend python3 manage.py create-profile -e {{cookiecutter._admin_email}} -p "{{cookiecutter._admin_password}}" -n "{{cookiecutter._admin_name}}"
    ```
    *Intentar loguearse con estas credenciales.*

## 7. Persistencia de Datos
1.  Subir un archivo a Penpot o crear un proyecto de prueba.
2.  Reiniciar los contenedores:
    ```bash
    docker compose restart
    ```
3.  Volver a acceder y verificar que el proyecto/archivo sigue ahí.

## 8. Prueba de Backup y Recuperación
### Ejecución Manual
Ejecutar el script de backup dentro del contenedor:
```bash
docker exec {{cookiecutter.project_slug}}_backup sh -c "tar -czf /backup/manual-test-$(date +%s).tar.gz -C /source/data assets"
```

### Verificación en Host
Comprobar que el archivo se ha creado en el directorio del host:
```bash
ls -l {{cookiecutter._host_backup_path}}
```

### Prueba de Cron (Simulación)
Verificar que la tarea de cron está registrada:
```bash
docker exec {{cookiecutter.project_slug}}_backup crontab -l
```
Debe mostrar la línea configurada con `{{cookiecutter._cron_schedule}}`.
