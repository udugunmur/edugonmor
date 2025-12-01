.PHONY: help setup setup-minimal verify status stable chrome vnc rclone backup-onedrive

help: ## Muestra esta ayuda
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'

# ------------------------------------------------------------------------------
# CONFIGURACIÓN DEL SISTEMA
# ------------------------------------------------------------------------------

setup: ## Ejecuta configuración inicial completa del sistema (requiere sudo)
	@echo "🔧 Ejecutando configuración inicial..."
	@sudo ./scripts/setup.sh --full
	@echo "✅ Configuración completada."

setup-minimal: ## Ejecuta solo configuración de energía (requiere sudo)
	@echo "⚡ Aplicando configuración mínima..."
	@sudo ./scripts/setup.sh --minimal
	@echo "✅ Configuración mínima completada."

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
# INSTALACIÓN DE SOFTWARE
# ------------------------------------------------------------------------------

chrome: ## Instala Google Chrome desde repositorio oficial (requiere sudo)
	@echo "🌐 Instalando Google Chrome..."
	@sudo ./scripts/install/install-chrome.sh
	@echo "✅ Chrome instalado."

vnc: ## Habilita servidor VNC para acceso remoto (requiere sudo)
	@echo "🖥️ Configurando VNC..."
	@sudo ./scripts/install/configure-vnc-server.sh
	@echo "✅ VNC configurado."

rclone: ## Instala rclone para sincronización cloud (requiere sudo)
	@echo "☁️ Instalando rclone..."
	@sudo ./scripts/install/install-rclone.sh
	@echo "✅ rclone instalado."

# ------------------------------------------------------------------------------
# BACKUP Y UTILIDADES
# ------------------------------------------------------------------------------

backup-onedrive: ## Ejecuta backup de OneDrive a disco local
	@echo "💾 Ejecutando backup de OneDrive..."
	@./scripts/backup/backup-onedrive.sh
	@echo "✅ Backup completado."

# ------------------------------------------------------------------------------
# SINCRONIZACIÓN CON REPOSITORIO REMOTO
# ------------------------------------------------------------------------------
REPO_NAME ?= $(shell basename $(CURDIR))

stable: ## Push a repositorio remoto
	@echo "🚀 Iniciando protocolo de despliegue estable..."
	@echo "📦 Repositorio: $(REPO_NAME)"
	git add .
	git commit -m "chore: sync $(REPO_NAME)" || true
	git push origin master
	@echo "✅ Despliegue estable completado."
