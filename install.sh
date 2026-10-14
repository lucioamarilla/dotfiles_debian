#!/bin/bash
# ==============================================================================
#  Auto Installer — BSPWM Debian (v2)
#  Base: MF-Rayo/bspwm-dotfiles-debian (MIT) — adaptado por lucioamarilla
#
#  Cambios vs original:
#   • CERO compilaciones (nada de eww/picom/cava/i3lock-color desde git)
#   • PipeWire nativo (Debian 13) — sin enmascarar, pactl compatible
#   • Nvim minimal (neovim apt) — sin NvChad ni Mason
#   • Sin herramientas de ciberseguridad (daily-driver)
#   • --preset vm|hw (picom + energía), --no-power (skip zram/tlp)
#   • Backups de ~/.config previos antes de copiar
# ==============================================================================

w="\033[0;37m"; r="\033[0;31m"; g="\033[0;32m"; y="\033[0;33m"; sb="\033[0;36m"; b="\033[0;34m"; reset="\033[0m"

PRESET="auto"; NO_POWER=false; DRY=false; NEXT=false
for arg in "$@"; do
    case "$arg" in
        --preset=*) PRESET="${arg#--preset=}" ;;
        --preset) NEXT=true ;;
        vm|hw) $NEXT && PRESET="$arg" && NEXT=false ;;
        --no-power) NO_POWER=true ;;
        --dry-run) DRY=true ;;
        --help|-h)
            cat <<EOF
Uso: ./install.sh [--preset vm|hw] [--no-power] [--dry-run]

  --preset vm    → VirtualBox / GPU emulada (picom sin blur)
  --preset hw    → hardware real (ThinkPad i3-10110U)
  --no-power     → no instalar zram/tlp/thermald
  --dry-run      → mostrar acciones sin ejecutar
  (auto: detecta VM con systemd-detect-virt)
EOF
            exit 0 ;;
    esac
done

if [ "$PRESET" = "auto" ]; then
    PRESET=hw
    command -v systemd-detect-virt >/dev/null 2>&1 && systemd-detect-virt -q && PRESET=vm
fi

banner() {
clear
echo -e "${w}⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿ ${r}D"
echo -e "${w}⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿ ${r}O"
echo -e "${w}⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡿⡟⢟${r}⢝⢝⢝⢝⢝⢟${w}⢿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿ ${r}T"
echo -e "${w}⣿⣿⣿⣿⣿⣿⣿⣿⣿⢟${r}⢕⢕⢌⢢⢡⢑⢕⠕⠕⢕⢕${w}⠏⠄⢏⣺⣿⣿⣿⣿⣿⣿ ${r}F"
echo -e "${w}⣿⣿⣿⣿⣿⣿⣿⣿⣿⢟${r}⢕⢅⢕⢕⢕⢕⢅⢕⢑⢕⢕⢕${w}⡵⠁⡂⠅⠂⠄⠙⣿⣿⣿⣿⣿ ${r}I"
echo -e "${w}⣿⣿⣿⣿⣿⣿⣿⣿⢏${r}⢆⢕⢕⢕⢔⠕⢕⢕⢅⢕⢕${w}⢵⠁⢂⠀⠐⢐⠐⠀⢍⣿⣿⣿⣿ ${r}L"
echo -e "${w}⣿⣿⣿⣿⣿⣿⣿⣟${r}⢅⢕⢑⢕⢅⢕⢕⢕⢕⢑⢅${w}⡵⠋⡀⠄⠠⠨⢀⢬⢜${r}⢾${w}⣿⣿⣿⣿ ${r}E"
echo -e "${w}⣿⣿⣿⣿⣿⣿⣿⣗${r}⢕⣕⡕⢕⢕⢕⢔⢕${w}⠵⢓${w}⠩⠀⢀⢔⢳⢈⠠⠘⡬${r}⡢${w}⣹⣿⣿⣿⣿ ${r}S"
echo -e "${w}⣿⣿⣿⣿⣿⣿⣿⡏${r}⢅${w}⡂⡌⢣${r}⢕⢕${w}⠕⠡⠐⡐⡤⡜⢡⠝⠡⠀⡂⠅⡯${r}⡪${w}⣾⣿⣿⣿⣿ "
echo -e "${w}⣿⣿⣿⣿⣿⣿⣿⣿${r}⣏⣪⠇⢢${w}⢵⣃⠍⡐⡢⠔⣍⠮⠇⠌⡐⡀⠐⢠⠫${r}⢺${w}⣾⣿⣿⣿⣿⣿"
echo -e "${w}  v2 · base MF-Rayo · sin eww/nvchad/pentest · PipeWire nativo ${w}⣿"
echo
}

