.PHONY: help setup optimize verify status stable rclone rclone-config rclone-mount rclone-sync

help: ## Muestra esta ayuda
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'

setup: ## Ejecuta configuración inicial del sistema (requiere sudo)
	@echo "🔧 Ejecutando configuración inicial..."
	@sudo ./scripts/setup.sh
	@echo "✅ Configuración completada."

optimize: ## Optimiza rendimiento del sistema (requiere sudo)
	@echo "⚡ Optimizando sistema..."
	@sudo ./scripts/optimize.sh
	@echo "✅ Optimización completada."

vnc: ## Habilita servidor VNC (requiere sudo)
	@echo "🖥️ Configurando VNC..."
	@sudo ./scripts/enable-vnc.sh
	@echo "✅ VNC configurado."

verify: ## Verifica estado de la configuración
	@echo "🔍 Verificando configuración..."
	@./scripts/verify.sh

status: ## Muestra estado actual del sistema
	@echo "📊 Estado del sistema:"
	@echo ""
	@echo "=== Suspensión ==="
	@systemctl is-enabled sleep.target 2>/dev/null || echo "sleep.target: masked"
	@echo ""
	@echo "=== CPU Governor ==="
	@cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor 2>/dev/null || echo "No disponible"
	@echo ""
	@echo "=== GNOME Lock Screen ==="
	@gsettings get org.gnome.desktop.screensaver lock-enabled 2>/dev/null || echo "No disponible"
	@echo ""
	@echo "=== Rclone ==="
	@rclone version 2>/dev/null | head -1 || echo "No instalado"
	@echo ""
	@echo "=== Montajes Rclone ==="
	@mountpoint /mnt/disk2/rclone/gdrive 2>/dev/null && echo "GDrive: montado" || echo "GDrive: no montado"
	@mountpoint /mnt/disk2/rclone/onedrive 2>/dev/null && echo "OneDrive: montado" || echo "OneDrive: no montado"

# ------------------------------------------------------------------------------
# RCLONE - Sincronización con la nube
# ------------------------------------------------------------------------------

rclone: ## Instala rclone y dependencias (requiere sudo)
	@echo "☁️ Instalando rclone..."
	@sudo ./scripts/install-rclone.sh
	@echo "✅ Rclone instalado."

rclone-config: ## Configura remotos de rclone (GDrive, OneDrive)
	@echo "⚙️ Configurando remotos rclone..."
	@./scripts/configure-rclone.sh

rclone-mount: ## Habilita servicios de montaje automático (requiere sudo)
	@echo "📁 Habilitando montajes rclone..."
	@sudo ./scripts/enable-rclone-mount.sh
	@echo "✅ Montajes habilitados."

rclone-sync: ## Sincroniza configuración de rclone con proyecto Docker
	@echo "🔄 Sincronizando configuración..."
	@./scripts/sync-rclone-config.sh
	@echo "✅ Configuración sincronizada."

# ------------------------------------------------------------------------------
# SINCRONIZACIÓN CON REPOSITORIO REMOTO
# ------------------------------------------------------------------------------
REPO_NAME ?= $(shell basename $(CURDIR))

stable: ## Push a repositorio remoto
	@echo "🚀 Iniciando protocolo de despliegue estable..."
	@echo "📦 Repositorio: $(REPO_NAME)"
	git add .
	git commit -m "chore: sync $(REPO_NAME)" || true
	git push origin main
	@echo "✅ Despliegue estable completado."
