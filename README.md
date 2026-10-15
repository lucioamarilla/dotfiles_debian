# dotfiles_debian v3 — base gh0stzk + comandos JaKoolit

Dotfiles **BSPWM (X11)** para **Debian 12/13 (trixie)** basados en el entorno de
**gh0stzk** (18 rices / themes con switch al vuelo, 16 barras polybar estilo, Rofi
applets, RiceEditor, scratchpad) — con la **capa de comandos de JaKoolit**
(keybinds de su Ubuntu-Hyprland) portada a X11 y preparada para hardware modesto
(ThinkPad i3-10110U, 8 GB RAM).

```
Base           : gh0stzk/dotfiles (GPL-3.0) —commit 8b3cd66
Keybinds       : JaKoolit (Ubuntu-Hyprland) portados a BSPWM/sxhkd
Port Debian    : lucioamarilla — 2026
```

## Qué cambió respecto a gh0stzk upstream

| Upstream (Arch) | Esta versión (Debian 13) | Motivo |
|---|---|---|
| pacman + chaotic-aur | apt (repos oficiales) | Debian |
| eww (compila Rust) + bar02/bar18 | ✂ fuera — polybar only | 40 MB RAM, 0 builds |
| clipcat | `clipmenu` | no existe en Debian |
| pamixer | `pactl` | ídem |
| i3lock-color (build) | `i3lock` vanilla + port visual | sin builds |
| st-gh0stzk / ghostty | kitty/alacritty (Term con autodetección) | antes de st no compil |
| paru + checkupdates + reflector | `Updates` (apt) | reescrito |
| npm/rustup | ✂ drop | sin usos |
| 15 paquetes gh0stzk (icons/gtk/cursor) | **descarga `tar --zstd` desde github.com/gh0stzk/pkgs** | mismos binarios de datos |
| JetBrainsMono Nerd font | descarga de releases nerd-fonts | las rices la nombran |
| sxhkdrc gh0stzk | **layer JaKoolit** (84 binds) | pedidos: mismos comandos |

## Instalación

```bash
git clone https://github.com/lucioamarilla/dotfiles_debian.git ~/dotfiles_debian
cd ~/dotfiles_debian
./install.sh --preset vm      # VirtualBox (picom xrender)
# ./install.sh --preset hw    # ThinkPad real (glx + tlp/zram)
# ./install.sh --no-icons     # sin descargar los 14 pkgs de temas de gh0stzk
# ./install.sh --dry-run
```

Después: `sudo reboot` → LightDM → sesión **bspwm**.

## Keybinds (JaKoolit layer — cheat completo: `alt+F1`)

| Atajo | Acción |
|---|---|
| `super+Return` / `super+shift+Return` | terminal / dropdown flotante |
| `super+d` / `super+@space` | app launcher |
| `alt+space` | **RiceSelector** (18 temas al vuelo) |
| `super+alt+@space` | BarSelector (16 barras polybar) |
| `super+q` / `super+x` | cerrar (alias ambos) |
| `super+shift+q/x` | matar proceso |
| `super+f` | fullscreen |
| `super+space` | float toggle |
| `super+s` | búsqueda web |
| `super+b` / `super+e` / `super+w` | browser / thunar / whatsapp(gh) |
| `super+v` / `super+y` / `super+m` | nvim / yazi-ranger / music |
| `super+1-0` + `super+shift` + `super+ctrl` | workspaces (focus/mover/mover-silent) |
| `super+arrows` focus · `super+shift+arrows` swap · `super+alt+arrows` resize · `super+ctrl+arrows` move | igual que JaKoolit |
| `alt+Tab` | window switcher rofi (cíclico, gh0stzk) |
| `alt+h` / `ctrl+alt+h` | ventanas ocultas (special ws) |
| `super+alt+o` | scratchpad gh0stzk |
| `ctrl+alt+l` / `ctrl+alt+p` | lock / power menu |
| `super+alt+h/u` + `ctrl+alt+b` | barra hide/unhide/toggle |
| `super+alt+r` | SoftReload |
| `ctrl+alt+Delete` | cerrar sesión |
| `XF86Audio/Brightness/Media` | pactl + brightnessctl + playerctl |
| `super+alt+c/e/v/n/b/u` | calc · emoji · clipboard · net · bt · updates |
| `super+r` | RiceEditor |

## Sistema de temas gh0stzk (sin cambios)

- `alt+space` (RiceSelector): cambio INSTANTANEO de rice — reescribe picom, polybar colors, dunst, rofi shared.rasi, alacritty, kitty? (no: kitty colors.ini via module), GTK (xsettingsd), lockscreen colors, jgmenu, nvim theme…
- BarSelector: 16 barras de polybar con previews por rice
- `super+r` abre **RiceEditor** (GUI gh0stzk para personalizar la rice activa)

## Estructura

```
install.sh     ← installer v3 (spinner + confirmaciones apt + backups ~/.RiceBackup)
config/        ← árbol gh0stzk completo, patched Debian (14 archivos ver CHANGELOG)
home/.zshrc    ← zsh gh0stzk (prompt vcs_info, fzf-tab vendored, plugins apt)
misc/          ← fonts bundle, asciiart (sysfetch), colorscript, firefox theme
RiceInstaller  ← REMOVIDO: era Arch-only (ver install.sh)
LICENSE        ← GPL-3.0 (gh0stzk) — nuestras modificaciones documentadas en CHANGELOG
```

## Qué NO trae esta versión

- eww widgets (welcome/profilecard/player): descartados (ver CHANGELOG)
- ghostty / st: Term autoseleciona lo instalado
- simple-mtpfs: gvfs-backends cubre MTP en thunar
- pentest: nada de herramientas de ciberseguridad (decisión del usuario)

## Troubleshooting

```bash
# rice rota? volvé a la emilia:
echo emilia > ~/.config/bspwm/.rice && SoftReload
# polybar sin tema:
~/.config/bspwm/bin/Theme.sh
# journal de xsion:
journalctl -b --grep="sxhkdrc\|polybar\|bspwm" | tail
# actualizar desde upstream gh0stzk:
# git remote add gh0stzk https://github.com/gh0stzk/dotfiles && git fetch gh0stzk master
# (el repo vendorizado permite diff manual de cambios)
```

## Créditos

- **gh0stzk** (gh0stzk@gmail/dotfiles): estructura completa del entorno — GPL-3.0
- **JaKoolit**: capa de comandos (Ubuntu-Hyprland)
- **lucioamarilla**: port Debian 13, instalar v3, patches (14) y presets
