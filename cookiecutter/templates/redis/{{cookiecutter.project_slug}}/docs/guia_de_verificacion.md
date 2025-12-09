# 🧪 Guía de Verificación y Testing (CI/CD Local)

Esta guía detalla el **flujo maestro** para verificar el funcionamiento correcto de la plantilla Redis.

## 📋 Prerrequisitos
- Docker y Docker Compose instalados.
- Cookiecutter instalados.
- Permisos de sudo (para limpieza de volúmenes persistentes).

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
cookiecutter templates/redis --no-input -f -o output

# Entrar al proyecto generado
cd output/{{cookiecutter.project_slug}}
```

### 3. Despliegue de Servicios
Levanta Redis y el servicio de backups.

```bash
docker compose up -d --build
```
> Observa los logs con `docker compose logs -f` si es necesario.

### 4. Verificación de Funcionamiento
Verifica que Redis responde y la autenticación funciona.

```bash
# Cargar variables para tener REDIS_PASSWORD
source .env

echo "Testeando conexión a Redis..."
# Usamos el contenedor para ejecutar redis-cli (evita necesitarlo en el host)
docker exec -i {{cookiecutter.project_slug}}_services redis-cli -a "$REDIS_PASSWORD" ping
```
> **Resultado esperado:** `PONG`

### 5. Verificación de Backups
Asegúrate de que el contenedor de backup está corriendo.

```bash
docker ps | grep {{cookiecutter.project_slug}}_backup
```
> **Resultado esperado:** El contenedor debe aparecer en la lista (Up).

---

## 🐛 Troubleshooting

### Error de Autenticación (`NOAUTH` o `WRONGPASS`)
*   **Causa:** La contraseña en `.env` no coincide con la configurada en el servidor o el servidor se levantó sin contraseña.
*   **Solución:** Verifica `.env` y asegúrate de que `docker-compose.yml` pasa `--requirepass`.

### Error de Permisos en Volúmenes
*   **Causa:** Problemas de escritura en directorios bind-mount.
*   **Solución:** Revisa los permisos de `docker/volumes/redis_data`. El hook `post_gen_project.py` debería haberlos puesto a 777.
