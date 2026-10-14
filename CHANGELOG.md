# CHANGELOG — Dotfiles Debian BSPWM

## v0.1.1 — Fixes Debian 13 (trixie)
- install.sh: paquetes renombrados a los de trixie — nvim→neovim, qalculate→qalc
- install.sh: agregados faltantes — i3lock, ffmpeg, psmisc(killall), xss-lock, pipx
- xautolock (eliminado de trixie) → xss-lock; IdleSetup reescrito para xss-lock
- clipmenu (removido de Debian) → vendorizado en bspwm/bin (clipmenu/clipmenud/clipctl)
- rofimoji (sin paquete) → pipx; wrapper bin/Rofimoji con fallback a ~/.local/bin
- picom: override ~/.config/autostart/picom.desktop Hidden=true (fix XFCE
  "Another composite manager is already running")
- gtk-3.0/settings.ini: quitada key inválida gtk-menu-icons (warning en app GTK)
- sxhkdrc: dedupe super+alt+u (Updates) → HideBar --unhide ahora en super+alt+shift+u
- fonts: Symbols Nerd Font Mono vendorizada en config/fonts + ~/.local/share/fonts
  (polybar font-2 ya tiene glifos)
- ScreenLocker: guard grácil si i3lock no está

## v0.1 — Inicial (VM tests)
- Estructura base: bspwm + sxhkd + polybar + rofi + picom + dunst
- Port completo de keybinds JaKoolit → sxhkd (mis combos y semántica)
- Scripts bin portados a Debian (pactl, maim, i3lock, feh, clipmenu)
- Temas: dark (Tokyo Night) + light (papel claro) con ThemeSwitch
- install.sh apt con presets vm/hw, backups, symlinks y zram/tlp
- Extras: updates, recorder, clima, notas, pass, keyboard layout
- Cheatsheet Alt+F1 vía keybinds.txt
