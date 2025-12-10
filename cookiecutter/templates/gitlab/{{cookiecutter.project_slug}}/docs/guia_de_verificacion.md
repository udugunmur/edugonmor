# 🧪 Guía de Verificación y Testing (CI/CD Local)

Esta guía detalla el **flujo maestro** para verificar el funcionamiento correcto de la plantilla GitLab.

## 📋 Prerrequisitos
- Docker y Docker Compose instalados.
- Cookiecutter instalados.
- Permisos de sudo (para limpieza de volúmenes persistentes si es necesario).

---

## 🔁 Flujo de Verificación Completo

Sigue estos pasos en orden secuencial para simular un despliegue desde cero.

### 1. Limpieza de Entorno
⚠️ **CRÍTICO:** Borrar volúmenes y contenedores anteriores.

```bash
# 1. Parar contenedores y borrar volúmenes asociados
cd output/{{cookiecutter.project_slug}} || (cd /home/edugonmor/repos/edugonmor/cookiecutter/output/{{cookiecutter.project_slug}} 2>/dev/null)
docker compose down -v 2>/dev/null || true

# 2. Volver a la raíz del repo de templates
cd /home/edugonmor/repos/edugonmor/cookiecutter

# 3. Borrar físicamente los archivos generados y datos persistidos
echo "Limpiando datos antiguos..."
sudo rm -rf output/{{cookiecutter.project_slug}}
```

### 2. Generación del Proyecto
Genera una nueva instancia basada en la plantilla actual.

```bash
mkdir -p output
cookiecutter templates/gitlab --no-input -f -o output

# Entrar al proyecto generado
cd output/{{cookiecutter.project_slug}}
```

### 3. Despliegue de Servicios
Levanta GitLab y el servicio de backups. Esto puede tardar varios minutos la primera vez.

```bash
docker compose up -d
```
> Observa los logs con `docker compose logs -f` para ver el progreso de la inicialización de GitLab. Busca "GitLab was successfully installed".

### 4. Verificación de Funcionamiento
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

### 5. Verificación Profunda de Salud (Health Check)
Verifica que los endpoints de salud internos estén OK.

```bash
docker exec {{cookiecutter.project_slug}}_gitlab_services curl -s http://localhost:80/ -/readiness  | grep '"status":"ok"'
```
> **Resultado esperado:** JSON con status ok.

### 6. Verificación de Puerto SSH
Asegúrate de que el puerto SSH mapeado está accesible.

```bash
nc -zv localhost ${GITLAB_SSH_PORT}
```
> **Resultado esperado:** Connection to localhost port ... [tcp/*] succeeded!

### 7. Verificación de Backups
Prueba la ejecución manual de un backup simulado (la lógica de backup real puede depender de scripts en el host o contenedor).

```bash
# Verificar que el servicio está activo
docker ps | grep {{cookiecutter.project_slug}}_backup

# Forzar una prueba de escritura en el volumen de backup para asegurar permisos
docker exec {{cookiecutter.project_slug}}_backup touch /backups/test_write.txt && echo "✅ Escritura en volumen de backups OK" || echo "❌ Fallo escritura backups"
ls -l {{cookiecutter._host_backup_path}}/test_write.txt
```

### 8. Persistencia de Datos
Verifica que los datos persisten tras un reinicio.

```bash
docker compose restart {{cookiecutter.project_slug}}_gitlab_services
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
