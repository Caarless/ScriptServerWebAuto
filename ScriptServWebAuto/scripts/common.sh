#!/bin/bash

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Definir directorio raíz del proyecto (un nivel arriba de /scripts)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BASE_DIR="$(dirname "$SCRIPT_DIR")"

# Variables Globales (Valores por defecto, se pueden sobreescribir)
DB_NAME=${DB_NAME:-"laboratorio_db"}
DB_USER=${DB_USER:-"lab_user"}
DB_PASS=${DB_PASS:-"secure_password_123"}
APP_DOMAIN=${APP_DOMAIN:-"localhost"}
TIMEZONE=${TIMEZONE:-"Europe/Madrid"}

# Funciones de Logging
log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Verificación de ejecución
check_root() {
    if [[ $EUID -ne 0 ]]; then
       log_error "Este script debe ejecutarse como root (o con sudo)."
       exit 1
    fi
}
