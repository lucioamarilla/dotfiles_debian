#!/bin/bash
# ==============================================================================
#  install.sh — dotfiles_eos v4 (base gh0stzk, comandos JaKoolit)
#  Port EndeavourOS del installer del port Debian v3 (base gh0stzk, GPL-3.0)
#
#  Cambios vs la versión Debian (v3):
#   • pacman + AUR helper (yay primero — default de EOS; paru fallback)
#   • checkupdates (pacman-contrib) + <helper> -Qua en Updates
#   • zram-generator en vez de zram-tools · gvfs/gvfs-mtp en vez de gvfs-backends
#   • pkgs gh0stzk instalados con pacman -U (son paquetes Arch nativos)
#   • rice default: "endeavour" (paleta púrpura/magenta de EndeavourOS)
#   • zsh "Ubuntu Edition": oh-my-zsh + agnosterzak + fzf-tab + lsd
#     (pokemon-colorscripts|fastfetch instalados, desactivados por defecto)
#   • VM: guest-utils auto + guard preset · clipmenu se mantiene (repo oficial)
#
#  Uso:
#    ./install.sh                 # completo, preset autodetectado
#    ./install.sh --preset vm     # picom xrender (VirtualBox)
#    ./install.sh --preset hw     # glx — laptop/pc clásico (tlp + zram)
#    ./install.sh --no-icons      # skip pack de temas de gh0stzk
#    ./install.sh --no-vbox       # skip guest-utils VirtualBox (solo VM)
#    ./install.sh --no-power      # skip tlp/zram (VM)
#    ./install.sh --dry-run       # mostrar acciones sin ejecutar
# ==============================================================================

GRN=$'\e[32m'; YLW=$'\e[33m'; RED=$'\e[31m'; BLU=$'\e[34m'; CYN=$'\e[36m'
PUR=$'\e[38;2;127;63;191m'   # EndeavourOS purple
MAG=$'\e[38;2;220;53;238m'   # EndeavourOS magenta
RST=$'\e[0m'
PRESET="auto"; NO_POWER=false; NO_ICONS=false; NO_VBOX=false; DRY=false; NEXT=false
AUR_HELPER=""

for arg in "$@"; do
    case "$arg" in
        --preset=*) PRESET="${arg#--preset=}" ;;
        --preset) NEXT=true ;;
        vm|hw) [ "$NEXT" = true ] && PRESET="$arg" && NEXT=false ;;
        --no-power) NO_POWER=true ;;
        --no-icons) NO_ICONS=true ;;
        --no-vbox) NO_VBOX=true ;;
        --dry-run) DRY=true ;;
        --help|-h) sed -n '3,22p' "$0" | sed "s/^#\s*//"; exit 0 ;;
    esac
done
[ "$PRESET" = "auto" ] && { PRESET=hw; command -v systemd-detect-virt >/dev/null 2>&1 && systemd-detect-virt -q && PRESET=vm; }

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOGFILE=$(mktemp)
RESUMEN=()
FRAME=("⠋" "⠙" "⠹" "⠸" "⠼" "⠴" "⠦" "⠧" "⠇" "⠏")

