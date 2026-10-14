# Dotfiles Debian BSPWM (v2) — base MF-Rayo, port JaKoolit

Dotfiles **BSPWM (X11)** para **Debian 13 (trixie)**, pensados para hardware
modesto (ThinkPad i3-10110U, 8 GB RAM) donde lo primero es **estabilidad,
compatibilidad y bajo consumo de RAM**.

```
Base original : MF-Rayo/bspwm-dotfiles-debian (MIT) — git@github.com:MF-Rayo/bspwm-dotfiles-debian.git
Comportamiento: comandos/keybinds de JaKoolit (Ubuntu-Hyprland), portados a X11
Adaptaciones  : lucioamarilla — 2026
```

## Qué cambió respecto a la base MF-Rayo (y por qué)

| Decisión | Original MF-Rayo | Esta versión | Por qué |
|---|---|---|---|
| Eww (widgets Rust) | compila con cargo | ✂ eliminado | −40 MB RAM, 0 compilación |
| picom | build git | paquete apt | repos Debian, estable |
| cava | build git | paquete apt | repos Debian |
| i3lock-color | build git | `i3lock` apt | mismo look (ScreenLocker) |
| xwinwrap | build git | ❌ | wallpaper animado innecesario |
| Neovim | GitHub + NvChad + 7 LSP | `neovim` apt + config aprox precisa | 8 GB RAM disciplinado |
| Audio | enmascara PipeWire → PulseAudio | PipeWire nativo | Debian 13 default, pactl ok |
| Pentest | penelope/seclists/scrub/target: SÍ | ✂ eliminado | daily-driver, sin herramientas ofensivas |
| Zsh | p10k + plugins | igual (p10k instant, plugins apt) | — |
| Energía | nada | tlp + thermald + zram 40% | laptop optimization |
| Backups | `rsync` repo a `~/.BSPWM` | + backup `~/.config` previo | no destruye configs |
| VM vs HW | solo una config | `--preset vm` / `--preset hw` | flake-proof en VirtualBox |

## Instalar

```bash
git clone git@github.com:lucioamarilla/dotfiles_debian.git   # o HTTPS
cd dotfiles_debian
./install.sh --preset vm       # VirtualBox (auto-detecta igual: systemd-detect-virt)
# ./install.sh --preset hw     # ThinkPad real
# ./install.sh --no-power      # skip tlp/zram (VM no laptop)
# ./install.sh --dry-run       # ver plan sin ejecutar
```

Después del installer:
1. **Reboot** → LightDM → en el greeter elegí sesión **bspwm**
2. La barra (polybar Cuts estilo) aparece abajo+arriba
3. `super+ctrl+t` cambia tema (9 previews rofi), `super+ctrl+p` cambia barra
   (Cuts/Lofi/Pacman/Round/Shapes), `super+ctrl+w` wallpaper

## Keybinds principales (cheat completo: `alt+F1`)

| Atajo | Acción | Origen |
|---|---|---|
| `super+Return` | kitty (^LIBGL_SOFT en VM) | ambos |
| `super+shift+Return` | kitty dropdown flotante | JaKoolit |
| `super+d` | app launcher (rofi) | ambos |
| `super+p` / `ctrl+alt+p` | power menu | base / JaKoolit |
| `Print` | menú screenshot | base |
| `super+shift+f` | firefox | base |
| `super+e` | thunar | JaKoolit |
| `super+shift+e` | ranger en kitty | específico |
| `super+v` | nvim | base |
| `super+q` / `super+shift+q` | cerrar / matar | ambos |
| `super+f` | fullscreen | ambos |
| `super+space` | float toggle | JaKoolit |
| `super+m` | tiled↔monocle | base |
| `super+g` | swap con la más grande | base |
| `super+1..0` / `super+shift+1..0` | workspace / mover ws | ambos |
| `super+ctrl+1..0` | mover sin seguir | JaKoolit |
| `super+Tab` | último desktop | base |
| `alt+Tab` | window switcher rofi | JaKoolit |
| `alt+h` / `ctrl+alt+h` | ocultar / restaurar ventanas | ≈ JaKoolit special ws |
| `super+alt+space` | todo flotante en desktop | JaKoolit |
| `super+ctrl+t` | **ThemeSelect** (9 temas) | base |
| `super+w` / `super+ctrl+w` | wallpaper selector | JaKoolit/base |
| `shift+l` / `ctrl+alt+l` | lock screen | base/JaKoolit |
| `super+alt+r` | restart bspwm (reload) | base |
| `super+alt+q` | cerrar sesión | base |
| `ctrl+alt+b` | toggle barra | JaKoolit |
| `XF86` vol/brillo/mic/media | pactl + brightnessctl + playerctl | idle-keys |
| `super+alt+c/e/v/n/b/u/y` | calc · emoji · clipboard · net · bt · updates · clima | extras |
| `F1` | copiar IP pública | base |
| `alt+F1` / `alt+F2` | cheat sxhkd · settings rápidos | base |

