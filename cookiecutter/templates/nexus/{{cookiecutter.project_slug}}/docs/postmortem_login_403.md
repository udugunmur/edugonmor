# 🐛 Postmortem: Error 403 Forbidden en Docker Login

**Fecha:** 2025-12-07  
**Estado:** Resuelto ✅

## 🚨 El Problema
Durante las pruebas de verificación del despliegue automatizado de Nexus, el paso de **login al registro privado de Docker** fallaba consistentemente con el siguiente error:

```bash
$ docker login localhost:8082 -u admin -p admin123
Error response from daemon: login attempt to http://localhost:8082/v2/ failed with status: 403 Forbidden
```

A pesar de que:
- Las credenciales (`admin` / `admin123`) eran correctas.
- El repositorio `docker-hosted` estaba creado.
- El Realm `Docker Bearer Token` estaba activo.
- La opción `forceBasicAuth` estaba habilitada/deshabilitada (se probaron ambas).

## 🔍 Causa Raíz
Tras investigar los logs y respuestas crudas de la API (usando `curl -v`), se descubrió que el bloqueo **no era de autenticación ni de autorización de roles**, sino un bloqueo sistémico por la **falta de aceptación del EULA (End User License Agreement)**.

Al consultar la API directamente, Nexus devolvía un cuerpo de mensaje que el cliente de Docker ocultaba:
```text
You must accept the End User License Agreement (EULA) through the onboarding wizard or REST API before proceeding.
```

El Wizard de "Onboarding" que aparece en la UI web bloquea ciertas funcionalidades críticas (como el login de Docker) hasta que se completa o se descarta.

## 🛠️ La Solución implementada
Se intentó desactivar el wizard mediante propiedades de sistema (`-Dnexus.onboarding.enabled=false`), pero no surtió efecto en la versión actual.

La solución definitiva y robusta fue **automatizar la aceptación del EULA** dentro del script de aprovisionamiento `setup_nexus.sh`.

### Lógica añadida al scipt `scripts/setup_nexus.sh`:
1. Se consulta el estado del EULA vía API REST: `GET /service/rest/v1/system/eula`.
2. Si `accepted` es `false`, se modifica el JSON para ponerlo en `true`.
3. Se envía la aceptación vía `POST`.

```bash
# Ejemplo simplificado de la corrección
curl -u admin:password -X POST "$NEXUS_URL/service/rest/v1/system/eula" \
    -H "Content-Type: application/json" \
    -d '{"accepted": true}'
```

Esta acción libera el bloqueo y permite que el `docker login` funcione correctamente de inmediato.
