#!/bin/bash
source "$(dirname "$0")/common.sh"

log_info "Iniciando instalación del stack LAMP..."

# --- APACHE ---
if ! command -v apache2 >/dev/null; then
    log_info "Instalando Apache2..."
    DEBIAN_FRONTEND=noninteractive apt-get install -y apache2
    
    # Habilitar mod_rewrite (muy común para apps modernas)
    a2enmod rewrite
    systemctl enable apache2
    systemctl start apache2
    log_info "Apache2 instalado y activo."
else
    log_warn "Apache2 ya está instalado. Omitiendo instalación."
fi

# --- MARIADB ---
if ! command -v mariadb >/dev/null; then
    log_info "Instalando MariaDB Server..."
    DEBIAN_FRONTEND=noninteractive apt-get install -y mariadb-server
    systemctl enable mariadb
    systemctl start mariadb
    
    # Secure installation básica automatizada
    log_info "Asegurando instalación de MariaDB..."
    # Establecer contraseña root (si no tiene) y eliminar usuarios anónimos/test
    mysql -e "UPDATE mysql.user SET Password = PASSWORD('${DB_PASS}') WHERE User = 'root';" 2>/dev/null || true
    mysql -e "DELETE FROM mysql.user WHERE User='';" 2>/dev/null || true
    mysql -e "DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');" 2>/dev/null || true
    mysql -e "DROP DATABASE IF EXISTS test;" 2>/dev/null || true
    mysql -e "DELETE FROM mysql.db WHERE Db='test' OR Db='test\\_%';" 2>/dev/null || true
    mysql -e "FLUSH PRIVILEGES;" 2>/dev/null || true
else
    log_warn "MariaDB ya está instalado. Omitiendo instalación."
fi

# Crear Base de Datos y Usuario para la App
log_info "Configurando base de datos '$DB_NAME' y usuario '$DB_USER'..."
mysql -u root -e "CREATE DATABASE IF NOT EXISTS ${DB_NAME};"
mysql -u root -e "CREATE USER IF NOT EXISTS '${DB_USER}'@'localhost' IDENTIFIED BY '${DB_PASS}';"
mysql -u root -e "GRANT ALL PRIVILEGES ON ${DB_NAME}.* TO '${DB_USER}'@'localhost';"
mysql -u root -e "FLUSH PRIVILEGES;"

# --- PHP ---
if ! command -v php >/dev/null; then
    log_info "Instalando PHP y módulos comunes..."
    DEBIAN_FRONTEND=noninteractive apt-get install -y php libapache2-mod-php php-mysql php-cli php-curl php-xml php-mbstring
    
    # Reiniciar Apache para que cargue PHP
    systemctl restart apache2
    log_info "PHP instalado."
else
    log_warn "PHP ya está instalado. Omitiendo instalación."
fi

# Verificar versión
PHP_VER=$(php -v | head -n 1 | cut -d " " -f 2)
log_info "Versión de PHP instalada: $PHP_VER"

log_info "Stack LAMP instalado correctamente."
