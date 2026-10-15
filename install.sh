#!/bin/bash
# ==============================================================================
#  install.sh — dotfiles_debian v3 (base gh0stzk, comandos JaKoolit)
#  Port Debian 12/13 del installer Arch-only de gh0stzk/dotfiles (GPL-3.0)
#
#  Cambios vs upstream:
#   • apt en vez de pacman/chaotic — CERO compilaciones (sin eww/rustup/npm/paru)
#   • clipcat→clipmenu · pamixer→pactl · i3lock-color→i3lock (vanilla port)
#   • eww descartado (16/18 barras polybar; bar02/bar18 filtradas del selector)
#   • 14 paquetes gh0stzk (icons/gtk/cursor) desde github.com/gh0stzk/pkgs (raw)
#   • JetBrainsMono Nerd Font desde releases de nerd-fonts (la usan las rices)
#   • fzf-tab vendorizado en el repo (sin git post-install)
#   • sxhkdrc con capa JaKoolit · presets vm/hw · backups ~/.RiceBackup
#
#  Uso:
#    ./install.sh                 # completo, preset autodetectado
#    ./install.sh --preset vm     # picom xrender (VirtualBox)
#    ./install.sh --preset hw     # glx — ThinkPad/clasico
#    ./install.sh --no-icons      # skip icon themes de gh0stzk
#    ./install.sh --no-power      # skip tlp/zram (VM)
#    ./install.sh --dry-run       # mostrar acciones sin ejecutar
# ==============================================================================

GRN=$'\e[32m'; YLW=$'\e[33m'; RED=$'\e[31m'; BLU=$'\e[34m'; CYN=$'\e[36m'; RST=$'\e[0m'
PRESET="auto"; NO_POWER=false; NO_ICONS=false; DRY=false; NEXT=false

for arg in "$@"; do
    case "$arg" in
        --preset=*) PRESET="${arg#--preset=}" ;;
        --preset) NEXT=true ;;
        vm|hw) [ "$NEXT" = true ] && PRESET="$arg" && NEXT=false ;;
        --no-power) NO_POWER=true ;;
        --no-icons) NO_ICONS=true ;;
        --dry-run) DRY=true ;;
        --help|-h) sed -n '3,20p' "$0" | sed "s/^#\s*//"; exit 0 ;;
    esac
done
[ "$PRESET" = "auto" ] && { PRESET=hw; command -v systemd-detect-virt >/dev/null 2>&1 && systemd-detect-virt -q && PRESET=vm; }

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOGFILE=$(mktemp)
RESUMEN=()
FRAME=("⠋" "⠙" "⠹" "⠸" "⠼" "⠴" "⠦" "⠧" "⠇" "⠏")

banner() {
    echo -e "${CYN}══════════════════════════════════════════════${RST}"
    echo -e "  Dotfiles Debian v3 — ${YLW}base gh0stzk · comandos JaKoolit${RST}"
    echo -e "${CYN}══════════════════════════════════════════════${RST}"
}

ask() { local def="${2:-n}"; read -rp "$1 [$def] " a; a="${a:-$def}"; [[ "$a" =~ ^[YySs] ]]; }

format_time() { local s=$1; [ "$s" -lt 60 ] && echo "${s}s" || echo "$((s/60))m $((s%60))s"; }

view_status() { clear; banner; for l in "${RESUMEN[@]}"; do echo -e "$l"; done; echo; }

execute() {
    local msg_prog="$1" msg_ok="$2"; shift 2
    if $DRY; then
        echo -e "${YLW}[dry]${RST} $msg_prog"
        RESUMEN+=("${YLW}[dry]${RST} $msg_prog")
        view_status
        return 0
    fi
    echo -e "${CYN}[..]${RST} $msg_prog"
    local t0 code
    t0=$(date +%s)
    ("$@") > "$LOGFILE" 2>&1 &
    local pid=$! i=0
    while kill -0 "$pid" 2>/dev/null; do
        printf "\r${CYN}[%s]${YLW} %s${RST}   " "${FRAME[$((i % 10))]}" "$msg_prog"
        sleep 0.15; i=$((i + 1))
    done
    wait "$pid"; code=$?
    local total; total=$(format_time "$(( $(date +%s) - t0 ))")
    if [ $code -ne 0 ]; then
        echo ""
        RESUMEN+=("${RED}[ERROR]${RST} $msg_prog (${total})")
        echo -e "\n${RED}Fallo en: $msg_prog${RST} — log:"
        tail -25 "$LOGFILE"
        exit 1
    fi
    RESUMEN+=("${GRN}[✔]${RST} $msg_ok ${CYN}(${total})${RST}")
    view_status
}

