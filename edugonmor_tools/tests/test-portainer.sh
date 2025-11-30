#!/bin/bash
#
# test-portainer.sh - Test de funcionalidad de Portainer
#

set -e

echo "=========================================="
echo "  Test de Portainer - edugonmor_tools"
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

echo "--- Estado del Servicio ---"
run_test "Contenedor Portainer healthy" "docker inspect edugonmor_tools_services --format='{{.State.Status}}' | grep -q running"

echo ""
echo "--- API de Portainer ---"
run_test "API HTTP responde (9000)" "curl -s -o /dev/null -w '%{http_code}' http://localhost:9000/api/status | grep -qE '200|401'"
run_test "API HTTPS responde (9443)" "curl -sk -o /dev/null -w '%{http_code}' https://localhost:9443/api/status | grep -qE '200|401'"

echo ""
echo "--- Interfaz Web ---"
run_test "UI HTTP accesible" "curl -s http://localhost:9000 | grep -qi 'portainer'"
run_test "UI HTTPS accesible" "curl -sk https://localhost:9443 | grep -qi 'portainer'"

echo ""
echo "--- Docker Socket ---"
run_test "Socket montado correctamente" "docker exec edugonmor_tools_services ls -la /var/run/docker.sock"

echo ""
echo "--- Volumen de Datos ---"
run_test "Directorio /data existe" "docker exec edugonmor_tools_services ls -la /data"

echo ""
echo "=========================================="
echo "Tests pasados: $TESTS_PASSED"
echo "Tests fallidos: $TESTS_FAILED"
echo "=========================================="

[ $TESTS_FAILED -eq 0 ] && exit 0 || exit 1
