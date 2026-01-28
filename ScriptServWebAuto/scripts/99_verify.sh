#!/bin/bash
source "$(dirname "$0")/common.sh"

log_info "Iniciando pruebas de verificación (Fase 4)..."
ERRORS=0

# Función auxiliar para comprobar servicios
check_service() {
    local SERVICE=$1
    if systemctl is-active --quiet "$SERVICE"; then
        log_info "Servicio $SERVICE: [OK]"
    else
        log_error "Servicio $SERVICE: [FALLO]"
        ERRORS=$((ERRORS+1))
    fi
}

# 1. Verificar Servicios
echo "--- Comprobando Estado de Servicios ---"
check_service apache2
check_service mariadb
check_service fail2ban
check_service sshd

if command -v ufw >/dev/null; then
    if ufw status | grep -q "Status: active"; then
         log_info "Firewall UFW: [OK] (Activo)"
    else
         log_error "Firewall UFW: [FALLO] (Inactivo o no instalado)"
         ERRORS=$((ERRORS+1))
    fi
fi

# 2. Verificar Respuesta HTTP
echo "--- Comprobando Respuesta Web ---"
# URL local
TEST_URL="http://localhost"
HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" "$TEST_URL")

if [ "$HTTP_CODE" == "200" ]; then
    log_info "Acceso HTTP a $TEST_URL: [OK] (Código 200)"
else
    log_error "Acceso HTTP a $TEST_URL: [FALLO] (Código $HTTP_CODE)"
    ERRORS=$((ERRORS+1))
fi

# Verificar si PHP está procesando (buscando string específico en la respuesta)
CONTENT=$(curl -s "$TEST_URL")
if echo "$CONTENT" | grep -q "Versión de PHP"; then
    log_info "Procesamiento PHP: [OK]"
else
    log_warn "No se detectó la salida de PHP esperada en index.php (¿Quizás cambiaste el contenido?)"
fi

# 3. Reporte Final
echo ""
if [ $ERRORS -eq 0 ]; then
    echo -e "${GREEN}VERIFICACIÓN COMPLETADA: TODOS LOS SISTEMAS OPERATIVOS.${NC}"
    exit 0
else
    echo -e "${RED}VERIFICACIÓN FALLIDA: SE ENCONTRARON $ERRORS ERRORES.${NC}"
    exit 1
fi
