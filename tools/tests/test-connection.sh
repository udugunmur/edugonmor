#!/bin/bash
#
# test-connection.sh - Test de conectividad básica
#

set -e

echo "=========================================="
echo "  Test de Conectividad - tools"
echo "=========================================="
echo ""

TESTS_PASSED=0
TESTS_FAILED=0

run_test() {
    local name="$1"
    local command="$2"
    
    if eval "$command" > /dev/null 2>&1; then
        echo "[PASS] $name"
        ((TESTS_PASSED++))
    else
        echo "[FAIL] $name"
        ((TESTS_FAILED++))
    fi
}

echo "--- Docker ---"
run_test "Docker daemon activo" "docker info"
run_test "Docker Compose disponible" "docker compose version"

echo ""
echo "--- Contenedores ---"
run_test "Contenedor Portainer existe" "docker ps -a | grep -q tools_services"
run_test "Contenedor Portainer running" "docker ps | grep -q tools_services"
run_test "Contenedor Backup existe" "docker ps -a | grep -q tools_backup"

echo ""
echo "--- Red ---"
run_test "Red shared_network existe" "docker network ls | grep -q shared_network"

echo ""
echo "--- Volúmenes ---"
run_test "Volumen tools_volumen existe" "docker volume ls | grep -q tools_volumen"

echo ""
echo "--- Puertos ---"
run_test "Puerto 9443 escuchando" "ss -tuln | grep -q ':9443'"
run_test "Puerto 9000 escuchando" "ss -tuln | grep -q ':9000'"

echo ""
echo "=========================================="
echo "Tests pasados: $TESTS_PASSED"
echo "Tests fallidos: $TESTS_FAILED"
echo "=========================================="

[ $TESTS_FAILED -eq 0 ] && exit 0 || exit 1
