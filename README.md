# dotfiles_eos v4 — base gh0stzk + comandos JaKoolit (rama `endeavouros`)

Dotfiles **BSPWM (X11)** para **EndeavourOS** (Arch-based) basados en el entorno de
**gh0stzk** (18 rices / themes con switch al vuelo, 16 barras polybar estilo, Rofi
applets, RiceEditor, scratchpad) — con la **capa de comandos de JaKoolit**
(keybinds de su Ubuntu-Hyprland) portados a X11 y preparados para hardware
modesto (ThinkPad i3-10110U, 8 GB RAM).

```
Base           : gh0stzk/dotfiles (GPL-3.0) — commit 8b3cd66
Keybinds       : JaKoolit (Ubuntu-Hyprland) portados a BSPWM/sxhkd
Port Debian v3 : lucioamarilla — 2026 (branch/rama histórica: main)
Port EOS  v4   : lucioamarilla — 2026 (rama endeavouros)
```

## Qué cambió respecto a la versión Debian (v3)

| Debian v3 (apt) | EndeavourOS v4 (pacman/AUR) | Motivo |
|---|---|---|
| apt (repos oficiales) | `pacman` + AUR helper **autodetectado** (yay primero, paru fallback) | EOS trae yay preinstalado |
| apt list --upgradable | `checkupdates` (pacman-contrib) + `<helper> -Qua` | Updates con repos + AUR |
| `DebianUpdates.{service,timer}` | `EndeavourUpdates.{service,timer}` | mismo timer, base pacman |
| clipmenu | `clipmenu` (repo extra de Arch) | sigue sin AUR extra |
| pactl | `pactl` | PipeWire de EOS lo cubre |
| i3lock vanilla | `i3lock` vanilla (repo extra) | sin builds/AUR |
| zram-tools (`/etc/default/zramswap`) | `zram-generator` (`/etc/systemd/zram-generator.conf`, zstd, ram/2) | equivalente Arch |
| gvfs-backends | `gvfs` + `gvfs-mtp` | nombres pacman |
| x11-* metapackages | `xorg-server` + `xorg-xev/xwininfo/xrdb/xrandr/xset/xinit` | nombres pacman |
| pkgs gh0stzk vía tar | pkgs gh0stzk vía **`pacman -U`** (fallback tar) | son paquetes Arch nativos |
| plugins zsh en `/usr/share/<plugin>/` | `/usr/share/zsh/plugins/` (con fallback Debian) | layout Arch |
| alias update = apt | `yay -Syu` / `paru -Syu` / `sudo pacman -Syu` (condicional) | AUR incluido |
| rice default emilia | **rice `endeavour`** (paleta púrpura/magenta EOS) | personalización EOS |
| glyph Debian U+F306 / 󰣽 | glyph Arch  en **púrpura EOS #7f3fbf** | identidad EOS sobre Arch |

## Instalación

```bash
git clone -b endeavouros https://github.com/lucioamarilla/dotfiles_debian.git ~/dotfiles_eos
cd ~/dotfiles_eos
./install.sh --preset vm      # VirtualBox (picom xrender)
# ./install.sh --preset hw    # ThinkPad real (glx + tlp/zram)
# ./install.sh --no-icons     # sin descargar los 15 pkgs de temas de gh0stzk
# ./install.sh --dry-run
```

> Si ya renombraste el repo en GitHub a `dotfiles_eos`, cambiá la URL del clone
> (GitHub redirige el nombre viejo igualmente).

Después: `sudo reboot` → LightDM → sesión **bspwm**. La rice activa al arrancar
es `endeavour` (paleta púrpura/magenta de EndeavourOS); cambiás con `alt+space`.

## Keybinds (JaKoolit layer — cheat completo: `alt+F1`)

| Atajo | Acción |
|---|---|
| `super+Return` / `super+shift+Return` | terminal / dropdown flotante |
| `super+d` / `super+@space` | app launcher |
| `alt+space` | **RiceSelector** (19 temas al vuelo, incluye `endeavour`) |
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

