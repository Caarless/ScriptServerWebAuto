#!/bin/bash

# Script Maestro - Laboratorio en una Caja
# Autor: Tu Nombre
# Descripción: Despliegue automatizado de infraestructura LAMP

# Obtener directorio del script
BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SCRIPTS_DIR="$BASE_DIR/scripts"

# Cargar configuración común (para tener acceso a los colores y logs)
source "$SCRIPTS_DIR/common.sh"

clear
echo -e "${GREEN}===========================================${NC}"
echo -e "${GREEN}   LABORATORIO EN UNA CAJA - INSTALADOR    ${NC}"
echo -e "${GREEN}===========================================${NC}"
echo ""

# Confirmación usuario
echo "Este script instalará un servidor LAMP completo en esta máquina."
echo "Se realizarán cambios permanentes (paquetes, usuarios, firewall)."
read -p "¿Estás seguro de continuar? (s/N): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Ss]$ ]]; then
    log_warn "Operación cancelada por el usuario."
    exit 0
fi

# Ejecución por fases
log_info "Iniciando proceso de instalación..."

# 1. Comprobaciones
bash "$SCRIPTS_DIR/00_preflight.sh"
if [ $? -ne 0 ]; then
    log_error "Fallaron las comprobaciones previas. Abortando."
    exit 1
fi

# 2. Sistema Base
bash "$SCRIPTS_DIR/01_system.sh"
if [ $? -ne 0 ]; then
    log_error "Error en configuración del sistema."
    exit 1
fi

# 3. Stack LAMP
bash "$SCRIPTS_DIR/02_lamp.sh"
if [ $? -ne 0 ]; then
    log_error "Error en instalación LAMP."
    exit 1
fi

# 4. Seguridad (Placeholder para Fase 2)
if [ -f "$SCRIPTS_DIR/03_security.sh" ]; then
    bash "$SCRIPTS_DIR/03_security.sh"
else
    log_warn "Script de seguridad no encontrado (¿Fase 2?), saltando..."
fi

# 5. Despliegue App (Placeholder para Fase 3)
if [ -f "$SCRIPTS_DIR/04_deploy.sh" ]; then
    bash "$SCRIPTS_DIR/04_deploy.sh"
else
    log_warn "Script de despliegue no encontrado (¿Fase 3?), saltando..."
fi

echo ""
echo -e "${GREEN}===========================================${NC}"
echo -e "${GREEN}      INSTALACION COMPLETADA CON EXITO     ${NC}"
echo -e "${GREEN}===========================================${NC}"
echo "Tu servidor LAMP debería estar operativo."
