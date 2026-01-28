# Manual de Uso - Laboratorio en una Caja

Este documento explica cómo utilizar el proyecto de automatización fase apaso.

## Requisitos Previos
*   Una máquina virtual (VM) o servidor con **Ubuntu 20.04/22.04 LTS**.
*   Acceso a Internet en la VM.
*   Primera red "NAT" para internet.
*   Segunda red "Solo-Anfitrión" (Host-Only) configurada en VirtualBox.
*   Usuario con permisos de `sudo` (o root).
*   Git instalado en tu máquina local (para bajar este repo) o un método para copiar archivos (SCP/FileZilla).

---

## 🚀 Guía Paso a Paso

### 1. Preparación del Entorno (Fase 1)
Antes de nada, necesitas tener los scripts en tu servidor destino.

**Opción A: Clonar con Git (Si ya tienes git en el servidor)**
```bash
git clone https://github.com/Caarless/ScriptServerWebAuto
cd ScriptServWebAuto (hasta llegar al que no tiene nada de -main)
```

**Opción B: Copiar desde tu PC (Si el servidor es nuevo)**
Desde tu máquina local (PowerShell o Terminal):
```bash
# Reemplaza 'usuario' e 'ip-servidor' con tus datos reales
scp -r ScriptServWebAuto/ usuario@192.168.1.100:~/
```
Luego entra al servidor:
```bash
ssh usuario@192.168.1.100
cd ScriptServWebAuto (hasta llegar al que no tiene nada de -main)
chmod +x install.sh scripts/*.sh
```

### 2. Instalación Completa
El proyecto incluye un script maestro que ejecuta todas las fases en orden.

```bash
sudo ./install.sh
```
Este script te pedirá confirmación y luego ejecutará secuencialmente:
1.  **Chequeos**: Verifica internet y sistema operativo.
2.  **Sistema**: Actualiza Ubuntu e instala herramientas base.
3.  **LAMP**: Instala Apache, MariaDB y PHP.
4.  **Seguridad**: Configura Firewall UFW y Fail2Ban.
5.  **Despliegue**: Instala la web de ejemplo en `/var/www/`.

---

## 🛠 Ejecución Manual por Fases

Si prefieres ejecutar paso a paso para depurar o aprender, puedes correr los scripts individuales.

### Fase 1: Stack LAMP Básico
Instala el servidor web, base de datos y lenguaje.
```bash
sudo ./scripts/01_system.sh
sudo ./scripts/02_lamp.sh
```
**Qué verificar:** Entra a `http://tu-ip` y deberías ver una página de Apache o nuestra app de ejemplo.

### Fase 2: Seguridad
Asegura el servidor cerrando puertos y protegiendo SSH.
```bash
sudo ./scripts/03_security.sh
```
**Qué verificar:** Ejecuta `sudo ufw status` para ver que solo los puertos 22 (SSH), 80 (HTTP) y 443 (HTTPS) están abiertos.

### Fase 3: Despliegue de Aplicación
Copia los archivos de `app/` al servidor web y configura el VirtualHost.
```bash
sudo ./scripts/04_deploy.sh
```
**Nota**: Puedes editar `config/apache/vhost.conf` antes si quieres cambiar configuraciones avanzadas de Apache.

### Fase 4: Verificación
Ejecuta un test automático para asegurar que todo está verde.
```bash
sudo ./scripts/99_verify.sh
```

---

## ⚙️ Personalización
Puedes editar el archivo `scripts/common.sh` para cambiar variables globales antes de instalar:

*   `DB_NAME`: Nombre de la base de datos a crear.
*   `DB_USER`: Usuario de base de datos.
*   `APP_DOMAIN`: Dominio de la web (por defecto `localhost`).

## _______________________________________________________________________________________________________________________________________________

##  Verificación Manual

*   **Apache**: Abre `http://tu-ip-vm` en tu navegador. Deberías ver la página por defecto de Apache ("It Works").
*   **Versiones**:
        ```bash
        apache2 -v
        mariadb --version
        php -v
        ```
*   **Base de Datos**:
        Prueba conectar con el usuario creado:
        ```bash
        mysql -u lab_user -p -e "SHOW DATABASES;"
        # Password: secure_password_123 (o la que hayas configurado)
        ```

