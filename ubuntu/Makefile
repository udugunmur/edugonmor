.PHONY: help setup optimize verify status stable

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

rclone: ## Instala rclone para sincronización cloud (requiere sudo)
	@echo "☁️ Instalando rclone..."
	@sudo ./scripts/install-rclone.sh
	@echo "✅ rclone instalado."

backup-onedrive: ## Ejecuta backup de OneDrive a disco local
	@echo "💾 Ejecutando backup de OneDrive..."
	@./scripts/backup-onedrive.sh
	@echo "✅ Backup completado."

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
