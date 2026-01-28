# Guía de Solución de Red y Configuración de Variables

Esta guía tiene dos objetivos principales:
1.  **Solucionar el problema de la IP cambiante** al cambiar de red (WiFi vs Datos Móviles vs Ethernet).
2.  **Explicar las variables de configuración** (`DB_NAME`, etc.) y cómo usarlas.

---

## Parte 1: Estabilizar la IP de la Máquina Virtual

### Problemas
*   Si usas **Puente**, la VM pide una IP al router de tu casa. Si cambias a los datos del móvil, cambias de router, y la IP cambia.
*   Esto rompe la configuración de tu web server, ya que la IP que usaste para configurar no es la misma que tienes ahora.

### La Solución: Red "Solo-Anfitrión" (Host-Only)
Vamos a configurar un **segundo cable de red** virtual.
*   **Cable 1 (NAT):** Se usa SOLO para que la VM tenga internet (descargar paquetes/updates).
*   **Cable 2 (Host-Only):** Se usa para que TU ordenador y la VM se comuniquen por una IP privada y FIJA que **nunca cambia**, tengas o no internet.

### Pasos de Configuración en VirtualBox

#### 1. Crear la Red Host-Only (Solo hay que hacerlo una vez)
1.  Abre **VirtualBox** (la ventana principal).
2.  Ve al menú **Archivo** (File) > **Herramientas** (Tools) > **Network Manager**.
3.  Ve a la pestaña **Host-only Networks**.
4.  Si no hay ninguna, dale a **Crear**.
5.  Se creará algo como `VirtualBox Host-Only Ethernet Adapter`.
6.  Fíjate en la IP que tiene asignada (usualmente `192.168.56.1` / Máscara `255.255.255.0`).
7.  Asegúrate que el **Servidor DHCP** esté **Habilitado**.

#### 2. Configurar la Máquina Virtual
1.  Apaga tu máquina virtual Ubuntu.
2.  Haz clic derecho en la VM > **Configuración (Settings)**.
3.  Ve a la sección **Red (Network)**.
4.  **Adaptador 1**: Déjalo como está (**NAT**). Esto da internet.
5.  **Adaptador 2**:
    *   Marca "Habilitar adaptador de red".
    *   Conectado a: **Adaptador solo-anfitrión (Host-only Adapter)**.
    *   Nombre: Selecciona el que creaste antes.
6.  Haz clic en OK e inicia la máquina.

#### 3. Configurar Ubuntu (Dentro de la VM)
Una vez encendida la VM, entra y escribe:
```bash
ip a
```
Verás dos interfaces (probablemente `enp0s3` y `enp0s8`).
*   `enp0s3`: Tendrá una IP tipo `10.0.2.15` (NAT, para internet).
*   `enp0s8` (o similar): Debería tener una IP del rango `192.168.56.X`. **¡ESTA ES TU IP FIJA!**

Usa esa IP (ej. `192.168.56.101`) para acceder a tu web desde el navegador de tu Windows. Siempre será esa, aunque te conectes al Wi-Fi del vecino o a los datos del móvil.

---

## Parte 2: Explicación de Variables (`DB_NAME`, `DB_USER`...)

En el script `scripts/common.sh`, ves líneas como esta:
```bash
DB_NAME=${DB_NAME:-"laboratorio_db"}
```

### ¿Qué significan?
Son variables de entorno que configuran tu servidor. La sintaxis `${VARIABLE:-"valor_defecto"}` significa:
> *"Si el usuario me dio un valor para VARIABLE, úsalo. Si no, usa 'valor_defecto'."*

*   **DB_NAME**: El nombre que tendrá la base de datos MySQL/MariaDB.
*   **DB_USER**: El usuario para conectar a esa base de datos.
*   **DB_PASS**: La contraseña para ese usuario.
*   **APP_DOMAIN**: El dominio donde se servirá la web (ej. `192.168.56.101` o `midominio.local`).

### ¿Cómo se utilizan?
No hace falta que edites el archivo `common.sh` si quieres cambiar estos valores. Puedes pasarlos al ejecutar el script principal (`install.sh`).

**Ejemplo 1: Instalación por defecto**
```bash
sudo ./install.sh
```
*   Crea la BD llamada: `laboratorio_db`
*   Usuario: `lab_user` / Contraseña: `secure_password_123`

**Ejemplo 2: Instalación personalizada**
Imagina que quieres crear un proyecto real.
```bash
export DB_NAME="tienda_online"
export DB_USER="admin_tienda"
export DB_PASS="ContrasenaSegura2026"
export APP_DOMAIN="192.168.56.101"

sudo -E ./install.sh
```
*(El `-E` en sudo es importante para que "pase" las variables de entorno al usuario root).*

O todo en una línea:
```bash
sudo DB_NAME="blog_personal" APP_DOMAIN="mi-blog.com" ./install.sh
```

### Resumen
Estas variables hacen que tu script sea **reutilizable**. Puedes usar el mismo código para montar 10 webs distintas cambiando solo esos parámetros al arrancar.
