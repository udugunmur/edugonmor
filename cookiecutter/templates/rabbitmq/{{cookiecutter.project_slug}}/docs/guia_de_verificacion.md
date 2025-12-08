# 🧪 Guía de Verificación y Testing (CI/CD Local)

Esta guía detalla el **flujo maestro** para verificar el funcionamiento correcto de la plantilla RabbitMQ, asegurando una instalación limpia, configuración automática y pruebas funcionales.

## 📋 Prerrequisitos
- Docker y Docker Compose instalados.
- Cookiecutter instalado (`pip install cookiecutter`).
- Permisos de sudo (para limpieza de volúmenes persistentes).

---

## 🔁 Flujo de Verificación Completo

Sigue estos pasos en orden secuencial para simular un despliegue desde cero.

### 1. Limpieza Total (Reset Factory)
⚠️ **CRÍTICO:** RabbitMQ persiste datos en los volúmenes. Para una prueba real, hay que borrarlos físicamente.

```bash
# 1. Parar contenedores y borrar volúmenes asociados
cd output/rabbitmq_service || (cd /home/edugonmor/repos/edugonmor/cookiecutter/output/rabbitmq_service 2>/dev/null)
docker compose down -v 2>/dev/null || true

# 2. Volver a la raíz del repo de templates
cd /home/edugonmor/repos/edugonmor/cookiecutter

# 3. Borrar físicamente los archivos generados y datos persistidos
# Nota: Se usa sudo porque Docker crea archivos propiedad de root dentro de los volúmenes
echo "Limpiando datos antiguos..."
sudo rm -rf output/rabbitmq_service
```

### 2. Generación del Proyecto
Genera una nueva instancia basada en la plantilla actual (sin inputs para usar los valores por defecto).

```bash
mkdir -p output
cookiecutter templates/rabbitmq --no-input -f -o output

# Entrar al proyecto generado
cd output/rabbitmq_service
```

### 3. Despliegue de Servicios
Levanta RabbitMQ.

```bash
docker compose up -d --build
```
> Espera unos segundos a que los contenedores arranquen. Observa los logs con `docker compose logs -f {{cookiecutter.project_slug}}`.

### 4. Wait-for-RabbitMQ
No puedes configurar nada hasta que la API responda.

```bash
echo "Esperando a que RabbitMQ arranque..."
until curl -s -f -o /dev/null http://localhost:{{cookiecutter._rabbitmq_management_port}}/api/overview -u {{cookiecutter._rabbitmq_user}}:{{cookiecutter._rabbitmq_password}}; do
    echo -n "."
    sleep 5
done
echo " ¡RabbitMQ UP!"
```

### 5. Verificación de Acceso y Configuración
Este script verifica que el servicio esté operativo y las credenciales sean correctas.

```bash
chmod +x scripts/setup_rabbitmq.sh
./scripts/setup_rabbitmq.sh
```
> **Resultado esperado:** Debes ver el mensaje `✅ RabbitMQ is ready and accessible`.

### 6. Prueba Funcional (Manual)
Puedes acceder al panel de administración en:
`http://localhost:{{cookiecutter._rabbitmq_management_port}}`
Usuario: `{{cookiecutter._rabbitmq_user}}`
Password: `{{cookiecutter._rabbitmq_password}}`

---

## 🐛 Troubleshooting Común

### Error `Connection refused`
*   **Causa:** El contenedor no ha terminado de arrancar o el puerto está ocupado.
*   **Solución:** Revisa los logs con `docker compose logs`.

### Error de permisos al borrar carpetas
*   **Causa:** Los contenedores Docker escriben con usuario root/999 en los bind-mounts.
*   **Solución:** Usa `sudo rm -rf output/rabbitmq_service`.
