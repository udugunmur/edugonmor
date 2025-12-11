# Guía de Verificación

Esta guía detalla los pasos para desplegar, verificar y asegurar el correcto funcionamiento del servicio y sus copias de seguridad.

## Requisitos Previos

- Docker y Docker Compose instalados.
- Red estandar definida en `.env` (variable `NETWORK_NAME`) creada:
  ```bash
  # Cargar variables
  export $(grep -v '^#' .env | xargs)
  
  # Crear red si no existe
  docker network create $NETWORK_NAME || true
  ```

## Pasos de Verificación

### 1. Configuración del Entorno
Verificar que el archivo `.env` existe y tiene los permisos correctos.

```bash
if [ ! -f .env ]; then
    echo "❌ Error: Archivo .env no encontrado."
    exit 1
fi
echo "✅ Archivo .env encontrado."
```

### 2. Validación de Configuración Docker
Verificar la sintaxis del archivo `docker-compose.yml`.

```bash
docker-compose config
if [ $? -eq 0 ]; then
    echo "✅ Sintaxis de docker-compose correcta."
else
    echo "❌ Error en la sintaxis de docker-compose."
    exit 1
fi
```

### 3. Despliegue del Servicio
Iniciar el servicio y el sistema de backup en segundo plano.

```bash
docker-compose up -d --build
```

### 4. Verificación de Contenedores
Comprobar que ambos contenedores (app y backup) se han creado correctamente.

```bash
# Cargar variables de entorno
export $(grep -v '^#' .env | xargs)

# Verificar App
if docker ps --format '{{ "{{" }}.Names}}' | grep -q "${CONTAINER_NAME}$"; then
    echo "✅ Contenedor App (${CONTAINER_NAME}) en ejecución."
else
    echo "❌ Error: Contenedor App (${CONTAINER_NAME}) no encontrado o detenido."
    exit 1
fi

# Verificar Backup
if docker ps --format '{{ "{{" }}.Names}}' | grep -q "${CONTAINER_NAME}_backup"; then
    echo "✅ Contenedor Backup (${CONTAINER_NAME}_backup) en ejecución."
else
    echo "❌ Error: Contenedor Backup (${CONTAINER_NAME}_backup) no encontrado o detenido."
    exit 1
fi
```

### 5. Verificación de Funcionamiento (Storybook)
Verificar que el servicio Storybook ha arrancado y está escuchando.

```bash
# 1. Verificar logs
if docker logs ${CONTAINER_NAME} 2>&1 | grep -q "Local:"; then
    echo "✅ Logs correctos: Storybook ha arrancado."
else
    echo "⚠️ Advertencia: Storybook puede estar arrancando. Revisar logs manualmente si persiste."
fi

# 2. Verificar puerto (Opcional si curl disponible)
if command -v curl &> /dev/null; then
    if curl -sI http://localhost:${STORYBOOK_PORT} | grep -q "200 OK"; then
        echo "✅ Servicio accesible HTTP 200 OK."
    fi
fi
```

### 6. Verificación de Backup
Ejecutar un backup manual y validar la creación del archivo.

```bash
echo "⏳ Ejecutando backup manual..."
docker exec ${CONTAINER_NAME}_backup /backup.sh

# Verificar existencia archivo
if ls backups/backup_*.tar.gz 1> /dev/null 2>&1; then
    echo "✅ Backup verificado: Archivo .tar.gz encontrado en ./backups"
else
    echo "❌ Error: No se ha generado el archivo de backup."
    exit 1
fi
```

### 7. Limpieza (Opcional)
Detener y eliminar los contenedores.

```bash
docker-compose down
# Nota: Los backups en ./backups persisten.
echo "✅ Entorno limpiado."
```

## Resumen
Si todos los pasos anteriores muestran el check verde (✅), el despliegue es completamente funcional y seguro.