banner() {
    echo -e "${PUR}══════════════════════════════════════════════${RST}"
    echo -e "  Dotfiles EndeavourOS v4 — ${MAG}base gh0stzk · comandos JaKoolit${RST}"
    echo -e "${PUR}══════════════════════════════════════════════${RST}"
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

# ── pacman helpers ───────────────────────────────────────────
# Espera hasta 90s si otro pacman (o el Welcome de EOS) tiene el lock de la db.
pacman_wait_lock() {
    local n=0
    while [ -f /var/lib/pacman/db.lck ] && pgrep -x pacman >/dev/null 2>&1; do
        n=$((n + 1)); [ "$n" -ge 90 ] && return 1
        sleep 1
    done
    return 0
}

pkg_installed() { pacman -Qq "$1" >/dev/null 2>&1; }

pacman_install() {
    # instala solo lo que falta; espera el lock antes de tocar la db
    local missing=() p
    for p in "$@"; do pkg_installed "$p" || missing+=("$p"); done
    [ ${#missing[@]} -eq 0 ] && return 0
    pacman_wait_lock || return 1
    sudo pacman -S --needed --noconfirm --noprogressbar "${missing[@]}" 2>&1
}

system_update() {
    pacman_wait_lock || return 1
    sudo pacman -Syu --noconfirm --noprogressbar 2>&1
    # huerfanos (solo si existen)
    local orphans
    orphans=$(pacman -Qtdq 2>/dev/null) || true
    if [ -n "$orphans" ]; then
        pacman_wait_lock || return 1
        echo "$orphans" | sudo pacman -Rns --noconfirm --noprogressbar - 2>&1 || true
    fi
}

detect_aur_helper() {
    local h
    for h in yay paru; do
        command -v "$h" >/dev/null 2>&1 && { AUR_HELPER="$h"; return 0; }
    done
    return 1
}

install_aur_helper() {
    if detect_aur_helper; then
        echo "  helper detectado: ${AUR_HELPER}"
        return 0
    fi
    # En EOS 'yay' vive en el repo endeavouros → instalable con pacman directo
    echo "  sin helper AUR → instalando yay desde el repo endeavouros"
    pacman_install yay || return 1
    detect_aur_helper
}

# ── core: lista Arch/EndeavourOS ─────────────────────────────
# Nota: xautolock está en el AUR desde la limpieza de huérfanos de Arch
# (Spring cleanup '25) → va en AUR_PKGS. qalc = libqalculate (no 'qalculate').
CORE_PKGS=(
    base-devel
    bspwm sxhkd polybar rofi picom dunst feh maim alacritty kitty
    thunar thunar-archive-plugin tumbler gvfs gvfs-mtp
    geany imagemagick jq curl xclip xdotool xdo xdg-user-dirs
    xorg-server xorg-xinit xorg-xev xorg-xwininfo xorg-xrdb xorg-xrandr xorg-xset
    lightdm lightdm-gtk-greeter
    playerctl mpc mpd mpv ncmpcpp pavucontrol lxsession redshift
    webp-pixbuf-loader papirus-icon-theme
    zsh zsh-autosuggestions zsh-syntax-highlighting zsh-history-substring-search
    oh-my-zsh lsd fastfetch
    bat eza fzf brightnessctl i3lock jgmenu xsettingsd
    clipmenu flameshot unzip zstd git
    python-gobject libqalculate pacman-contrib
    network-manager-applet blueman
)

# Paquetes del AUR (requieren helper — instalados después de install_core)
# pokemon-colorscripts-git instala el binario /usr/local/bin (así era en tu
# Ubuntu); el fork-git es fallback si el build del original falla.
AUR_PKGS=(xautolock pokemon-colorscripts-git)

install_core() {
    pacman_wait_lock || return 1
    local out
    if ! out=$(pacman_install "${CORE_PKGS[@]}"); then
        echo "${YLW}[pacman] lote falló → reintento paquete por paquete${RST}"
        for p in "${CORE_PKGS[@]}"; do
            pkg_installed "$p" && continue
            pacman_wait_lock || true
            if ! out=$(pacman_install "$p"); then
                echo "${RED}  ✗ $p${RST} (opcional: scripts degradan con aviso)"
                echo "$out" | tail -3
            fi
        done
    fi
    return 0
}

install_aur_pkgs() {
    [ ${#AUR_PKGS[@]} -gt 0 ] || { echo "[skip] sin paquetes AUR"; return 0; }
    command -v yay >/dev/null 2>&1 || command -v paru >/dev/null 2>&1 || {
        echo "${YLW}[warn] sin helper AUR — se omite: ${AUR_PKGS[*]}${RST}"; return 0; }
    local h; h=$(command -v yay || command -v paru)
    # pkg_installed no distingue repo/AUR; -Qea cubre paquetes AUR instalados
    local missing=() p
    for p in "${AUR_PKGS[@]}"; do pkg_installed "$p" || missing+=("$p"); done
    [ ${#missing[@]} -eq 0 ] && { echo "  AUR ya al día"; return 0; }
    for p in "${missing[@]}"; do
        pacman_wait_lock || return 1
        if ! "$h" -S --needed --noconfirm "$p" >/dev/null 2>&1; then
            # fallback conocido: pokemon-colorscripts-git → fork-git
            if [ "$p" = "pokemon-colorscripts-git" ] && ! pkg_installed pokemon-colorscripts-fork-git 2>/dev/null; then
                echo "${YLW}[aur] $p falló → intentando pokemon-colorscripts-fork-git${RST}"
                pacman_wait_lock || return 1
                "$h" -S --needed --noconfirm pokemon-colorscripts-fork-git >/dev/null 2>&1 \
                    || echo "${RED}  ✗ pokemon-colorscripts${RST} (sin pokemon art; fastfetch solo)"
            else
                echo "${RED}  ✗ $p${RST} (opcional)"; fi
        fi
    done
    return 0
}

# Tools de la VM VirtualBox (Guest Additions): portapapeles bi-dir, resize,
# integración de pointer —sin esto la sesión se ve 'zombie' a veces en BSPWM.
install_vm_tools() {
    local virt
    virt=$(systemd-detect-virt -v 2>/dev/null || true)
    case "$virt" in
        ""|none) echo "[skip] no es VM" ; return 0 ;;
        oracle)
            if $NO_VBOX; then echo "[skip] --no-vbox"; return 0; fi
            pacman_wait_lock || return 1
            pacman_install virtualbox-guest-utils || { echo "${RED}  ✗ virtualbox-guest-utils${RST}"; return 0; }
            sudo systemctl enable --now vboxservice.service 2>/dev/null || true
            echo "  guest-utils + vboxservice activos"
            ;;
        *)  echo "[skip] virt=$virt (no virtualbox — guest-utils de esa hipervisor)" ;;
    esac
    return 0
}

install_power() {
    ls /sys/class/power_supply/*BAT* >/dev/null 2>&1 || { echo "[skip] no es laptop"; return 0; }
    $NO_POWER && { echo "[skip] --no-power"; return 0; }
    pacman_wait_lock || return 1
    pacman_install tlp thermald powertop zram-generator || true
    sudo systemctl disable --now power-profiles-daemon 2>/dev/null || true
    sudo systemctl enable --now thermald 2>/dev/null || true
    sudo systemctl enable --now tlp 2>/dev/null || true
    # zram-generator (udev-triggered: systemd-zram-setup@zram0)
    sudo tee /etc/systemd/zram-generator.conf >/dev/null 2>&1 <<'EOF'
[zram0]
zram-size = min(ram / 2, 8192)
compression-algorithm = zstd
EOF
    sudo systemctl start systemd-zram-setup@zram0.service 2>/dev/null || true
    return 0
}

download_nerd_font() {
    # JetBrainsMono Nerd Font — usada por las rices y el ScreenLocker
    local url="https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.zip"
    local tmp; tmp=$(mktemp -d)
    if ! curl -fsSL --max-time 180 "$url" -o "$tmp/jbm.zip"; then
        echo "${YLW}[warn] no se pudo descargar JetBrainsMono NF (sigue el bundle del repo)${RST}"
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
        # Son paquetes Arch nativos: pacman los registra. Fallback: extracción tar.
        pacman_wait_lock || true
        if ! sudo pacman -U --noconfirm --noprogressbar "$tmp/$pkg" >/dev/null 2>&1; then
            tar --zstd -xf "$tmp/$pkg" -C "$tmp" 2>/dev/null || failed=$((failed + 1))
        fi
    done
    if [ -d "$tmp/usr" ]; then
        sudo cp -a "$tmp/usr/." /usr/ 2>/dev/null
    fi
    sudo fc-cache -f >/dev/null 2>&1
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

    local PICS_DIR
    PICS_DIR=$(xdg-user-dir PICTURES 2>/dev/null || true)
    [ -z "$PICS_DIR" ] && PICS_DIR="$HOME/Pictures"
    mkdir -p "$CFG" "$HOME/.local/share" "$HOME/.local/bin" "$PICS_DIR/ScreenShots"

    cp -r "$dir/config/." "$CFG/"
    cp -r "$dir/misc/fonts/." "$HOME/.local/share/fonts/" 2>/dev/null
    cp -r "$dir/misc/asciiart/." "$HOME/.local/share/asciiart/" 2>/dev/null
    cp "$dir/misc/bin/"* "$HOME/.local/bin/" 2>/dev/null
    cp -r "$dir/misc/applications/." "$HOME/.local/share/applications/" 2>/dev/null
    cp "$dir/home/.zshrc" "$HOME/.zshrc"

    # ── Terminal Ubuntu Edition: oh-my-zsh custom + fastfetch ──
    ZSH_CUSTOM="$HOME/.config/zsh/custom"
    mkdir -p "$ZSH_CUSTOM/themes" "$ZSH_CUSTOM/plugins" "$CFG/fastfetch"
    cp "$dir/home/agnosterzak.zsh-theme" "$ZSH_CUSTOM/themes/agnosterzak.zsh-theme" 2>/dev/null
    # fzf-tab vendored (repo config/zsh/fzf-tab) → como plugin de OMZ
    if [ -d "$dir/config/zsh/fzf-tab" ]; then
        rm -rf "$ZSH_CUSTOM/plugins/fzf-tab"
        cp -r "$dir/config/zsh/fzf-tab" "$ZSH_CUSTOM/plugins/fzf-tab"
    fi
    cp -r "$dir/config/fastfetch/." "$CFG/fastfetch/" 2>/dev/null

    chmod +x "$CFG/bspwm/bin/"* 2>/dev/null
    chmod +x "$CFG/bspwm/autostart.sh" 2>/dev/null
    find "$CFG/bspwm/bars" "$CFG/bspwm/rices" "$CFG/bspwm/config/modules" \
         -type f \( -name "*.sh" -o -name "*.bash" -o -name "theme-config.bash" \) -exec chmod +x {} + 2>/dev/null
    chmod +x "$HOME/.local/bin/"* 2>/dev/null

    # rice default: endeavour (paleta EndeavourOS)
    echo "endeavour" > "$CFG/bspwm/.rice"

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
    chk "helper AUR (yay/paru)" "command -v yay || command -v paru"
    chk "checkupdates"         "command -v checkupdates"
    chk "xautolock (AUR)"      "command -v xautolock"
    chk "qalc (libqalculate)"  "command -v qalc"
    chk "oh-my-zsh (pkg/clone)" "[ -d /usr/share/oh-my-zsh ] || [ -d $HOME/.oh-my-zsh ]"
    chk "theme agnosterzak"    "[ -f $HOME/.config/zsh/custom/themes/agnosterzak.zsh-theme ]"
    chk "fzf-tab plugin OMZ"   "[ -f $HOME/.config/zsh/custom/plugins/fzf-tab/fzf-tab.zsh ]"
    chk "lsd (alias ls)"       "command -v lsd"
    chk "fastfetch"            "command -v fastfetch && [ -f $HOME/.config/fastfetch/config-pokemon.jsonc ]"
    chk "pokemon-colorscripts" "command -v pokemon-colorscripts"
    chk "rice endeavour activa" "[ \"\$(cat $HOME/.config/bspwm/.rice 2>/dev/null)\" = endeavour ]"
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
    chk "rice endeavour en rices" "[ -f $HOME/.config/bspwm/rices/endeavour/theme-config.bash ]"
    echo -e "\n ${GRN}$ok ok${RST} / ${RED}$bad faltantes${RST}"
    return 0
}

# ─────────────────────────────────────────────────────────────
banner

if [ "$(id -u)" -eq 0 ]; then echo -e "${RED}ERROR:${RST} no corras con sudo/root."; exit 1; fi
DISTRO=$(grep -oP '^ID=\K.*' /etc/os-release 2>/dev/null)
case "$DISTRO" in
    endeavouros|arch) ;;
    *) echo -e "${YLW}AVISO: pensado para EndeavourOS (Arch-based) — distro detectada: ${DISTRO:-?}${RST}" ;;
esac
if ! $DRY; then
    sudo -v 2>/dev/null || { echo -e "${RED}Falta sudo${RST}"; exit 1; }
    ( while :; do sudo -n true 2>/dev/null || break; sleep 50; done ) &
    SUDO_KEEPER=$!
    trap 'kill $SUDO_KEEPER 2>/dev/null' EXIT
fi

# Guard de preset: picom glx sobre software-rendering en una VM = sesión
# lag/cuelga todo. Se pregunta (default sí) y se cambia a vm.
VIRT_TYPE=$(systemd-detect-virt -v 2>/dev/null || true)
if [ -n "$VIRT_TYPE" ] && [ "$VIRT_TYPE" != "none" ] && [ "$PRESET" = "hw" ]; then
    echo -e "${YLW}Detectada VM (${VIRT_TYPE}) con preset hw (picom glx).${RST}"
    if $DRY; then echo "[dry] mantener hw y preguntar en run real"
    elif ask "¿Cambiar a preset vm (xrender, recomendado en VM)?" y; then
        PRESET=vm
    else
        echo -e "${YLW}hw forzado en VM — si todo va lento, ya sabés por qué.${RST}"
    fi
fi

execute "Actualizando sistema (pacman -Syu)"   "Sistema al día"              system_update
execute "AUR helper (yay/paru)"                "Helper AUR listo"            install_aur_helper
execute "Instalando core pacman"               "Core EndeavourOS instalado"  install_core
execute "Paquetes AUR (xautolock, pokemon)"    "AUR instalado"               install_aur_pkgs
execute "VM tools (VirtualBox guest-utils)"    "Guest utils (o skip host)"   install_vm_tools
execute "Energía laptop (tlp/zram-generator)"  "Energía laptop (o skip VM)"  install_power
execute "JetBrainsMono Nerd Font"              "Font Nerd instalada"         download_nerd_font
execute "Pack gh0stzk (icons/gtk/cursor)"      "Themes gh0stzk en /usr/share" install_gh0stzk_pkgs
execute "Copiando configs (+backup)"           "Configs en ~/.config"        install_configs
execute "Update + verify"                      "Verificación completa"       update_and_verify

echo -e "\n${GRN}■ Instalación completa${RST} — preset ${CYN}${PRESET^^}${RST} · helper ${CYN}${AUR_HELPER:-?}${RST}"
echo "  Siguiente: ${CYN}sudo reboot${RST} → LightDM → sesión ${CYN}bspwm${RST}"
echo "  Cheatsheet: ${CYN}alt+F1${RST} · RiceSelector: ${CYN}alt+space${RST} · BarSelector: ${CYN}super+alt+space${RST}"
echo "  Rice default: ${MAG}endeavour${RST} (paleta EndeavourOS) — cambiá con RiceSelector"
if ask "¿Reboot ahora?" n; then
    sudo systemctl reboot
fi
exit 0
