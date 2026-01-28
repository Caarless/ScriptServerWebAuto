#!/bin/bash
source "$(dirname "$0")/common.sh"

log_info "Iniciando comprobaciones previas..."

# 1. Verificar usuario root
check_root

# 2. Verificar conectividad a Internet
echo -e "Comprobando conexión a internet..."
if ping -q -c 1 -W 1 8.8.8.8 >/dev/null; then
    log_info "Conexión a Internet: OK"
else
    log_error "No hay conexión a Internet. Imposible continuar."
    exit 1
fi

# 3. Verificar OS (Opcional, pero recomendado)
if [ -f /etc/os-release ]; then
    . /etc/os-release
    log_info "Sistema detectado: $NAME $VERSION_ID"
    if [[ "$ID" != "ubuntu" && "$ID" != "debian" ]]; then
        log_warn "Este script está optimizado para Ubuntu/Debian. Puede que algunos comandos fallen en $ID."
        read -p "¿Desea continuar de todos modos? (s/n) " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Ss]$ ]]; then
            exit 1
        fi
    fi
else
    log_warn "No se pudo detectar la distribución del sistema operativo."
fi

log_info "Comprobaciones previas finalizadas con éxito."
