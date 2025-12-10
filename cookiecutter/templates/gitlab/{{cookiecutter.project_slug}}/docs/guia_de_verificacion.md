# 🧪 Guía de Verificación y Testing (CI/CD Local)

Esta guía detalla el **flujo maestro** para verificar el funcionamiento correcto de la plantilla GitLab.

## 📋 Prerrequisitos
- Docker y Docker Compose instalados.
- Cookiecutter instalados.
- Permisos de sudo (para limpieza de volúmenes persistentes si es necesario).

---

## 🔁 Flujo de Verificación Completo

Sigue estos pasos en orden secuencial para simular un despliegue desde cero.

### 1. Preparación de Variables
Define el slug del proyecto para usar en los comandos siguientes.

```bash
export PROJECT_SLUG="<nombre_del_proyecto>"
export HOST_BACKUP_PATH="./backups" # Ajustar según configuración
```

### 2. Limpieza de Entorno
⚠️ **CRÍTICO:** Borrar volúmenes y contenedores anteriores.

```bash
# 1. Parar contenedores y borrar volúmenes asociados
cd output/$PROJECT_SLUG || (cd /home/edugonmor/repos/edugonmor/cookiecutter/output/$PROJECT_SLUG 2>/dev/null)
docker compose down -v 2>/dev/null || true

# 2. Volver a la raíz del repo de templates
cd /home/edugonmor/repos/edugonmor/cookiecutter

# 3. Borrar físicamente los archivos generados y datos persistidos
# Usamos sudo para evitar problemas de permisos con root
sudo rm -rf output/$PROJECT_SLUG
```

### 3. Generación del Proyecto
Genera una nueva instancia basada en la plantilla actual.

```bash
mkdir -p output
cookiecutter templates/gitlab --no-input -f -o output

# Entrar al proyecto generado
cd output/$PROJECT_SLUG
```

### 4. Despliegue de Servicios
Levanta GitLab y el servicio de backups. Esto puede tardar varios minutos la primera vez.

```bash
docker compose up -d
```
> Observa los logs con `docker compose logs -f` para ver el progreso de la inicialización de GitLab. Busca "GitLab was successfully installed".

### 5. Verificación de Funcionamiento
Verifica que GitLab responde.

```bash
# Cargar variables para tener los puertos
source .env

echo "Esperando a que GitLab esté listo (puede tardar unos minutos)..."
# Loop simple para chequear status
for i in {1..30}; do
    if curl -s -o /dev/null -w "%{http_code}" http://localhost:${GITLAB_HTTP_PORT}/users/sign_in | grep -q "200"; then
        echo "✅ GitLab está respondiendo en el puerto ${GITLAB_HTTP_PORT}"
        break
    fi
    echo "⏳ Esperando..."
    sleep 10
done
```

### 6. Verificación Profunda de Salud (Health Check)
Verifica que los endpoints de salud internos estén OK.

```bash
docker exec ${PROJECT_SLUG}_gitlab_services curl -s http://localhost:80/-/readiness  | grep '"status":"ok"'
```
> **Resultado esperado:** JSON con status ok.

### 7. Verificación de Puerto SSH
Asegúrate de que el puerto SSH mapeado está accesible.

```bash
python3 -c "import socket; s=socket.socket(); s.settimeout(3); result=s.connect_ex(('localhost', int('${GITLAB_SSH_PORT}'))); exit(result)" && echo "✅ Port ${GITLAB_SSH_PORT} is open"
```
> **Resultado esperado:** ✅ Port ... is open

### 8. Verificación de Backups
Prueba la ejecución manual de un backup completo utilizando el servicio de backup configurado.

```bash
# 1. Verificar que el servicio de backup está activo
docker ps | grep ${PROJECT_SLUG}_backup

# 2. Ejecutar backup manualmente (esto simula lo que hace el Cron)
# Nota: Instalamos docker-cli si no está presente (caso de prueba manual directa) o usamos el comando definido
docker exec ${PROJECT_SLUG}_backup sh -c "apk add --no-cache docker-cli && docker exec ${PROJECT_SLUG}_gitlab_services gitlab-backup create SKIP=artifacts,registry"

# 3. Verificar que el archivo de backup (.tar) se ha generado en el host
# Usamos docker para listar el archivo ya que puede tener permisos restrictivos (usuario git)
docker run --rm -v "$(pwd)/${HOST_BACKUP_PATH}:/backups" alpine ls -lh /backups/*.tar
```

### 9. Persistencia de Datos
Verifica que los datos persisten tras un reinicio.

```bash
docker compose restart ${PROJECT_SLUG}_gitlab_services
# Repetir paso 4 tras unos minutos
```

---

## 🐛 Troubleshooting

### Timeout o 502 Bad Gateway inicial
*   **Causa:** GitLab tarda bastante en arrancar (Unicorn/Puma).
*   **Solución:** Espera unos minutos más. Revisa los logs con `docker compose logs -f`.

### Problemas de Permisos en Volúmenes
*   **Causa:** Docker no puede escribir en los directorios mapeados.
*   **Solución:** Verifica que `docker/volumes` tenga permisos adecuados (el hook `post_gen_project.py` debería encargarse de esto).
