#!/bin/bash
# =============================================================
#  install.sh — Dotfiles Debian (BSPWM + X11)
#  Installer para Debian 12/13 con apt. Sin AUR, sin builds.
#
#  USO:
#    ./install.sh                 → modo completo, preset auto(detección VM)
#    ./install.sh --preset vm     → VirtualBox (picom backend xrender)
#    ./install.sh --preset hw     → ThinkPad real (picom backend glx)
#    ./install.sh --minimal       → solo paquetes CORE
#    ./install.sh --copy          → copiar configs en lugar de symlinks
#    ./install.sh --dry-run       → mostrar acciones sin ejecutar
#    ./install.sh --no-reboot     → no automatizar reboot al final
#    ./install.sh --no-power      → no tocar tlp/zram (VM sin laptop)
# =============================================================

set -o pipefail
REPO_DIR="$(cd "$(dirname "$0")" && pwd)"
CONF_SRC="$REPO_DIR/config"
HOME_SRC="$REPO_DIR/home"
LOG="$REPO_DIR/install-$(date +%Y%m%d-%H%M%S).log"

GRN=$'\e[32m'; YLW=$'\e[33m'; RED=$'\e[31m'; BLU=$'\e[34m'; CYN=$'\e[36m'; RST=$'\e[0m'

DRY=false; COPY=false; MINIMAL=false; NO_REBOOT=false; NO_POWER=false
PRESET="auto"; NEXT_IS_PRESET=false

for arg in "$@"; do
    case "$arg" in
        --dry-run)    DRY=true ;;
        --copy)       COPY=true ;;
        --minimal)    MINIMAL=true ;;
        --no-reboot)  NO_REBOOT=true ;;
        --no-power)   NO_POWER=true ;;
        --preset=*)   PRESET="${arg#--preset=}" ;;
        --preset)     NEXT_IS_PRESET=true ;;
        vm|hw)
            if $NEXT_IS_PRESET; then PRESET="$arg"; NEXT_IS_PRESET=false; fi ;;
        *) ;;
    esac
done

# Log completo SIEMPRE
exec > >(tee -a "$LOG") 2>&1

banner() {
    echo
    echo "${CYN}══════════════════════════════════════════════${RST}"
    echo "  Dotfiles Debian BSPWM — $1"
    echo "${CYN}══════════════════════════════════════════════${RST}"
}

ask() {  # ask "¿pregunta?" [y|n] → 0 = sí
    local def="${2:-n}"
    read -rp "$1 [$def] " a
    a="${a:-$def}"
    [[ "$a" =~ ^[YySs] ]]
}

run() {
    if $DRY; then echo "${YLW}[dry]${RST} $*"
    else "$@"; fi
}

sudo_run() {
    if $DRY; then echo "${YLW}[dry-sudo]${RST} sudo $*"
    elif [ "$(id -u)" -eq 0 ]; then "$@"
    else sudo "$@"; fi
}

# ─────────────────────────────────────────────────────────────
banner "Verificaciones iniciales"
# ─────────────────────────────────────────────────────────────

if [ "$(id -u)" -eq 0 ]; then
    echo "${RED}ERROR${RST}: no ejecutes como root. Corre: ./$0 con tu usuario."
    exit 1
fi

DISTRO=""
VER_ID=""
if [ -f /etc/os-release ]; then
    . /etc/os-release
    DISTRO="$ID"
    VER_ID="${VERSION_ID:-}"
fi
echo "Distro   : ${DISTRO:-desconocida} ${VER_ID}"
case "${DISTRO}" in
    debian|kali|parrot) ;;
    *) echo "${YLW}AVISO${RST}: pensado para Debian 12/13. Continúa con riesgo." ;;
esac

CASE_MODE="full"
$MINIMAL && CASE_MODE="minimal"
echo "Preset   : $PRESET (auto = systemd-detect-virt)"
echo "Modo     : $CASE_MODE / $( $COPY && echo 'copy' || echo 'symlink' )"

# sudo disponible?
if ! sudo -v 2>/dev/null; then
    echo "${RED}ERROR${RST}: sudo no dhava disponible."
    exit 1
fi

# ─────────────────────────────────────────────────────────────
banner "Preparando apt"
# ─────────────────────────────────────────────────────────────
sudo_run env DEBIAN_FRONTEND=noninteractive apt-get -qq update

# ─────────────────────────────────────────────────────────────
# Paquetes (solo repos oficiales Debian trixie — verificados)
# ─────────────────────────────────────────────────────────────
banner "Paquetes"

