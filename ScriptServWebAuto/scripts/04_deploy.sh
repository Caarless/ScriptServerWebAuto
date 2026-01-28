#!/bin/bash
source "$(dirname "$0")/common.sh"

log_info "Iniciando despliegue de la aplicación (Fase 3)..."

APP_DIR="/var/www/${APP_DOMAIN}"
LOCAL_APP_SOURCE="$BASE_DIR/app" # Ruta relativa si copiamos desde local
# GIT_REPO="https://github.com/usuario/mi-repo.git" # Descomentar para clonar

# 1. Preparar directorio de la aplicación
if [ -d "$APP_DIR" ]; then
    log_warn "El directorio $APP_DIR ya existe. Creando backup..."
    mv "$APP_DIR" "${APP_DIR}.bak.$(date +%F_%T)"
fi

mkdir -p "$APP_DIR"

# 2. Copiar código fuente
# Opción A: Copia Local (para desarrollo/testing)
if [ -d "$LOCAL_APP_SOURCE" ]; then
    log_info "Copiando aplicación desde $LOCAL_APP_SOURCE..."
    cp -r "$LOCAL_APP_SOURCE"/* "$APP_DIR/"
else
    # Opción B: Clonar Git (Producción)
    # log_info "Clonando repositorio git..."
    # git clone "$GIT_REPO" "$APP_DIR"
    
    # Fallback si no hay app local ni git
    log_warn "No se encontró fuente de la app. Creando index.php de prueba."
    echo "<?php phpinfo(); ?>" > "$APP_DIR/index.php"
fi

# 3. Configurar Permisos
log_info "Estableciendo permisos (www-data)..."
chown -R www-data:www-data "$APP_DIR"
chmod -R 755 "$APP_DIR"

# 4. Configurar VirtualHost
VHOST_TEMPLATE="$BASE_DIR/config/apache/vhost.conf"
VHOST_DEST="/etc/apache2/sites-available/${APP_DOMAIN}.conf"

if [ -f "$VHOST_TEMPLATE" ]; then
    log_info "Configurando VirtualHost para $APP_DOMAIN..."
    cp "$VHOST_TEMPLATE" "$VHOST_DEST"
    
    # Reemplazar {{DOMAIN}} por el valor real
    sed -i "s/{{DOMAIN}}/${APP_DOMAIN}/g" "$VHOST_DEST"
    
    # Habilitar sitio y recargar Apache
    a2ensite "${APP_DOMAIN}.conf"
    
    # Deshabilitar default si es necesario
    a2dissite 000-default.conf || true

    
    systemctl reload apache2
    log_info "Apache recargado."
else
    log_error "No se encontró la plantilla del VirtualHost en $VHOST_TEMPLATE"
fi

# 5. Importar Base de Datos (Opcional)
SQL_INIT="$BASE_DIR/config/mysql/init.sql"
if [ -f "$SQL_INIT" ]; then
    log_info "Importando datos inicales a la base de datos '$DB_NAME'..."
    mysql -u root "$DB_NAME" < "$SQL_INIT"
    log_info "Importación completada."
else
    log_warn "No se encontró script SQL de inicialización."
fi

log_info "Fase 3 (Despliegue) completada. Tu app está en http://$APP_DOMAIN (o la IP del servidor)"
