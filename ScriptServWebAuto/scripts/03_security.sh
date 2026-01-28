#!/bin/bash
source "$(dirname "$0")/common.sh"

log_info "Iniciando proceso de securización (Fase 2)..."

# 1. Configurar Firewall (UFW)
if command -v ufw >/dev/null; then
    log_info "Configurando UFW Firewall..."
    
    # Reset para empezar limpio (opcional, pero asegura idempotencia)
    # ufw --force reset 
    
    # Políticas por defecto
    ufw default deny incoming
    ufw default allow outgoing
    
    # Permitir SSH (o te quedas fuera!)
    # TODO: Si usas un puerto SSH distinto al 22, cámbialo aquí.
    ufw allow ssh  # Permite puerto 22/tcp
    
    # Permitir Tráfico Web
    ufw allow "Apache Full" # Abre 80 y 443
    
    # Habilitar firewall sin pedir confirmación
    ufw --force enable
    
    log_info "Estado de UFW:"
    ufw status verbose
else
    log_error "UFW no está instalado. Ejecute primero 01_system.sh"
    exit 1
fi

# 2. Instalar y Configurar Fail2Ban
if ! command -v fail2ban-client >/dev/null; then
    log_info "Instalando Fail2Ban..."
    DEBIAN_FRONTEND=noninteractive apt-get install -y fail2ban
    
    # Crear copia local de configuración (nunca editar jail.conf directamente)
    cp /etc/fail2ban/jail.conf /etc/fail2ban/jail.local
    
    # Habilitar protección SSH explícitamente (suele venir por defecto, pero nos aseguramos)
    # Usamos sed para manipular el archivo de configuración limpiamente
    # [sshd] -> enabled = true
    # Esto es un reemplazo simple, para configuraciones complejas mejor usar archivos separados en jail.d/
    
    cat <<EOF > /etc/fail2ban/jail.d/defaults-debian.conf
[sshd]
enabled = true
# Banear por 1 hora (3600s) tras 5 intentos fallidos
bantime  = 3600
findtime = 600
maxretry = 5
EOF

    systemctl enable fail2ban
    systemctl restart fail2ban
    log_info "Fail2Ban instalado y activo. Jails activas:"
    fail2ban-client status
else
    log_warn "Fail2Ban ya instalado."
fi

# 3. Hardening Básico de SSH
SSH_CONFIG="/etc/ssh/sshd_config"
BACKUP_SSH="/etc/ssh/sshd_config.bak.$(date +%F_%T)"

log_info "Aplicando hardening básico a SSH..."

if [ -f "$SSH_CONFIG" ]; then
    # Backup primero
    cp "$SSH_CONFIG" "$BACKUP_SSH"
    log_info "Backup de sshd_config creado en $BACKUP_SSH"
    
    # Deshabilitar login de root (PermitRootLogin no/prohibit-password)
    # Usamos sed para buscar la línea y cambiarla, o añadirla si no existe.
    sed -i 's/^#PermitRootLogin.*/PermitRootLogin no/' "$SSH_CONFIG"
    sed -i 's/^PermitRootLogin.*/PermitRootLogin no/' "$SSH_CONFIG"
    
    # (Opcional) Deshabilitar autenticación por contraseña
    # ¡CUIDADO! Solo descomentar si tienes claves SSH configuradas, si no te quedarás fuera.
    # log_warn "Deshabilitando autenticación por contraseña (PasswordAuthentication no)..."
    # sed -i 's/#PasswordAuthentication.*/PasswordAuthentication no/' "$SSH_CONFIG"
    # sed -i 's/PasswordAuthentication.*/PasswordAuthentication no/' "$SSH_CONFIG"
    
    # Validar configuración antes de reiniciar
    if sshd -t; then
        systemctl restart sshd
        log_info "Servicio SSH reiniciado con nueva configuración."
    else
        log_error "La configuración de SSH es inválida. Restaurando backup..."
        cp "$BACKUP_SSH" "$SSH_CONFIG"
        systemctl restart sshd
    fi
else
    log_error "No se encontró $SSH_CONFIG"
fi

log_info "Fase 2 (Seguridad) completada."