PKGS_CORE=(
    # X11 + WM
    xorg x11-utils x11-xserver-utils bspwm sxhkd
    # bar, menus, compositor
    polybar rofi picom feh
    # notificaciones
    dunst libnotify-bin
    # terminal + shell
    alacritty zsh
    zsh-autosuggestions zsh-syntax-highlighting fzf
    # utilidades X11
    xclip xdotool wmctrl arandr xautolock
    # capturas / control
    maim flameshot brightnessctl playerctl pavucontrol
    # templates + thema
    arc-theme papirus-icon-theme fonts-jetbrains-mono
    fonts-noto fonts-noto-color-emoji
    # red/blu
    network-manager network-manager-gnome wpasupplicant blueman bluez
    # apps compat
    thunar thunar-archive-plugin tumbler
    qalculate rofimoji
    zathura zathura-pdf-poppler
    imagemagick jq python3
    lightdm lightdm-gtk-greeter xdg-desktop-portal-gtk
    clipmenu
    nvim ripgrep
)
PKGS_BASE_FALLBACK=( eza bat cava xterm )

IS_LAPTOP="no"
if ls /sys/class/power_supply/*BAT* >/dev/null 2>&1; then
    IS_LAPTOP="yes"
fi

install_pkgs() {
    local name="$1"; shift
    local toinstall=()
    for p in "$@"; do
        dpkg -s "$p" >/dev/null 2>&1 || toinstall+=("$p")
    done
    if [ "${#toinstall[@]}" -eq 0 ]; then
        echo "  $name: todos presentes"
        return 0
    fi
    echo "${CYN}[apt]${RST} instalando $name: ${toinstall[*]}"
    if ! sudo_run env DEBIAN_FRONTEND=noninteractive apt-get -y install "${toinstall[@]}"; then
        echo "${YLW}NOTA${RST}: alguno falló en $name. Los scripts degradan solos (dunstify avisa)."
    fi
}

install_pkgs "CORE" "${PKGS_CORE[@]}"
if ! $MINIMAL; then
    install_pkgs "CLI-UTILS" "${PKGS_BASE_FALLBACK[@]}"
fi

# Audio: preferir PipeWire> pulseaudio
if ! $MINIMAL; then
    if ! dpkg -s pipewire-pulse >/dev/null 2>&1; then
        install_pkgs "AUDIO" pipewire pipewire-pulse wireplumber pulseaudio-utils
    fi
fi

# Laptop optimizations (ThinkPad 8GB)
if [ "$IS_LAPTOP" = "yes" ] && ! $NO_POWER && ! $MINIMAL; then
    if ask "¿Optimizar energía ThinkPad? (tlp + thermald + zram) [y] " y; then
        install_pkgs "POWER" tlp thermald zram-tools powertop
        sudo_run systemctl disable --now power-profiles-daemon 2>/dev/null || true
        sudo_run systemctl enable --now thermald 2>/dev/null || true
        if ! $DRY; then
            sudo tee /etc/default/zramswap >/dev/null <<'ZRAMCONF'
ALGO=zstd
PERCENT=40
ZRAMCONF
        fi
        sudo_run systemctl enable --now zramswap 2>/dev/null || true
        sudo_run systemctl enable --now tlp 2>/dev/null || true
    fi
fi

# Music stack (opcional)
if ! $MINIMAL && ask "¿Stack de música? (mpd + ncmpcpp) " n; then
    install_pkgs "MUSIC" mpd mpc ncmpcpp cava
fi

# Dev tools (opcional)
if ! $MINIMAL && ask "¿Herramientas dev? (git + geany + fastfetch) " n; then
    install_pkgs "DEV" git geany fastfetch
else
    dpkg -s fastfetch >/dev/null 2>&1 || install_pkgs "FASTFETCH" fastfetch
fi

# ─────────────────────────────────────────────────────────────
banner "Backups de configuraciones previas"
# ─────────────────────────────────────────────────────────────

BACKUPS_DIR="$HOME/.config-backup-$(date +%Y%m%d-%H%M%S)"
if ! $DRY; then mkdir -p "$BACKUPS_DIR"; fi

backup_path() {
    local p="$1"
    if [ -e "$p" ] || [ -L "$p" ]; then
        if $DRY; then
            echo "[dry] movería $p → $BACKUPS_DIR/"
        else
            mv "$p" "$BACKUPS_DIR/"
            echo "${YLW}backup${RST}: $p → $BACKUPS_DIR/"
        fi
    fi
}

for cfg in bspwm sxhkd polybar picom rofi dunst alacritty gtk-3.0 fastfetch \
           flameshot zathura nvim; do
    backup_path "$HOME/.config/$cfg"
done
backup_path "$HOME/.zshrc"

# ─────────────────────────────────────────────────────────────
banner "Instalando configuraciones"
# ─────────────────────────────────────────────────────────────

if ! $DRY; then
    mkdir -p "$HOME/.config" \
             "$HOME/Imágenes/ScreenShots" \
             "$HOME/Imágenes/Wallpapers" \
             "$HOME/Imágenes/ScreenRecordings" \
             "$HOME/.cache"
fi

link_or_copy() {
    local src="$1" dst="$2"
    if $DRY; then
        echo "[dry] $( $COPY && echo cp || echo ln -s) $src → $dst"
    elif $COPY; then
        cp -r "$src" "$dst"
    else
        ln -sfn "$src" "$dst"
    fi
}

for cfg in bspwm sxhkd polybar picom rofi dunst alacritty gtk-3.0 fastfetch \
           flameshot zathura nvim; do
    [ -d "$CONF_SRC/$cfg" ] && link_or_copy "$CONF_SRC/$cfg" "$HOME/.config/$cfg"
done

link_or_copy "$HOME_SRC/.zshrc" "$HOME/.zshrc"

if ! $DRY; then
    chmod +x "$HOME/.config/bspwm/bin/"* 2>/dev/null
    chmod +x "$HOME/.config/polybar/launch.sh" 2>/dev/null
fi

# ─────────────────────────────────────────────────────────────
banner "picom preset (backend según preset=$PRESET)"
# ─────────────────────────────────────────────────────────────

PICOM_DEFAULT="$HOME/.config/picom/picom.conf"
if [ "$PRESET" = "vm" ]; then
    link_or_copy "$HOME/.config/picom/picom-vm.conf" "$PICOM_DEFAULT"
    echo "→ picom backend xrender (VirtualBox / GPU emulada)"
else
    link_or_copy "$HOME/.config/picom/picom-hw.conf" "$PICOM_DEFAULT"
    echo "→ picom backend glx (hardware real)"
fi

# ─────────────────────────────────────────────────────────────
banner "Tema inicial + sistema.polybar variables"
# ─────────────────────────────────────────────────────────────

if ! $DRY; then
    echo dark > "$HOME/.config/bspwm/.theme"
    if [ -x "$HOME/.config/bspwm/bin/ThemeSwitch" ]; then
        "$HOME/.config/bspwm/bin/ThemeSwitch" --set dark || true
    fi
fi

# ─────────────────────────────────────────────────────────────
banner "Sesión y autostart"
# ─────────────────────────────────────────────────────────────

# archivo private autostart (no versionado) — daemons de tray
if ! $DRY && [ ! -f "$HOME/.config/bspwm/autostart.sh" ]; then
    cat > "$HOME/.config/bspwm/autostart.sh" <<'AUTOSTART'
#!/bin/sh
# autostart privado del usuario (NO versionado)
# add: start <cmd>
start() { if ! pgrep -x "$1" >/dev/null; then "$@" & return 0; fi }

start nm-applet
if command -v blueman-applet >/dev/null 2>&1; then start blueman-applet; fi
if command -v clipmenud   >/dev/null 2>&1; then start clipmenud;   fi
if command -v xfce4-notifyd >/dev/null 2>&1; then :; fi
AUTOSTART
    chmod +x "$HOME/.config/bspwm/autostart.sh"
fi

# sesión bspwm para lightdm ( 있는 Debian's bspwm pkg include it, but if not…)
if ! $DRY && ! dpkg -L bspwm 2>/dev/null | grep -q bspwm.desktop; then
    sudo_run tee /usr/share/xsessions/bspwm-dotfiles.desktop >/dev/null <<'DESKTOP'
[Desktop Entry]
Name=bspwm (dotfiles debian)
Comment=Tiling window manager BSPWM
Exec=bspwm
Type=Application
DESKTOP
fi

echo "sesión: $(dpkg -L bspwm 2>/dev/null | grep -c 'bspwm.desktop') bspwm.desktop presente"

# ─────────────────────────────────────────────────────────────
banner "FIN"
# ─────────────────────────────────────────────────────────────

echo
echo "${GRN}■ Instalación completa${RST}  preset=${PRESET}  $( $COPY && echo copied || echo symlinked )"
echo "  log: $LOG"
echo
echo "Proximo boot en LightDM: elegí la sesión ${CYN}bspwm${RST} y atajos:"
echo "  ${CYN}Alt+F1${RST}          → cheatsheet completo de keybinds"
echo "  ${CYN}super+alt+r${RST}     → SoftReload (recarga componentes)"
echo "  ${CYN}alt+space${RST}       → cambiar tema dark/light"
echo
if ! $NO_REBOOT; then
    echo "Si nada falla: reiniciar — lightdm+zram necesitan reboot inicial."
    if ask "¿Reiniciar ahora? " n; then
        sudo_run systemctl reboot
    fi
fi
exit 0
