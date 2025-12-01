# 🏗️ Plan de Implementación: Nginx Reverse Proxy para Penpot

## 📋 Fase 1: Análisis y Opciones

El objetivo es exponer **Penpot** a través del proxy inverso centralizado `nginx`, asignándole el subdominio `penpot.edugonmor.com`.

### 🔍 Estado Actual
- **Configuración**: Archivos individuales en `config/conf.d/`.
- **Redes**: `docker-compose.yml` conecta a redes externas de cada servicio.

---

### 🚀 Opciones de Arquitectura

#### 🌟 Opción 1: Configuración Estándar (Recomendada)
Seguir el patrón existente en `nginx`.
1.  **Configuración**: Crear `config/conf.d/penpot.conf`.
2.  **Red**: Añadir `penpot_network` a `docker-compose.yml` de Nginx.
3.  **DNS**: Asumimos que `penpot.edugonmor.com` apunta al servidor (wildcard o entrada específica).

- **Pros**:
    - ✅ Consistencia con el resto de servicios.
    - ✅ SSL centralizado (Let's Encrypt).
- **Contras**:
    - Requiere reinicio de Nginx.

---

## 📝 Recomendación
**Opción 1**. Es la única lógica para mantener la coherencia del sistema.

---

## 📅 Siguientes Pasos (Fase 2: Ejecución)
Tras tu aprobación:
1.  **Nginx**:
    - Crear `config/conf.d/penpot.conf` (Proxy a `penpot_frontend:80`).
    - Modificar `docker-compose.yml` para incluir la red `penpot_network`.
2.  **Verificación**:
    - Validar configuración de Nginx.
    - Reiniciar servicio Nginx.
    - Probar acceso (curl/browser).