## _______________________________________________________________________________________________________________________________________________

# Guía de Personalización: Tu Web y Tu Dominio

Esta guía te explica cómo sustituir el ejemplo por defecto con tus propios archivos (HTML, CSS, JS) y cómo configurar un dominio real.

## 1. Desplegar tu propia Web (HTML/CSS/JS)

El sistema copia todo lo que hay en la carpeta `app/` del proyecto a `/var/www/tudominio`.

### Estructura de Carpetas
Para que tu web funcione ordenadamente, organiza tus archivos dentro de la carpeta `app/` de este proyecto **antes** de subirlo al servidor.

**Ejemplo recomendado:**
```text
ScriptServWebAuto/
├── app/
│   ├── index.html       <-- Tu archivo principal (o index.php)
│   ├── css/
│   │   └── style.css    <-- Tus estilos
│   ├── js/
│   │   └── main.js      <-- Tus scripts
│   ├── img/
│   │   └── logo.png     <-- Tus imágenes
│   └── assets/          <-- Otros recursos
```

### Pasos:
1.  Borra el contenido actual de la carpeta `app/` (el `index.php` de prueba).
2.  Copia **todos** tus archivos y carpetas dentro de `app/`.
3.  Asegúrate de que tu archivo principal se llame `index.html` o `index.php`.
4.  En tus archivos HTML, referencia los estilos y scripts con rutas relativas:
    ```html
    <link rel="stylesheet" href="css/style.css">
    <script src="js/main.js"></script>
    ```
5.  Ejecuta el script de despliegue:
    ```bash
    sudo ./scripts/04_deploy.sh
    ```
    *Esto actualizará `/var/www/tu-dominio` con tus nuevos archivos automáticamente.*

---

## 2. Usar un Dominio Personalizado (miweb.com)

Por defecto, el script usa `localhost` o el dominio que definas. Para usar uno real:

### A. Configurar el Script
1.  Edita el archivo `scripts/common.sh`.
2.  Cambia la variable `APP_DOMAIN`:
    ```bash
    # scripts/common.sh
    APP_DOMAIN="midominio.com"
    ```
3.  Ejecuta de nuevo el instalador o el despliegue:
    ```bash
    sudo ./scripts/04_deploy.sh
    ```
    *Esto creará un nuevo archivo de configuración `/etc/apache2/sites-available/midominio.com.conf`.*

### B. Hacer que funcione (DNS)

Para ver la web en tu navegador, tienes dos opciones:

**Opción 1: Dominio Real (Producción)**
Si has comprado un dominio (ej. en GoDaddy, Namecheap):
1.  Ve al panel de control de tu registrador.
2.  Crea un **Registro A** (A Record).
3.  Apunta `@` a la **IP Pública** de tu servidor VPS.
4.  Espera unos minutos a que se propague.

**Opción 2: Simulación Local (Desarrollo/Pruebas)**
Si no tienes dominio o estás probando en una VM local:
1.  Abre el archivo `hosts` en **TU ordenador** (no en la VM).
    *   **Windows**: Ejecuta el Bloc de Notas como Administrador y abre `C:\Windows\System32\drivers\etc\hosts`.
    *   **Linux/Mac**: `sudo nano /etc/hosts`.
2.  Añade una línea al final:
    ```text
    192.168.1.50   midominio.com www.midominio.com
    ```
    *(Reemplaza `192.168.1.50` por la IP de tu máquina virtual).*
3.  Guarda el archivo.
4.  Ahora, si escribes `midominio.com` en tu navegador, ¡Windows redirigirá esa petición a tu VM!

---

## 3. Certificados SSL (HTTPS) con Let's Encrypt

Si tienes un dominio real y es accesible desde internet, puedes activar HTTPS gratis muy fácilmente.

1.  Instala certbot:
    ```bash
    sudo apt-get install -y certbot python3-certbot-apache
    ```
2.  Ejecuta el asistente:
    ```bash
    sudo certbot --apache -d midominio.com
    ```
3.  Sigue las instrucciones. ¡Listo, ya tienes candadito verde!