# ── apt helpers (v2.0.2 machinery) ──────────────────────────
apt_with_retry() {
    local n=0 out
    while : ; do
        if out=$(sudo env DEBIAN_FRONTEND=noninteractive "$@" 2>&1); then
            return 0
        fi
        if printf '%s\n' "$out" | grep -qiE "could not get lock|mutex|lock-frontend"; then
            n=$((n + 1)); [ "$n" -ge 3 ] && { printf '%s\n' "$out" | tail -6; return 1; }
            sleep 30
        else
            printf '%s\n' "$out" | tail -8; return 1
        fi
    done
}

system_update() {
    apt_with_retry apt-get -qq update
    apt_with_retry apt-get -qy upgrade
    apt_with_retry apt-get autoremove -qy
}

install_core() {
    local rc=0
    apt_with_retry apt-get install -y -qq \
        bspwm sxhkd polybar rofi picom dunst feh maim alacritty kitty \
        thunar thunar-archive-plugin tumbler gvfs-backends \
        geany imagemagick jq curl xclip xdotool xdo xdg-user-dirs \
        x11-utils x11-apps x11-xserver-utils xorg lightdm lightdm-gtk-greeter \
        playerctl mpc mpd mpv ncmpcpp pavucontrol lxsession redshift \
        webp-pixbuf-loader papirus-icon-theme \
        zsh zsh-autosuggestions zsh-syntax-highlighting zsh-history-substring-search \
        bat eza fzf xautolock brightnessctl i3lock jgmenu xsettingsd \
        clipmenu flameshot unzip zstd git || rc=$?

    if [ $rc -ne 0 ]; then
        echo "${YLW}[apt] lote falló → reintento paquete por paquete${RST}"
        for p in bspwm sxhkd polybar rofi picom dunst feh maim alacritty kitty \
                 thunar gvfs-backends geany imagemagick jq curl xclip xdotool xdo \
                 xdg-user-dirs x11-utils x11-apps x11-xserver-utils xorg lightdm \
                 lightdm-gtk-greeter playerctl mpc mpd mpv ncmpcpp pavucontrol \
                 lxsession redshift webp-pixbuf-loader \
                 zsh zsh-autosuggestions zsh-syntax-highlighting zsh-history-substring-search \
                 bat eza fzf xautolock brightnessctl i3lock jgmenu xsettingsd \
                 clipmenu flameshot git; do
            dpkg -s "$p" >/dev/null 2>&1 && continue
            apt_with_retry apt-get install -y -qq "$p" \
                || echo "${RED}  ✗ $p${RST} (opcional: scripts degradan con aviso)"
        done
    fi
    return 0
}

