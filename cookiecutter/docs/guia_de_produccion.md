# Guía de Despliegue y Producción

Este documento define qué significa "Producción" para el proyecto Cookiecutter y cómo gestionar el ciclo de vida de liberación bajo el **Protocolo Maestro**.

## 1. Concepto de Producción

A diferencia de una aplicación web o un microservicio, una plantilla Cookiecutter **no se despliega en un servidor**.

*   **Artefacto de Producción**: El código fuente en la rama `main` (o tags específicos) del repositorio remoto.
*   **Entorno de Ejecución**: La máquina local del usuario final que invoca la plantilla.

> **Nota Arquitectónica**: El directorio `.devcontainer` y los tests son herramientas de manufactura. No forman parte del producto final que consume el usuario, aunque viajan con el código.

## 2. Flujo de Trabajo de Publicación

El paso de Desarrollo a Producción sigue este pipeline estricto:

### Fase A: Validación (Local)
Dentro del Dev Container:
1.  Ejecutar suite de pruebas: `pytest`
2.  Generar proyecto de prueba manual: `cookiecutter .`
3.  Verificar que el proyecto generado cumple los estándares.

### Fase B: Versionado (Git)
Usamos **Semantic Versioning** (vX.Y.Z) para marcar releases estables.

```bash
# 1. Commit de cambios
git add .
git commit -m "feat: añade soporte para python 3.12"

# 2. Crear Tag de versión
git tag v1.0.0

# 3. Subir a Producción (GitHub/GitLab)
git push origin main --tags
```

## 3. Consumo en Producción

El usuario final (o tú en otro contexto) utiliza la plantilla directamente desde la fuente oficial.

### Comando Estándar
```bash
cookiecutter https://github.com/edugonmor/cookiecutter.git
```

### Comando para Versión Específica
Para garantizar reproducibilidad en entornos corporativos, se recomienda apuntar a un tag específico:
```bash
cookiecutter https://github.com/edugonmor/cookiecutter.git --checkout v1.0.0
```

## 4. Mantenimiento

*   **Hotfixes**: Crear rama desde el tag afectado -> Corregir -> Nuevo Tag (v1.0.1).
*   **Breaking Changes**: Requieren incremento de versión mayor (v2.0.0) y actualización de documentación.

---
**Generado bajo Protocolo Maestro - Edugonmor**
