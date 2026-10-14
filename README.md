# Dotfiles Debian — BSPWM (light + estable)

Dotfiles para **Debian 12/13 ((trixie))** sobre **BSPWM (X11)**, pensados para hardware modesto
(ThinkPad i3-10110U, 8 GB RAM) pero estables en cualquier equipo.

Fusiona el **comportamiento de comandos de JaKoolit** (Ubuntu-Hyprland) con la
infraestructura **BSPWM/X11 de gh0stzk**, sustituyendo todos los paquetes que no
existen en Debian (pamixer→pactl, i3lock-color→i3lock, swww→feh, eww→fuera,
clipcat→clipmenu).

## ¿Por qué BSPWM y no Hyprland?

| | BSPWM (este) | Hyprland (JaKoolit) |
|---|---|---|
| RAM boot | ~600-750 MB | ~950-1100 MB |
| Paquetes Debian | 100% oficiales | backports |
| Compatibilidad X11 | máxima | vía XWayland |
| GPU requerida | ninguna | OpenGL 3.3+ |

## Estructura

```
config/
├── bspwm/  → bspwmrc + bin/ (30 scripts) + keybinds.txt (cheat) + themes/
├── sxhkd/  → sxhkdrc (todos los atajos: JaKoolit + gh0stzk + extras)
├── polybar/ → 1 barra inferior sober (vacía de framework: 30 MB RAM)
├── rofi/   → launcher + themes/ (dark/light via symlink theme-active.rasi)
├── picom/  → 2 presets: picom-hw.conf (glx) / picom-vm.conf (xrender)
├── dunst/ alacritty/ gtk-3.0/ fastfetch/ flameshot/ zathura/ nvim/
home/       → .zshrc (sin Oh-My-Zsh: compinit cacheado + plugins from apt)
install.sh  → apt installer completo
```

## Instalar (VM VirtualBox primero)

```bash
# clonar y correr en la VM con Debian 13 netinst (sin DE preinstalada)
git clone <tu-repo> ~/dotfiles_debian
cd ~/dotfiles_debian
./install.sh --preset vm
# cerrar sesión → LightDM → sesión "bspwm"
```

En el ThinkPad real:

```bash
./install.sh --preset hw
```

## Keybinds principales (chuletilla)

> **Alt+F1** abre el cheatsheet completo dentro del sistema.

| Atajo | Acción |
|---|---|
| `super+Return` | terminal |
| `super+shift+Return` | terminal flotante (dropdown) |
| `super+d` | app launcher (rofi) |
| `super+q` | cerrar ventana |
| `super+f` | fullscreen |
| `super+space` | toggle float |
| `super+arrows` | focus |
| `super+alt+arrows` | swap |
| `super+shift+arrows` | resize |
| `super+1-0` | workspaces |
| `super+shift+1-0` | mover ventana |
| `ctrl+alt+l` | lock |
| `ctrl+alt+p` | power menu |
| `super+w` | wallpapers |
| `super+e` | archivos |
| `super+b` | browser |
| `super+s` | búsqueda web |
| `super+alt+c` | calculadora |
| `alt+space` | cambiar tema |

Gracias al port, puedes usarlos con `ctrl+alt+arrows` (alias del move de JaKoolit)
y el resto del mapa de JaKoolit.

## Extras añadidos (no existen en JaKoolit)

- **updates rofi** (apt) — `super+alt+u`
- **grabadora de pantalla** (ffmpeg x11grab) — `super+alt+g`
- **clima** (wttr.in) — `super+alt+y`
- **notas rápidas** (nvim persistente scratchpad) — `super+alt+o`
- **screenshot con anotación** (flameshot) — `super+shift+s`
- **layout clave intercambiable** — `super+alt+k`
- **tramite tupel/setxkbmap** con guardado persistente
- **update checker** polybar-backed (`Updates --notify`)

## Cambiar tema (dark/light)

```
alt+space   → menú rofi dark/light
```

El *ThemeSwitch* regenera polybar colors, bspwm borders, y symlink rofi.
No recompila nada ⇒.empty? no, todo es variable de configuración.

## Cómo agregar un tema nuevo (guía)

1. Copiá `config/bspwm/themes/dark.sh` a `config/bspwp/themes/<nombre>.sh`
2. Editá las variables colores (BG, FG, ACCENT…)
3. Copiá `config/rofi/themes/theme-dark.rasi` a `theme-<nombre>.rasi`
   y cambiá los colores rgba / their.
4. Agregá el nombre en `ThemeSwitch --menu` (line  § es lo único con hardcode).
5. Desde el menú rofi (`alt+space`) ya lo veis y aplica.

Si querés íconos Nerd-font o emoji en polybar, insterala:
```bash
sudo apt install fonts-jetbrains-mono fonts-noto-color-emoji
```

## Cómo agregar módulos a polybar

Add-a [module/X] sección en `config/polybar/modules.ini` y el nombre a
`modules-right` en `config/polybar/config.ini`. Reco: reload con
`super+alt+r` para SoftReload.

## Cómo agregar keybinds

Editá `config/sxhkd/sxhkdrc` y corré `super+Escape` (o `pkill -USR1 sxhkd`).
Recordá regenerar el cheat: `config/bspwm/keybinds.txt`.

## Gestión con git (flujo recomendado)

```bash
# branch de experimentos hasta que está estable en la VM
git checkout -b feat/nuevo-modulo
...editás...
git commit -am "feat: X"
git checkout main && git merge feat/nuevo-modulo
git tag v0.3-tests-vm
git push origin main --tags

# en el ThinkPad real
git clone <tu-repo> ~/dotfiles_debian
./install.sh --preset hw
```

Rollback de un cambio roto: `git checkout v1.0` en `main` + re-correr install.

## Performance (RAM esperada)

| Estado | RAM |
|---|---|
| Boot idle | ~600-750 MB |
| + Firefox 8 tabs | ~2.5 GB |
| + nvim con LSP | ~+150-300 MB |

Ajustes ya hechos para bajarla: sin eww, sin ags, sin pokemon, polybar única,
picom sin blur, zram 40%, tlp tuned, sin OS RAM-buyer (no cheat, no flatpak?).

## Compatibilidad con programas

- Java: `_JAVA_AWT_WM_NONREPARENTING` ya seteado
- GTK/Qt: settings GTK3 via `config/gtk-3.0` + `qt5ct/qt6ct` si lo querés (instala)
- Electron/Chrome/Slack: funcionan nativo (X11)
- Flatpak apps: compatibles sin config extra
- Firefox: usa `firefox-esr` (en repos) con tema Arc/Papirus

## Troubleshooting rápido

```bash
# symlinks rotos?
ls -l ~/.config | grep dotfiles

# polybar no arranca?
~/.config/polybar/launch.sh; sleep 2; polybar --edition -c ~/.config/polybar/config.ini

# reiniciar entorno
super+alt+r    # SoftReload

# picom flicker en VM?
# usar preset vm: ln -sf ~/.config/picom/picom-vm.conf ~/.config/picom/picom.conf

# faltar této? dunstify "not found" — libnotify-bin
sudo apt install libnotify-bin
```
