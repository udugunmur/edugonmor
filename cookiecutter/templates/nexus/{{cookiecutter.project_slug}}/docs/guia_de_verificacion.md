# 🧪 Guía de Verificación y Testing (CI/CD Local)

Esta guía detalla el **flujo maestro** para verificar el funcionamiento correcto de la plantilla Nexus, asegurando una instalación limpia, configuración automática y pruebas funcionales.

## 📋 Prerrequisitos
- Docker y Docker Compose instalados.
- Cookiecutter instalado (`pip install cookiecutter`).
- Permisos de sudo (para limpieza de volúmenes persistentes).

---

## 🔁 Flujo de Verificación Completo

Sigue estos pasos en orden secuencial para simular un despliegue desde cero.

### 1. Limpieza Total (Reset Factory)
⚠️ **CRÍTICO:** Nexus persiste datos agresivamente en los volúmenes. Para una prueba real, hay que borrarlos físicamente.

```bash
# 1. Parar contenedores y borrar volúmenes asociados
cd output/nexus_project || (cd /home/edugonmor/repos/edugonmor/cookiecutter/output/nexus_project 2>/dev/null)
docker compose down -v 2>/dev/null || true

# 2. Volver a la raíz del repo de templates
cd /home/edugonmor/repos/edugonmor/cookiecutter

# 3. Borrar físicamente los archivos generados y datos persistidos
# Nota: Se usa sudo porque Docker crea archivos propiedad de root dentro de los volúmenes
echo "Limpiando datos antiguos..."
sudo rm -rf output/nexus_project
```

### 2. Generación del Proyecto
Genera una nueva instancia basada en la plantilla actual (sin inputs para usar los valores por defecto).

```bash
mkdir -p output
cookiecutter templates/nexus --no-input -f -o output

# Entrar al proyecto generado
cd output/nexus_project
```

### 3. Despliegue de Servicios
Levanta Nexus y el servicio de backups.

```bash
docker compose up -d --build
```
> Espera unos segundos a que los contenedores arranquen. Observa los logs con `docker compose logs -f nexus_project_services` si deseas ver el progreso del boot de Java (tarda 1-2 minutos).

### 4. Wait-for-Nexus
No puedes configurar nada hasta que la API responda 200 OK.

```bash
echo "Esperando a que Nexus arranque..."
until curl -s -f -o /dev/null http://localhost:8081/service/rest/v1/status; do
    echo -n "."
    sleep 5
done
echo " ¡Nexus UP!"
```

### 5. Configuración Automática (El paso Mágico 🪄)
Este script es **vital**. Realiza las siguientes acciones automáticas:
1.  Espera a que la API esté lista.
2.  Recupera la **password de admin** (ya sea la inicial aleatoria o 'admin123' si es re-deploy).
3.  **ACEPTA EL EULA** automáticamente (Solución al error 403).
4.  Crea el repositorio `docker-hosted`.
5.  Activa el Realm `Docker Bearer Token`.

```bash
chmod +x scripts/setup_nexus.sh
./scripts/setup_nexus.sh
```
> **Resultado esperado:** Debes ver el mensaje `✅ EULA accepted successfully` junto con `Nexus configuration completed`.

### 6. Prueba de Login Docker (Validación Final)
Si el paso 5 funcionó, esto debe ejecutarse sin errores.

```bash
# Login al puerto del Registry (8082 por defecto)
echo "admin123" | docker login localhost:8082 -u admin --password-stdin
```
**Resultado esperado:** `Login Succeeded`

### 7. (Opcional) Prueba Funcional de Push
```bash
docker pull alpine:latest
docker tag alpine:latest localhost:8082/test-alpine:v1
docker push localhost:8082/test-alpine:v1
```

---

## 🐛 Troubleshooting Común

### Error `403 Forbidden` en docker login
*   **Causa:** El EULA no ha sido aceptado.
*   **Solución:** Asegúrate de haber ejecutado `./scripts/setup_nexus.sh`. Este script ahora incluye la llamada a la API `POST /service/rest/v1/system/eula` necesaria para desbloquear el login.

### Error de permisos al borrar carpetas
*   **Causa:** Los contenedores Docker escriben con usuario root en los bind-mounts.
*   **Solución:** Usa `sudo rm -rf output/nexus_project`.