install_power() {
    ls /sys/class/power_supply/*BAT* >/dev/null 2>&1 || { echo "[skip] no es laptop"; return 0; }
    $NO_POWER && { echo "[skip] --no-power"; return 0; }
    local rc=0
    apt_with_retry apt-get install -y -qq tlp thermald zram-tools powertop || rc=$?
    sudo systemctl disable --now power-profiles-daemon 2>/dev/null || true
    sudo systemctl enable --now thermald 2>/dev/null || true
    sudo systemctl enable --now tlp 2>/dev/null || true
    { echo "ALGO=zstd"; echo "PERCENT=40"; } | sudo tee /etc/default/zramswap >/dev/null 2>/dev/null
    sudo systemctl enable --now zramswap 2>/dev/null || true
    return $rc
}

download_nerd_font() {
    # JetBrainsMono Nerd Font — usada por las rices y el ScreenLocker
    local url="https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.zip"
    local tmp; tmp=$(mktemp -d)
    if ! curl -fsSL --max-time 180 "$url" -o "$tmp/jbm.zip"; then
        echo "${YLW}[warn] no se pudo descargar JetBrainsMono NF (seguedo al bundle del repo)${RST}"
        rm -rf "$tmp"; return 0
    fi
    unzip -q -o "$tmp/jbm.zip" -d "$tmp/nf" 2>/dev/null
    sudo mkdir -p /usr/local/share/fonts
    sudo cp "$tmp/nf/"*.ttf /usr/local/share/fonts/ 2>/dev/null
    sudo fc-cache -f >/dev/null 2>&1
    rm -rf "$tmp"
    return 0
}

PKGS_URL="https://raw.githubusercontent.com/gh0stzk/pkgs/master/x86_64"
GZ_PKGS=(
    gh0stzk-cursor-qogirr-1.0-1-any.pkg.tar.zst
    gh0stzk-gtk-themes-1.0-1-any.pkg.tar.zst
    gh0stzk-icons-beautyline-1.0-0-any.pkg.tar.zst
    gh0stzk-icons-candy-1.0-0-any.pkg.tar.zst
    gh0stzk-icons-catppuccin-mocha-1.0-0-any.pkg.tar.zst
    gh0stzk-icons-dracula-1.0-0-any.pkg.tar.zst
    gh0stzk-icons-glassy-1.0-0-any.pkg.tar.zst
    gh0stzk-icons-gruvbox-plus-dark-1.0-0-any.pkg.tar.zst
    gh0stzk-icons-hack-1.0-0-any.pkg.tar.zst
    gh0stzk-icons-luv-1.0-0-any.pkg.tar.zst
    gh0stzk-icons-sweet-rainbow-1.0-0-any.pkg.tar.zst
    gh0stzk-icons-tokyo-night-1.0-0-any.pkg.tar.zst
    gh0stzk-icons-vimix-white-1.0-0-any.pkg.tar.zst
    gh0stzk-icons-zafiro-1.0-0-any.pkg.tar.zst
    gh0stzk-icons-zafiro-purple-1.0-0-any.pkg.tar.zst
)

install_gh0stzk_pkgs() {
    $NO_ICONS && { echo "[skip] --no-icons"; return 0; }
    command -v curl >/dev/null || { echo "[warn] curl faltante"; return 0; }
    local tmp; tmp=$(mktemp -d)
    local failed=0
    for pkg in "${GZ_PKGS[@]}"; do
        if ! curl -fsSL --max-time 120 "$PKGS_URL/$pkg" -o "$tmp/$pkg"; then
            echo "${YLW}[warn] no se pudo bajar: $pkg${RST}"; failed=$((failed + 1)); continue
        fi
        tar --zstd -xf "$tmp/$pkg" -C "$tmp" 2>/dev/null || failed=$((failed + 1))
    done
    if [ -d "$tmp/usr" ]; then
        sudo cp -a "$tmp/usr/." /usr/ 2>/dev/null
        sudo fc-cache -f >/dev/null 2>&1
    fi
    rm -rf "$tmp"
    [ "$failed" -gt 0 ] && echo "${YLW}[warn] $failed pkgs gh0stzk fallaron (rices bootearán con papirus/Adwaita)${RST}"
    return 0
}

install_configs() {
    local dir="$REPO"
    local CFG="$HOME/.config"

    # BACKUP estilo gh0stzk: ~/.RiceBackup/<ts>
    if [ -d "$CFG" ]; then
        mkdir -p "$HOME/.RiceBackup"
        mv "$CFG" "$HOME/.RiceBackup/$(date +%Y%m%d-%H%M%S)"
    fi
    [ -f "$HOME/.zshrc" ] && mv -f "$HOME/.zshrc" "$HOME/.RiceBackup/zshrc-$(date +%Y%m%d-%H%M%S)"

    mkdir -p "$CFG" "$HOME/.local/share" "$HOME/.local/bin" "$HOME/Imágenes/ScreenShots"

    cp -r "$dir/config/." "$CFG/"
    cp -r "$dir/misc/fonts/." "$HOME/.local/share/fonts/" 2>/dev/null
    cp -r "$dir/misc/asciiart/." "$HOME/.local/share/asciiart/" 2>/dev/null
    cp "$dir/misc/bin/"* "$HOME/.local/bin/" 2>/dev/null
    cp -r "$dir/misc/applications/." "$HOME/.local/share/applications/" 2>/dev/null
    cp "$dir/home/.zshrc" "$HOME/.zshrc"

    chmod +x "$CFG/bspwm/bin/"* 2>/dev/null
    chmod +x "$CFG/bspwm/autostart.sh" 2>/dev/null
    find "$CFG/bspwm/bars" "$CFG/bspwm/rices" "$CFG/bspwm/config/modules" \
         -type f \( -name "*.sh" -o -name "*.bash" \) -exec chmod +x {} + 2>/dev/null
    chmod +x "$HOME/.local/bin/"* 2>/dev/null

    # picom preset
    if [ "$PRESET" = "vm" ]; then
        cp -f "$CFG/bspwm/config/picom/picom-vm.conf" "$CFG/bspwm/config/picom/picom.conf"
        echo "[preset vm] picom → backend xrender"
    fi

    fc-cache -f >/dev/null 2>&1
    sudo chsh -s /usr/bin/zsh "$USER" 2>/dev/null || true
    sudo systemctl enable lightdm 2>/dev/null || true
    sudo systemctl set-default graphical.target 2>/dev/null || true
}

update_and_verify() {
    local ok=0 bad=0
    chk() {
        if eval "$2" >/dev/null 2>&1; then echo " ${GRN}✔${RST} $1"; ok=$((ok + 1))
        else echo " ${RED}✗${RST} $1"; bad=$((bad + 1)); fi
    }
    echo -e "${CYN}[verify]${RST} comprobaciones post-instalación:"
    chk "bspwm"                "command -v bspwm"
    chk "sxhkd"                "command -v sxhkd"
    chk "polybar"              "command -v polybar"
    chk "rofi"                 "command -v rofi"
    chk "picom"                "command -v picom"
    chk "dunst"                "command -v dunst"
    chk "kitty"                "command -v kitty"
    chk "alacritty"            "command -v alacritty"
    chk "jgmenu"               "command -v jgmenu"
    chk "rice emilia activa"   "[ \"\$(cat $HOME/.config/bspwm/.rice 2>/dev/null)\" = emilia ]"
    chk "RiceSelector"         "[ -x $HOME/.config/bspwm/bin/RiceSelector ]"
    chk "Volume pactl"         "grep -q 'pactl' $HOME/.config/bspwm/bin/Volume"
    chk "ScreenLocker vanilla" "grep -q 'i3lock -n -t -i' $HOME/.config/bspwm/bin/ScreenLocker"
    chk "fzf-tab vendored"     "[ -f $HOME/.config/zsh/fzf-tab/fzf-tab.zsh ]"
    chk "JetBrainsMono NF"     "fc-list | grep -qi 'JetBrainsMono Nerd'"
    chk "GTK themes gh0stzk"   "[ -d /usr/share/themes/Andrea-zk ]"
    chk "cursor Qogirr pkg"    "[ -n \"\$(find /usr/share/icons -maxdepth 1 -iname '*Qogirr*')\" ]"
    chk "fonts misc bundle"    "fc-list | grep -qi 'Maple Mono'"
    chk "clipmenu"             "command -v clipmenu"
    chk "lightdm enabled"      "systemctl is-enabled lightdm"
    chk "zsh default user"     "[ \"\$(getent passwd \$USER | cut -d: -f7)\" = /usr/bin/zsh ]"
    echo -e "\n ${GRN}$ok ok${RST} / ${RED}$bad faltantes${RST}"
    return 0
}

# ─────────────────────────────────────────────────────────────
banner

if [ "$(id -u)" -eq 0 ]; then echo -e "${RED}ERROR:${RST} no corras con sudo/root."; exit 1; fi
DISTRO=$(grep -oP '^ID=\K.*' /etc/os-release 2>/dev/null)
case "$DISTRO" in
    debian*) ;;
    *) echo "${YLW}AVISO: pensado para Debian 12/13 — distro detectada: ${DISTRO:-?}${RST}" ;;
esac
if ! $DRY; then
    sudo -v 2>/dev/null || { echo -e "${RED}Falta sudo${RST}"; exit 1; }
    ( while :; do sudo -n true 2>/dev/null || break; sleep 50; done ) &
    SUDO_KEEPER=$!
    trap 'kill $SUDO_KEEPER 2>/dev/null' EXIT
fi

execute "Actualizando sistema"        "Sistema al día"              system_update
execute "Instalando core apt"         "Core Debian instalado"       install_core
execute "Energía laptop (tlp/zram)"   "Energía laptop (o skip VM)"  install_power
execute "JetBrainsMono Nerd Font"     "Font Nerd instalada"         download_nerd_font
execute "Pack gh0stzk (icons/gtk/cursor)" "Themes gh0stzk en /usr/share" install_gh0stzk_pkgs
execute "Copiando configs (+backup)"  "Configs en ~/.config"        install_configs
execute "Update + verify"             "Verificación completa"       update_and_verify

echo -e "\n${GRN}■ Instalación completa${RST} — preset ${CYN}${PRESET^^}${RST}"
echo "  Siguiente: ${CYN}sudo reboot${RST} → LightDM → sesión ${CYN}bspwm${RST}"
echo "  Cheatsheet: ${CYN}alt+F1${RST} · RiceSelector: ${CYN}alt+space${RST} · BarSelector: ${CYN}super+alt+space${RST}"
if ask "¿Reboot ahora?" n; then
    sudo systemctl reboot
fi
exit 0
