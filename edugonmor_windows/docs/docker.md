# Docker en Windows

Guía para configurar y usar Docker en Windows.

## Opciones de Instalación

### 1. Docker Desktop (Recomendado)

La opción más fácil para desarrollo en Windows.

**Requisitos:**
- Windows 10/11 Pro, Enterprise o Education
- WSL2 habilitado
- 4GB+ RAM

**Instalación:**
1. Descargar desde [docker.com](https://www.docker.com/products/docker-desktop)
2. Ejecutar instalador
3. Reiniciar Windows
4. Configurar integración con WSL2

### 2. Docker en WSL2

Instalar Docker directamente en una distribución Linux WSL2.

```bash
# Ubuntu/Debian
sudo apt update
sudo apt install docker.io docker-compose-plugin
sudo usermod -aG docker $USER
```

## Configuración de Docker Desktop

### Recursos

Settings → Resources → Advanced:

| Recurso | Recomendado | Mínimo |
|---------|-------------|--------|
| CPUs | 4 | 2 |
| Memory | 8 GB | 4 GB |
| Swap | 2 GB | 1 GB |
| Disk | 60 GB | 20 GB |

### Integración WSL2

Settings → Resources → WSL Integration:
- Habilitar integración con distribución predeterminada
- Habilitar distribuciones específicas según necesidad

### Backend WSL2

Settings → General:
- ✅ Use the WSL 2 based engine

## Comandos Básicos

### Imágenes

```powershell
# Listar imágenes
docker images

# Descargar imagen
docker pull nginx:latest

# Eliminar imagen
docker rmi nginx:latest

# Limpiar imágenes no usadas
docker image prune -a
```

### Contenedores

```powershell
# Listar contenedores
docker ps -a

# Ejecutar contenedor
docker run -d --name mi-nginx -p 8080:80 nginx

# Detener contenedor
docker stop mi-nginx

# Iniciar contenedor
docker start mi-nginx

# Eliminar contenedor
docker rm mi-nginx

# Logs del contenedor
docker logs -f mi-nginx
```

### Volúmenes

```powershell
# Listar volúmenes
docker volume ls

# Crear volumen
docker volume create mi-volumen

# Eliminar volumen
docker volume rm mi-volumen

# Limpiar volúmenes no usados
docker volume prune
```

### Redes

```powershell
# Listar redes
docker network ls

# Crear red
docker network create mi-red

# Conectar contenedor a red
docker network connect mi-red mi-nginx
```

## Docker Compose

### Ejemplo básico

`docker-compose.yml`:

```yaml
version: '3.8'

services:
  web:
    image: nginx:alpine
    ports:
      - "8080:80"
    volumes:
      - ./html:/usr/share/nginx/html

  db:
    image: postgres:15
    environment:
      POSTGRES_PASSWORD: secret
    volumes:
      - db-data:/var/lib/postgresql/data

volumes:
  db-data:
```

### Comandos Compose

```powershell
# Iniciar servicios
docker-compose up -d

# Detener servicios
docker-compose down

# Ver logs
docker-compose logs -f

# Reconstruir
docker-compose up -d --build
```

## Optimización para Windows

### Rendimiento de Archivos

Para mejor rendimiento con volúmenes:

1. **Mejor**: Archivos dentro de WSL2 (`\\wsl$\Ubuntu\home\...`)
2. **Medio**: Volúmenes nombrados de Docker
3. **Peor**: Bind mounts desde Windows (`C:\...`)

### Configuración de Memoria

Limitar memoria de WSL2 para que Docker no consuma todo:

`C:\Users\<usuario>\.wslconfig`:

```ini
[wsl2]
memory=8GB
swap=2GB
```

### Caché de Compose

```yaml
services:
  app:
    build:
      context: .
      cache_from:
        - app:latest
```

## Desarrollo con Docker

### VS Code + Dev Containers

1. Instalar extensión "Dev Containers"
2. Crear `.devcontainer/devcontainer.json`
3. Abrir carpeta en contenedor

### Hot Reload

Para desarrollo con recarga automática:

```yaml
services:
  app:
    volumes:
      - .:/app
      - /app/node_modules  # Excluir node_modules
    environment:
      - CHOKIDAR_USEPOLLING=true  # Para Windows
```

## Solución de Problemas

### Error: "Cannot connect to Docker daemon"

```powershell
# Reiniciar Docker Desktop
# O desde WSL:
sudo service docker start
```

### Error: "Port already in use"

```powershell
# Encontrar proceso usando el puerto
netstat -ano | findstr :8080

# Terminar proceso
taskkill /PID <PID> /F
```

### Limpiar Todo

```powershell
# ⚠️ Elimina TODO
docker system prune -a --volumes
```

### WSL2 consume mucha memoria

```powershell
# Liberar memoria
wsl --shutdown
```