- `alt+space` (RiceSelector): cambio INSTANTANEO de rice — reescribe picom,
  polybar colors, dunst, rofi shared.rasi, alacritty, kitty colors, GTK
  (xsettingsd), lockscreen colors, jgmenu, nvim theme…
- **Rice `endeavour`**: bg `#161120`, púrpura EOS `#7f3fbf`, magenta EOS
  `#dc35ee`, glyph Arch  tintado púrpura, GTK LoveLace-zk, iconos
  Zafiro-Purple. Walls púrpura en `rices/endeavour/walls/`.
- BarSelector: 16 barras de polybar con previews por rice
- `super+r` abre **RiceEditor** (GUI gh0stzk para personalizar la rice activa)

## Estructura

```
install.sh     ← installer v4 (pacman + yay, spinner, backups ~/.RiceBackup)
config/        ← árbol gh0stzk completo, patched EndeavourOS
home/.zshrc    ← zsh gh0stzk (prompt vcs_info, fzf-tab vendored, plugins Arch)
misc/          ← fonts bundle, colorscript (arte ascii propio), firefox theme,
                 startup-page (links EOS)
RiceInstaller  ← REMOVIDO: era Arch-only upstream (ver install.sh)
LICENSE        ← GPL-3.0 (gh0stzk) — modificaciones documentadas en CHANGELOG
```

## Qué NO trae esta versión

- eww widgets (welcome/profilecard/player): descartados desde v3 (16/18 barras polybar)
- ghostty / st: Term autoselecciona lo instalado
- pentest: nada de herramientas de ciberseguridad (decisión del usuario)
- paru forzado: yay es el default de EOS; paru solo entra si yay no existe

## ASCII art en la terminal (opcional, arte propio)

El arte random upstream (pizza/mario/pacman...) se removió v3.0.0.3. Para
colocar el tuyo —valen los mismos tamaños que da `colorscript -l`:

1. `~/.local/share/asciiart/<nombre>` (sin extensión), formato mínimo:
   ```sh
   #!/bin/sh
   cat <<EOF
   ...tu arte...
   EOF
   ```
   más `chmod +x`.
2. Probar: `~/.local/bin/colorscript -e <nombre>` · listar: `colorscript -l`
3. Activar al abrir terminal: descomentar en `~/.zshrc`
   `~/.local/bin/colorscript -r` (random) o `-e <nombre>` (fijo).

Restricciones de tamaño: **≤ 80 columnas** (ideal 60–70, 1 carácter = 1 celda)
y **≤ 18–20 líneas** (ventana default ~24 filas). Solo caracteres de ancho
simple — nada de emoji/CJK. Truco: duplica tus artes en `misc/asciiart/` del
repo para que sobrevivan a reinstalaciones (install.sh los re-copia).

## Timer de updates

`systemd/user/EndeavourUpdates.{service,timer}` chequea pacman + AUR cada
15 min y pinta el contador en el módulo `updates` de polybar. Activación
manual (una vez):

```bash
systemctl --user enable --now EndeavourUpdates.timer
```

## Troubleshooting

```bash
# rice rota? volvé a la endeavour:
echo endeavour > ~/.config/bspwm/.rice && SoftReload
# polybar sin tema:
~/.config/bspwm/config/bspwmrc/bin/Theme.sh 2>/dev/null || ~/.config/bspwm/bin/Theme.sh
# ver updates a mano (repos + AUR):
~/.config/bspwm/bin/Updates --list
# journal de xsion:
journalctl -b --grep="sxhkdrc\|polybar\|bspwm" | tail
# actualizar desde upstream gh0stzk:
# git remote add gh0stzk https://github.com/gh0stzk/dotfiles && git fetch gh0stzk master
# (el repo vendorizado permite diff manual de cambios)
```

## Créditos

- **gh0stzk** (gh0stzk/dotfiles): estructura completa del entorno — GPL-3.0
- **JaKoolit**: capa de comandos (Ubuntu-Hyprland)
- **lucioamarilla**: port Debian v3, port EndeavourOS v4, patches y presets
