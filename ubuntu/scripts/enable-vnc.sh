#!/bin/bash
#
# enable-vnc.sh - Habilita acceso VNC remoto
#
# Este script configura x11vnc para permitir conexiones remotas a la sesión de escritorio.
# IMPORTANTE: Deshabilita Wayland para asegurar compatibilidad con x11vnc.
#

# Verificar root
if [ "$EUID" -ne 0 ]; then
    echo "[ERROR] Este script debe ejecutarse como root (sudo)."
    exit 1
fi

# Detectar usuario real
REAL_USER=${SUDO_USER:-$USER}
if [ "$REAL_USER" = "root" ]; then
    echo "[ERROR] No se pudo detectar el usuario real. Ejecuta con sudo desde un usuario normal."
    exit 1
fi
USER_HOME=$(getent passwd "$REAL_USER" | cut -d: -f6)
USER_UID=$(id -u "$REAL_USER")

echo "=== Configurando Servidor VNC (x11vnc) para usuario: $REAL_USER (UID: $USER_UID) ==="

# 1. Deshabilitar Wayland (necesario para x11vnc)
if grep -q "^#WaylandEnable=false" /etc/gdm3/custom.conf; then
    echo "[INFO] Deshabilitando Wayland en /etc/gdm3/custom.conf..."
    sed -i 's/^#WaylandEnable=false/WaylandEnable=false/' /etc/gdm3/custom.conf
    echo "[WARN] Se ha deshabilitado Wayland. Será necesario reiniciar para que surta efecto completo."
elif grep -q "^WaylandEnable=false" /etc/gdm3/custom.conf; then
    echo "[INFO] Wayland ya está deshabilitado."
else
    echo "[INFO] No se detectó configuración de Wayland o archivo diferente. Continuando..."
fi

# 2. Instalar x11vnc
echo "[INFO] Instalando x11vnc..."
apt-get update -qq
apt-get install -y x11vnc net-tools -qq

# 3. Configurar contraseña
VNC_DIR="/etc/x11vnc"
mkdir -p "$VNC_DIR"

if [ ! -f "$VNC_DIR/vncpwd" ]; then
    if [ -n "$VNC_PASSWORD" ]; then
        echo "[INFO] Usando contraseña de variable de entorno VNC_PASSWORD"
        x11vnc -storepasswd "$VNC_PASSWORD" "$VNC_DIR/vncpwd"
    else
        echo ""
        echo ">>> Por favor, introduce la contraseña para el acceso VNC:"
        x11vnc -storepasswd "$VNC_DIR/vncpwd"
    fi
    chmod 400 "$VNC_DIR/vncpwd"
    chown "$REAL_USER:$REAL_USER" "$VNC_DIR/vncpwd"
    echo "[OK] Contraseña guardada en $VNC_DIR/vncpwd"
else
    echo "[INFO] La contraseña VNC ya existe. Si quieres cambiarla, borra $VNC_DIR/vncpwd y ejecuta de nuevo."
    chown "$REAL_USER:$REAL_USER" "$VNC_DIR/vncpwd"
fi

# 4. Crear servicio systemd
echo "[INFO] Creando servicio systemd..."
cat > /etc/systemd/system/x11vnc.service <<EOF
[Unit]
Description=Start x11vnc at startup.
After=multi-user.target

[Service]
Type=simple
User=$REAL_USER
ExecStart=/usr/bin/x11vnc -auth /run/user/$USER_UID/gdm/Xauthority -display :0 -forever -loop -noxdamage -repeat -rfbauth /etc/x11vnc/vncpwd -rfbport 5900 -shared -noxrecord -noxfixes -nowf
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF

# 5. Configurar Pantalla Virtual (Headless Mode)
# Esto es necesario si no hay monitor conectado para evitar la pantalla negra
echo "[INFO] Configurando pantalla virtual (Headless Mode)..."
apt-get install -y xserver-xorg-video-dummy -qq

cat > /usr/share/X11/xorg.conf.d/10-headless.conf <<EOF
Section "Device"
    Identifier "DummyDevice"
    Driver "dummy"
    VideoRam 256000
EndSection

Section "Monitor"
    Identifier "DummyMonitor"
    HorizSync 30-70
    VertRefresh 50-85
EndSection

Section "Screen"
    Identifier "DummyScreen"
    Device "DummyDevice"
    Monitor "DummyMonitor"
    DefaultDepth 24
    SubSection "Display"
        Depth 24
        Modes "1920x1080"
    EndSubSection
EndSection
EOF
echo "[OK] Configuración de pantalla virtual creada en /usr/share/X11/xorg.conf.d/10-headless.conf"

# 6. Habilitar y arrancar servicio
systemctl daemon-reload
systemctl enable x11vnc.service
echo "[INFO] Reiniciando servicio x11vnc..."
systemctl restart x11vnc.service

echo ""
echo "=== Configuración VNC Completada ==="
echo "1. El servidor VNC está escuchando en el puerto 5900."
echo "2. Si acabas de deshabilitar Wayland, REINICIA el sistema ahora: 'reboot'"
echo "3. Conéctate usando un cliente VNC a la IP de esta máquina."
