.PHONY: help setup test clean

help: ## Muestra esta ayuda
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'

setup: ## Ejecuta la configuración inicial
	@echo "Ejecutando setup de Windows..."
	@powershell.exe -ExecutionPolicy Bypass -File scripts/setup.ps1

optimize: ## Ejecuta optimización del sistema
	@echo "Ejecutando optimización..."
	@powershell.exe -ExecutionPolicy Bypass -File scripts/optimize.ps1

cleanup: ## Limpia archivos temporales
	@echo "Limpiando archivos temporales..."
	@powershell.exe -ExecutionPolicy Bypass -File scripts/cleanup.ps1

services: ## Gestiona servicios de Windows
	@echo "Gestionando servicios..."
	@powershell.exe -ExecutionPolicy Bypass -File scripts/services.ps1

test: ## Ejecuta los tests de verificación
	@echo "Ejecutando tests..."
	@powershell.exe -ExecutionPolicy Bypass -File tests/verify.ps1

info: ## Muestra información del sistema
	@echo "Información del sistema Windows..."
	@powershell.exe -Command "Get-ComputerInfo | Select-Object WindowsProductName, WindowsVersion, OsHardwareAbstractionLayer"
