# Políticas de Seguridad

## 🔒 Resumen de Seguridad

| Aspecto | Estado | Descripción |
|---------|--------|-------------|
| HTTPS | ✅ Habilitado | Puerto 9443 |
| Privilegios | ✅ Restringidos | `no-new-privileges:true` |
| Red | ✅ Aislada | Red bridge dedicada |
| Credenciales | ✅ Hasheadas | bcrypt |
| Socket Docker | ⚠️ Montado | Necesario para funcionamiento |

## 🔐 Autenticación

### Contraseña de Administrador

```bash
# Generar hash bcrypt
htpasswd -nbB admin "tu_contraseña_segura" | cut -d ":" -f 2
```

## 🛡️ Configuración de Contenedor

### No New Privileges

```yaml
security_opt:
  - no-new-privileges:true
```

## 🌐 Seguridad de Red

### Puertos Expuestos

| Puerto | Protocolo | Uso |
|--------|-----------|-----|
| 9443 | HTTPS | Acceso web seguro (recomendado) |
| 9000 | HTTP | Acceso web sin cifrar |

## 🐳 Seguridad del Docker Socket

### Riesgos

El acceso al Docker socket implica control total sobre Docker del host.

### Mitigaciones

1. Acceso restringido al contenedor de Portainer
2. No-new-privileges habilitado
3. Red aislada

## 📋 Checklist de Seguridad

### Antes del Despliegue

- [ ] Cambiar contraseña por defecto
- [ ] Verificar permisos de archivos
- [ ] Configurar firewall del host

### Mantenimiento Periódico

- [ ] Actualizar imágenes mensualmente
- [ ] Revisar logs de seguridad
- [ ] Verificar integridad de backups