FRAME=("⠋" "⠙" "⠹" "⠸" "⠼" "⠴" "⠦" "⠧" "⠇" "⠏")
FRAME_INTERVAL=0.1
declare -a RESUMEN=()

format_time() {
    local secs=$1
    if [ "$secs" -lt 60 ]; then echo "${secs}s"; else echo "$((secs / 60))m $((secs % 60))s"; fi
}

view_status() {
    clear; banner
    echo ""
    for linea in "${RESUMEN[@]}"; do echo -e "$linea"; done
    echo ""
}

run() {  # wrapper dry-run
    if $DRY; then echo "${y}[dry]${reset} $*"
    else "$@"; fi
}

execute() {
    local msg_progress="$1" msg_success="$2"; shift 2
    local logfile start_time pid
    logfile=$(mktemp)
    start_time=$(date +%s)

    if $DRY; then
        echo "${y}[dry]${reset} $msg_progress"
        RESUMEN+=("${y}[dry] $msg_progress${reset}")
        view_status
        return 0
    fi

    "$@" >"$logfile" 2>&1 &
    local pid=$!
    tput civis 2>/dev/null
    while kill -0 "$pid" 2>/dev/null; do
        local elapsed="$(( $(date +%s) - start_time ))"
        for frame in "${FRAME[@]}"; do
            if ! kill -0 "$pid" 2>/dev/null; then break; fi
            printf "\r${sb}[%s]${y} %s ${sb}(%s)${reset}   " "$frame" "$msg_progress" "$(format_time "$elapsed")"
            sleep "$FRAME_INTERVAL"
        done
    done
    tput cnorm 2>/dev/null

    wait "$pid"
    local code=$?
    local total="$(format_time "$(( $(date +%s) - start_time ))")"

    if [ $code -ne 0 ]; then
        RESUMEN+=("\n${r}[ERROR] ${msg_progress} (${total})${reset}")
        view_status
        echo -e "\n${r}[ERROR] Detenido. Log del fallo:${reset}\n"
        cat "$logfile"; rm -f "$logfile"; exit 1
    fi
    RESUMEN+=("${g}[✔] ${msg_success} ${sb}(${total})${reset}\n")
    rm -f "$logfile"
    view_status
}

# ─── Pasos ────────────────────────────────────────────────────────────────

system_update() {
    sudo env DEBIAN_FRONTEND=noninteractive apt-get -qq update
    sudo env DEBIAN_FRONTEND=noninteractive apt-get -qy upgrade
    sudo apt-get -qy autoremove
}

install_packages() {
    local distro=$1
    sudo env DEBIAN_FRONTEND=noninteractive apt-get install -y -qq \
        bspwm sxhkd polybar rofi picom feh scrot dunst kitty zsh \
        zsh-autosuggestions zsh-syntax-highlighting \
        adwaita-icon-theme xclip numlockx xdotool lsd \
        imagemagick mpv playerctl btop acpi bc jq xxhash \
        bat fzf ranger fastfetch lightdm lightdm-gtk-greeter xorg \
        x11-xserver-utils x11-utils xautolock arandr \
        flameshot brightnessctl rofimoji qalculate qalculate-data \
        i3lock maim wireless-tools pavucontrol pipx \
        neovim thunar thunar-archive-plugin tumbler \
        blueman bluez network-manager network-manager-gnome wpasupplicant \
        pipewire pipewire-pulse wireplumber pulseaudio-utils \
        clipmenu curl gawk rsync net-tools python3 python3-pip

    case "$distro" in
        kali)  sudo env DEBIAN_FRONTEND=noninteractive apt-get install -y -qq libdbusmenu-gtk3-4 ;;
        parrot) sudo env DEBIAN_FRONTEND=noninteractive apt-get install -y -qq \
                 libatk1.0-dev libatk-bridge2.0-dev libatspi2.0-dev \
                 libglib2.0-dev libpango1.0-dev libjson-glib-dev \
                 libwayland-dev libwebp-dev ;;
    esac
}

