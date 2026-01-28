# ScriptServerWebAuto
# Laboratorio en una Caja (ScriptServWebAuto)

![License](https://img.shields.io/badge/license-MIT-blue.svg)
![Bash](https://img.shields.io/badge/language-Bash-green.svg)
![Platform](https://img.shields.io/badge/platform-Ubuntu%20LTS-orange.svg)

> Scripts en Bash para montar un servidor LAMP (Apache + MariaDB + PHP), aplicar seguridad básica (UFW + Fail2Ban) y desplegar una web automáticamente en Ubuntu Server.

Este proyecto está pensado para montar un laboratorio reproducible (VM o servidor) y aprender automatización de sistemas Linux con un instalador principal (`install.sh`) y scripts por fases.

---

## Qué hace este proyecto

Al ejecutar `install.sh`, el sistema realiza el flujo completo:

1. Chequeos previos (SO y conectividad).
2. Preparación del sistema y herramientas base.
3. Instalación del stack LAMP (Apache, MariaDB, PHP).
4. Seguridad: UFW + Fail2Ban.
5. Despliegue de la aplicación en `/var/www/`.
6. Verificación final.

Incluye configuración mediante variables (`DB_NAME`, `DB_USER`, `DB_PASS`, `APP_DOMAIN`) para reutilizarlo en diferentes máquinas/proyectos sin editar scripts.

---

## Requisitos

- Ubuntu Server **20.04 LTS** o **22.04 LTS**.
- Acceso a Internet en la VM/servidor (para instalar paquetes).
- Usuario con permisos `sudo` (o root).
- Recomendado si usas VirtualBox: 2 adaptadores de red (NAT + Host-Only) para tener IP estable.

---

## Recomendado: red en VirtualBox (IP estable)

Si usas “Puente” y cambias de WiFi/datos, la IP puede cambiar y se “rompe” el acceso a la web/SSH.

La configuración recomendada:

- Adaptador 1: **NAT** (solo Internet en la VM).
- Adaptador 2: **Host-Only** (IP privada estable PC ↔ VM).

### 1) Crear red Host-Only (una vez)
1. Abre VirtualBox (ventana principal).
2. Archivo > Herramientas > Network Manager.
3. Pestaña “Host-only Networks”.
4. Crear (si no existe).
5. Verifica que el DHCP esté habilitado (IP típica del host: `192.168.56.1/24`).

### 2) Configurar tu VM
1. Apaga la VM.
2. Configuración > Red.
3. Adaptador 1 = NAT.
4. Adaptador 2 = Host-only Adapter (elige la red creada).

### 3) Ver tu IP fija dentro de Ubuntu
En la VM:

```bash
ip a
```
Busca la interfaz del Host-Only (normalmente 192.168.56.X). Esa será tu IP estable para acceder desde tu PC.

Instalación rápida (modo automático)

1) Descargar el proyecto
Opción A (recomendado): clonar desde la VM/servidor:

```bash
git clone https://github.com/Caarless/ScriptServerWebAuto
cd ScriptServWebAuto
```
Opción B: copiar desde tu PC con SCP:

```bash
scp -r ScriptServWebAuto/ usuario@IP_SERVIDOR:~/
ssh usuario@IP_SERVIDOR
cd ScriptServWebAuto
```

2) Dar permisos de ejecución

```bash
chmod +x install.sh scripts/*.sh
```

3) Ejecutar instalador

```bash
sudo ./install.sh
```
4) Abrir en el navegador
http://TU_IP

Si estás en VirtualBox con Host-Only, usa http://192.168.56.X

Ejecución por fases (modo manual)
Útil para aprender o depurar.

```bash
sudo ./scripts/01_system.sh
sudo ./scripts/02_lamp.sh
sudo ./scripts/03_security.sh
sudo ./scripts/04_deploy.sh
sudo ./scripts/99_verify.sh
```

5) Configuración (variables)
Puedes personalizar sin editar archivos pasando variables al ejecutar install.sh.

Variables principales:

DB_NAME: nombre de la base de datos.

DB_USER: usuario de base de datos.

DB_PASS: contraseña del usuario.

APP_DOMAIN: dominio/IP del VirtualHost (ej. 192.168.56.101, midominio.local, etc.).

6) Instalación por defecto
```bash
sudo ./install.sh
```
7) Instalación personalizada (recomendado)
Usa sudo -E para conservar variables exportadas:

```bash
export DB_NAME="tienda_online"
export DB_USER="admin_tienda"
export DB_PASS="ContrasenaSegura2026"
export APP_DOMAIN="192.168.56.101"

sudo -E ./install.sh
```
Alternativa: todo en una línea

```bash
sudo DB_NAME="blog_personal" APP_DOMAIN="mi-blog.com" ./install.sh
Desplegar tu propia web (HTML/CSS/JS/PHP)
El despliegue copia el contenido de app/ al directorio web (por ejemplo /var/www/tudominio).
```

Pasos:

Sustituye el contenido de app/ por tu web.

Asegúrate de tener index.html o index.php.

Ejecuta:

```bash
sudo ./scripts/04_deploy.sh
```

Estructura recomendada:

text
app/
├── index.html (o index.php)
├── css/
│   └── style.css
├── js/
│   └── main.js
└── img/
    └── logo.png

7) Dominio (opcional) y acceso por nombre
Dominio real: configura un registro A apuntando a la IP pública del servidor.

Pruebas en VM: edita el hosts de tu ordenador para simular el dominio.

Ejemplo en tu PC:

text
192.168.1.50   midominio.com www.midominio.com
HTTPS con Let's Encrypt (opcional)
Si tu dominio real apunta a tu servidor y es accesible desde Internet:

```bash
sudo apt-get install -y certbot python3-certbot-apache
sudo certbot --apache -d midominio.com
Verificación manual (si algo falla)
Ver Apache en el navegador: http://TU_IP
```

8) UFW:

```bash
sudo ufw status
Versiones:
```

```bash
apache2 -v
mariadb --version
php -v
```
9) Base de datos (ejemplo):

```bash
mysql -u lab_user -p -e "SHOW DATABASES;"
```
10) Estructura del proyecto
text
.
├── install.sh
├── scripts/
│   ├── common.sh
│   ├── 00_preflight.sh
│   ├── 01_system.sh
│   ├── 02_lamp.sh
│   ├── 03_security.sh
│   ├── 04_deploy.sh
│   └── 99_verify.sh
├── config/
│   ├── apache/vhost.conf
│   └── mysql/init.sql
├── app/
└── docs/
    ├── manual.md
    └── GUIA_RED_Y_VARIABLES.md

11) Documentación

Manual paso a paso: docs/manual.md

Red + variables (Host-Only / DB / APP_DOMAIN): docs/GUIA_RED_Y_VARIABLES.md

12) Autor
Carles
