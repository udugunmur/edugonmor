# 📋 Guía de Verificación - {{cookiecutter._project_name}}

## Pasos para Verificar la Plantilla MongoDB

### 1. Crear directorio de salida para backups (requerido por el volumen)

```bash
mkdir -p {{cookiecutter._rclone_base_path}}/{{cookiecutter.project_slug}}
```

### 2. Crear directorio de volumen de datos

```bash
mkdir -p docker/volumes/{{cookiecutter.project_slug}}_volumen
```

### 3. Verificar sintaxis de docker-compose

```bash
docker compose config --quiet && echo "✅ MongoDB docker-compose OK"
```

### 4. Construir y levantar servicios

```bash
docker compose up -d --build
```

### 5. Verificar conexión a MongoDB

```bash
docker exec {{cookiecutter.project_slug}}_services mongosh --eval "db.adminCommand('ping')"
```

### 6. Verificar que el usuario tiene permisos root

```bash
docker exec {{cookiecutter.project_slug}}_services mongosh -u {{cookiecutter._mongo_root_user}} -p {{cookiecutter._mongo_root_password}} --authenticationDatabase admin --eval "db.adminCommand({listDatabases: 1})"
```

### 7. Probar backup manual

```bash
docker exec {{cookiecutter.project_slug}}_backup /usr/local/bin/backup.sh
```

### 8. Verificar archivo de backup creado

```bash
ls -la {{cookiecutter._rclone_base_path}}/{{cookiecutter.project_slug}}/
```

---

## 🔧 Si hay errores

**Error de volumen no encontrado:**
```bash
# Crear directorios manualmente
mkdir -p docker/volumes/{{cookiecutter.project_slug}}_volumen
mkdir -p {{cookiecutter._rclone_base_path}}/{{cookiecutter.project_slug}}
```

**Error de red no encontrada:**
```bash
docker network create {{cookiecutter._network_name}}
```

---

## 🧪 Comandos de Prueba Adicionales

### Listar bases de datos
```bash
docker exec {{cookiecutter.project_slug}}_services mongosh -u {{cookiecutter._mongo_root_user}} -p {{cookiecutter._mongo_root_password}} --authenticationDatabase admin --eval "show dbs"
```

### Ver logs del servicio
```bash
docker compose logs -f {{cookiecutter.project_slug}}_services
```

### Ver logs del backup
```bash
docker compose logs -f {{cookiecutter.project_slug}}_backup
```

### Detener servicios
```bash
docker compose down
```

### Detener y eliminar volúmenes (⚠️ ELIMINA DATOS)
```bash
docker compose down -v
```