install_laptop_power() {
    # laptop detection
    ls /sys/class/power_supply/*BAT* >/dev/null 2>&1 || { echo "[skip] no es laptop"; return 0; }
    $NO_POWER && { echo "[skip] --no-power"; return 0; }
    sudo env DEBIAN_FRONTEND=noninteractive apt-get install -y -qq tlp thermald zram-tools powertop \
        || return 1
    sudo systemctl disable --now power-profiles-daemon 2>/dev/null || true
    sudo systemctl enable --now thermald 2>/dev/null || true
    sudo systemctl enable --now tlp 2>/dev/null || true
    echo "ALGO=zstd"  | sudo tee /etc/default/zramswap >/dev/null
    echo "PERCENT=40" | sudo tee -a /etc/default/zramswap >/dev/null
    sudo systemctl enable --now zramswap 2>/dev/null || true
}

clone_repositories() {
    mkdir -p ~/github
    git clone -q https://github.com/vinceliuice/Qogir-icon-theme.git ~/github/Qogir-icon-theme
    git clone -q --depth=1 https://github.com/romkatv/powerlevel10k.git ~/.powerlevel10k
}

install_icons_font_build() {
    # Qogir icons (script bash puro, no compila) + cursor del repo
    cd ~/github/Qogir-icon-theme || return 1
    ./install.sh -d "$HOME/.local/share/icons" -c standard -t default >/dev/null 2>&1 \
        || ./install.sh >/dev/null 2>&1

    dir="$(cd "$REPO" 2>/dev/null && pwd)"
    [ -d "$HOME/.local/share/icons/Qogir" ] || sudo ./install.sh

    local idx="$dir/installer/cursor/index.theme"
    if [ -f "$idx" ]; then
        sudo mkdir -p /usr/share/icons/default
        sudo rm -rf /usr/share/icons/default/index.theme
        sudo cp -f "$idx" /usr/share/icons/default/
        sudo cp -f "$dir/installer/cursor/.Xresources" "$HOME/.Xresources"
    fi

    cd "$dir" || cd ~
}

update_fonts_cache() {
    sudo fc-cache -fv >/dev/null 2>&1
}

themes_config() {
    local dir=$1 distro=$2

    # BACKUP de config previa (no destruir de golpe como el original)
    if [ -d "$HOME/.config" ] && [ ! -d "$HOME/.config-backup" ]; then
        mv "$HOME/.config" "$HOME/.config-backup-$(date +%Y%m%d-%H%M%S)" 2>/dev/null \
            || { echo "[warn] no se pudo backup ~/.config"; }
    fi
    [ -f "$HOME/.zshrc" ] && mv -f "$HOME/.zshrc" "$HOME/.zshrc.bak-$(date +%Y%m%d-%H%M%S)" 2>/dev/null

    # NerdFonts + polybar fonts (inclusive repo)
    sudo mkdir -p /usr/local/share/fonts /usr/share/fonts/truetype
    sudo cp -v "$dir/installer/fonts/HNF/"* /usr/local/share/fonts/ 2>/dev/null
    sudo cp -v "$dir/installer/fonts/polybar/"* /usr/share/fonts/truetype/ 2>/dev/null

    # Configs del entorno
    mkdir -p "$HOME/.config"
    cp -rv "$dir/installer/Config/"* "$HOME/.config/" 2>/dev/null

    # zsh del usuario (+ p10k del repo)
    cp -v "$dir/installer/.zshrc" "$HOME/.zshrc"
    cp -v "$dir/installer/.p10k.zsh" "$HOME/.p10k.zsh"
    sudo cp -v "$dir/installer/.p10k_root.zsh" /root/.p10k.zsh 2>/dev/null || true

    # plugin zsh sudo (comodidad: esc dos veces)
    sudo mkdir -p /usr/share/zsh-sudo
    [ -f /usr/share/zsh-sudo/sudo.plugin.zsh ] || \
        sudo wget -qO /usr/share/zsh-sudo/sudo.plugin.zsh \
            https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/plugins/sudo/sudo.plugin.zsh

    # wallpaper default (Nord, como base)
    rm -rf "$HOME/.Wallpaper"
    cp -r "$dir/Themes/Nord/Wallpaper" "$HOME/.Wallpaper"

    # pips del theme-system (pywal16 colormap + cloudscraper downloader)
    pip install pywal16 cloudscraper --break-system-packages --quiet 2>/dev/null \
        || pipx install pywal16 >/dev/null 2>&1 || true

    # Scripts del repo a /usr/local/bin (sin pentest: wifi, shortcuts, xwall, settings)
    sudo cp -v "$dir/installer/scripts/"* /usr/local/bin/ 2>/dev/null
    for script in shortcuts xwall wifi bspwm_settings; do
        sudo chmod +x "/usr/local/bin/$script" 2>/dev/null
    done
    sudo sed -i 's/\r$//' /usr/local/bin/shortcuts 2>/dev/null || true

    # permisos ejecutables en ~/.config
    chmod +x \
        "$HOME/.config/bin/scripts/"* \
        "$HOME/.config/bspwm/"* \
        "$HOME/.config/polybar/"*.sh \
        "$HOME/.config/polybar/themes/"*/*.sh \
        "$HOME/.config/ranger/"*.sh \
        "$HOME/.config/rofi/"*/* 2>/dev/null

    # picom activo según preset
    if [ "$PRESET" = "vm" ]; then
        cp -f "$dir/installer/Config/picom/no_blur_picom.conf" "$HOME/.config/picom/picom.conf"
    else
        cp -f "$dir/installer/Config/picom/picom.conf" "$HOME/.config/picom/picom.conf"
        # hw: anims SOLO si picom local las soporta (picom >= 12; Debian trixie = 11 → off)
        # (picom-animations.conf queda disponible para picom-git)
    fi

    # sesiones lightdm
    sudo chsh -s /usr/bin/zsh "$USER" 2>/dev/null || true
    sudo chsh -s /usr/bin/zsh root 2>/dev/null || true
    sudo ln -sfv "$HOME/.zshrc" /root/.zshrc 2>/dev/null || true
}

backup_repo() {
    mkdir -p "$HOME/.BSPWM"
    rsync -a --delete "$REPO/" "$HOME/.BSPWM/" >/dev/null 2>&1
}

cleanup_clone_repos() {
    sudo rm -rf ~/github 2>/dev/null
}

post_verify() {
    local ok=0 bad=0
    echo -e "${sb}[verify]${reset} comprobaciones post-instalación:"
    local check_item
    check_item() {
        if eval "$2" >/dev/null 2>&1; then
            echo -e " ${g}✔${reset} $1"; ok=$((ok + 1))
        else
            echo -e " ${r}✗${reset} $1"; bad=$((bad + 1))
        fi
    }
    check_item "bspwm instalado"        "command -v bspwm"
    check_item "polybar"                "command -v polybar"
    check_item "rofi"                   "command -v rofi"
    check_item "kitty"                  "command -v kitty"
    check_item "picom"                  "command -v picom"
    check_item "dunst"                  "command -v dunst"
    check_item "nvim (minimal)"         "command -v nvim"
    check_item "sessión lightdm on"     "systemctl is-enabled lightdm"
    check_item "sesión bspwm.desktop"   "[ -f /usr/share/xsessions/bspwm.desktop ]"
    check_item "temas en ~/.BSPWM"      "[ -d $HOME/.BSPWM/Themes ]"
    check_item "scripts ~/.config/bin"  "[ -x $HOME/.config/bin/scripts/ScreenLocker ]"
    check_item "fonts HNF instaladas"   "fc-list | grep -qi 'nerd'"
    check_item "zsh default user"       "[ \"\$(getent passwd \$USER | cut -d: -f7)\" = /usr/bin/zsh ]"
    echo -e "\n ${g}$ok ok${reset} / ${r}$bad faltantes${reset}"
    [ "$bad" -gt 0 ] && return 1
    return 0
}

# ─── GUIA ────────────────────────────────────────────────────────────────

banner
dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export REPO="$dir"

if [ "$EUID" -eq 0 ]; then
    echo -e "${sb}[!] ${y}Ejecutar SIN root: ./install.sh${reset}"
    exit 1
elif grep -qi debian /etc/os-release; then
    echo -e "${sb}[+] ${g}Debian${reset} (preset: ${sb}${PRESET}${reset})"
    distro=debian
elif grep -qi kali /etc/os-release; then
    echo -e "${sb}[+] ${y}Kali Linux${reset} (base frontend)"
    distro=kali
elif grep -qi parrot /etc/os-release; then
    echo -e "${sb}[+] ${g}Parrot OS${reset}"
    distro=parrot
else
    echo -e "${y}[WARNING] Distro no reconocida (solo Debian/Kali/Parrot soportados)${reset}"
    grep -i "^PRETTY_NAME" /etc/os-release 2>/dev/null | head -1
    exit 1
fi

echo -e "${sb}[INFO] Se pedirá tu contraseña sudo.\n"
sudo -v || { echo -e "\n${r}[ERROR] Fallo autenticación sudo.${reset}"; exit 1; }
banner
(
    while :; do sudo -n true 2>/dev/null || break; sleep 50; done
) &
SUDO_KEEPER_PID=$!
trap 'kill $SUDO_KEEPER_PID 2>/dev/null' EXIT

execute "Actualizando sistema"          "Sistema actualizado"               system_update
execute "Instalando paquetes apt"       "Paquetes base instalados"          install_packages "$distro"
execute "Optimización laptop (tlp/zram)" "Energía thinkpad configurada"     install_laptop_power
execute "Clonando Qogir + powerlevel10k" "Repos auxiliares clonados"        clone_repositories
execute "Iconos Qogir + cursor"         "Iconos y cursor instalados"        install_icons_font_build
execute "Actualizando cache fonts"      "Fuentes disponibles"               update_fonts_cache
execute "Aplicando theme system"        "Configs instaladas en ~/.config"   themes_config "$dir" "$distro"
execute "Respaldo repo → ~/.BSPWM"      "Theme system listo (usa ~/.BSPWM)" backup_repo
execute "Limpiando clones temporales"   "Cleanup ok"                        cleanup_clone_repos
execute "Actualizando sistema (final)"  "Sistema al día"                    system_update

# lightdm enable (instalado con xorg arriba)
sudo systemctl enable lightdm 2>/dev/null || true
sudo systemctl set-default graphical.target 2>/dev/null || true

if post_verify; then
    echo -e "\n${g}[✔] ${sb}BSPWM ${y}instalado correctamente${reset}"
    echo -e "${g}[✔]${reset} Reboot → LightDM → sesión ${sb}bspwm${reset}"
    echo -e "  - Ayuda: ${sb}alt+F1${reset} (cheatsheet sxhkd)"
    echo -e "  - Tema:  ${sb}super+ctrl+t${reset} (previews de los 9 temas)"
    echo -e "  - Barra: ${sb}super+ctrl+p${reset} (Cuts/Lofi/Pacman/Round/Shapes)"
    echo -e "  - Docs:  ${sb}README.md${reset} del repo"
else
    echo -e "\n${y}[!] Con faltantes: revisá los paquetes y el log (install/fc-cache).${reset}"
    echo -e "${y}    Puedes seguir: los scripts degradan con aviso, el arranque es funcional.${reset}"
fi