**JaKoolit equivalencias donde el bspwm clásico gana:**
| JaKoolit | aquí en su lugar |
|---|---|
| `super+Shift+arrows` resize | `super+alt+arrows` |
| `super+Alt+arrows` swap | `super+shift+arrows` |
| `super+M`(split ratio toggler) | `super+ctrl+arrows` (mover) |
| `super+B`(browser) | `super+shift+f` (base) |

**Pentest**: removido. Los scripts del repo (`wifi` para conectar en ncurses, `xwall` downloader) quedan como utilidades genéricas.

## Estructura del repo

```
install.sh          ← installer automático (spinner, verificación, --preset, backups)
installer/Config/*  →  ~/.config/*   (bspwm sxhkd polybar picom rofi dunst kitty
                                       nvim ranger theme gtk-3.0 flameshot fastfetch bin)
installer/fonts/*   →  /usr/local/share/fonts (HF/ + polybar)
installer/scripts/* →  /usr/local/bin   (wifi shortcuts xwall bspwm_settings)
Themes/*/colors/*   →  los 9 temas (bin.sh, kitty.ini, polybar.ini, rofi.rasi, p10k…)
Themes/*/Wallpaper  →  copiada a ~/.Wallpaper
README.md, CHANGELOG.md, LICENSE (MIT, créditos MF-Rayo)
```

## Flujo del theme system

```
~/.BSPWM = copia espejo del repo (backup_repo del installer)
~/.config/theme/config.json = estado (theme activa, polybar style, paddings, api keys)
~/.config/theme/colors/* = colores del tema activo
super+ctrl+t (ThemeSelect) → copia Wallpaper + colors + prosigue en kitty/cava/dunst
ZeroColor = modo especial → usa pywal16 sobre el wallpaper elegido (colores dinámicos)
```

Para agregar un tema: copiá cualquiera de `Themes/*` con otro nombre y agregale
`colors/{bin.sh, kitty.ini, polybar.ini, rofi.rasi}` + preview png en
`~/.config/rofi/themes/preview/Themes/`.

## Troubleshooting rápido

```bash
# dwm no arranca a boot? → ver vos mismo
sudo journalctl -b -u lightdm --no-pager | tail -40
# sin polybar?
~/.config/polybar/launch.sh
# picom artifacts en VM?
cp ~/.BSPWM/installer/Config/picom/no_blur_picom.conf ~/.config/picom/picom.conf && bspc wm -r
# themes no aplican? (requerido ~/.BSPWM existe)
rsync -a --delete $(pwd)/ ~/.BSPWM/
```

## Contratos con git (gestión de dotfiles)

```bash
# rama estable en VM: hacé branch para cambios
git checkout -b feat/modulo && git commit -am "..." && git merge feat/modulo
git tag v2.1-nombre && git push --tags
# ThinkPad real: clone + ./install.sh --preset hw
```

Archivado del trabajo manual v0.1 (sin base MF-Rayo): branch `archive/v0.1-handmade`
en este repo — útil si algún día querrés un un dotfile 100% propio.

## Créditos

- **MF-Rayo** (`git@github.com:MF-Rayo/bspwm-dotfiles-debian.git`): estructura, temas, rofi applets, fonts, y el installer básico — MIT LICENSE
- **JaKoolit**: mappings de comandos/keybinds (producidos en su repo Ubuntu-Hyprland)
- **gh0stzk**: referencias de scripts X11 de BSPWM
- **lucioamarilla**: adaptaciones Debian 13, port X11 de JAK, installer v2, nvim minimal, presets vm/hw
