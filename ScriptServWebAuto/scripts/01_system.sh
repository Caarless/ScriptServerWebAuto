#!/bin/bash
source "$(dirname "$0")/common.sh"

log_info "Configurando sistema base..."

# 1. Configurar Zona Horaria
log_info "Configurando zona horaria a $TIMEZONE..."
timedatectl set-timezone "$TIMEZONE"

# 2. Actualizar repositorios y paquetes
log_info "Actualizando lista de paquetes..."
apt-get update -y

log_info "Actualizando paquetes instalados (esto puede tardar)..."
# DEBIAN_FRONTEND=noninteractive evita que apt pida confirmación interactiva
DEBIAN_FRONTEND=noninteractive apt-get upgrade -y

# 3. Instalar utilidades esenciales
TOOLS="curl git vim ufw unzip htop net-tools"
log_info "Instalando herramientas esenciales: $TOOLS..."
DEBIAN_FRONTEND=noninteractive apt-get install -y $TOOLS

log_info "Sistema base configurado y actualizado."
