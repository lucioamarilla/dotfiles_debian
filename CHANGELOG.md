# CHANGELOG — dotfiles_eos (rama endeavouros) / dotfiles_debian (main)

## v4.0.0-endeavouros (port EndeavourOS — rama `endeavouros`)
- Target: EndeavourOS (pacman + yay preinstalado). La línea Debian queda en main.
- install.sh v4: pacman con esperas de lock de db, `system_update` → `pacman -Syu`
  + autoremove de huérfanos (`pacman -Qtdq`), paquete-por-paquete fallback con
  `pacman -Q` de guard, AUR helper autodetectado (yay primero, paru fallback; si
  no hay, `pacman -S yay` — está en el repo endeavouros), banner púrpura EOS.
- Paquetes mapeados: gvfs-backends → gvfs+gvfs-mtp; x11-* → xorg-xev/xwininfo/
  xrdb/xrandr/xset/xinit/xorg-server; zram-tools → zram-generator
  (/etc/systemd/zram-generator.conf, zstd, ram/2 max 8 GB); + python-gobject
  (NetManagerDM), qalculate (RofiCalc), pacman-contrib (checkupdates),
  network-manager-applet + blueman (trays del autostart).
- pkgs gh0stzk (15) ahora con `pacman -U` (son paquetes Arch nativos; fallback tar).
- Updates reescrito: `checkupdates` + `<helper> -Qua` (yay/paru autodetect),
  secciones Official/AUR coloreadas, sin sudo; bug v3 `--print-updates` fixed
  (Term lo llama y no existía); service ExecStart apuntaba a --sync-polybar
  inexistente → --sync.
- systemd: DebianUpdates.{service,timer} → EndeavourUpdates.{service,timer}.
- .zshrc: glyph prompt Debian U+F306 → Arch U+F303 coloreado magenta EOS; paths
  de plugins con fuente condicional Arch (/usr/share/zsh/plugins/) + fallback
  Debian; alias update condicional yay→paru→sudo pacman.
- Glifos distro: 16 bars/*/modules.ini launcher 󰣽 (U+F08FD Debian) →  (U+F303);
  yazi theme: .SRCINFO glyph 󰣽→  y fg #d70a53 → #7f3fbf
  (PKGBUILD ídem: púrpura EOS en vez de rojo Debian)
- Nueva rice `endeavour` (19ª): bg #161120, EOS purple #7f3fbf, EOS magenta
  #dc35ee, arch_icon=purple EOS, main_bar bar07, GTK LoveLace-zk, iconos
  Zafiro-Purple, cursor Qogirr-Dark, geany z0mbi3-LoveLace, 3 walls purple
  (emilia 04/05/08), preview generado (wall branded). Rice default tras
  instalar (.rice → endeavour).
- Screenshots dir vía `xdg-user-dir PICTURES` (con fallback ~/Pictures) — ya no
  fuerza ~/Imágenes.
- OpenApps: fallback firefox-esr fuera (firefox nativo en EOS).
- sysfetch: conteo de paquetes dpkg → pacman -Qq.
- startup-page: links dotfiles_eos (rama endeavouros) + EndeavourOS.
- Cosméticos: sxhkdrc/picom-vm/ScreenLocker/Term comments → v4 EOS.

## v3.0.0.3 (debianización: arte fuera, iconos Debian, datos personales removidos)
- ASCII art upstream removido (18 scripts: pizza, mario, pacman, burger...): el zshrc ya
  no llama a colorscript (queda instalado para arte propio; guía de activación + reglas de
  tamaño en ~/.zshrc y README)
- Glifos Arch -> Debian: prompt zsh U+F303 -> U+F306; en 16 modules.ini de polybar y theme
  de yazi (.SRCINFO 󰣽 + rojo Debian #d70a53): U+F08C7 -> U+F08FD
- .zshrc: banner propio (lucioamarilla), SUDO_PROMPT en español sobrio, alias update =
  apt (antes paru — roto en Debian desde el port)
- sysfetch: conteo de paquetes pacman -> dpkg (mostraba 0 en Debian)
- systemd: ArchUpdates.{service,timer} -> DebianUpdates.{service,timer} (re-descripciones;
  activación manual documentada en README)
- paru.conf removido (sin paru en Debian)
- runtime fuera del repo: zsh/zhistory (tenía 'echo hello im z0mbi3'), zsh/zcompdump,
  mpd/{mpd.db,mpdstate,log}, ncmpcpp/error.log + .gitignore nuevo
- startup page: name/TZ (Buenos_Aires)/saludos es_ARI, weatherKey vacía + guard en
  weather.js (sin key, widget oculto), coords default limpiadas, botones 'z0mbi3' ->
  nombres de link reales, gh0stzk-dotfiles/ArchLinux list -> repo debian/Debian

## v3.0.0 (rebase base gh0stzk + comandos JaKoolit)
- Vendor: gh0stzk/dotfiles @ 8b3cd66 (18 rices, 18 barras, 23 módulos de theme system, Rofi applets, misc assets)
- Port Debian 13: pactl (Volume), clipmenu (clipboard), i3lock vanilla (ScreenLocker keeps módulo-colores-compatible), Web guard (AnimatedWall), Term autodetect (sin st/ghostty/yazi→ranger)
- sin eww: bspwmrc clipcatd/eww fuera; bar02/bar18 filtradas del BarSelector; Theme.sh/SoftReload/HideBar guards
- 15 paquetes gh0stzk (icons/gtk/cursor) vía raw.githubusercontent/gh0stzk/pkgs + tar --zstd → /usr/share
- JetBrainsMono Nerd Font desde releases nerd-fonts (para rices + lockscreen)
- fzf-tab vendorizado en el repo (config/zsh/fzf-tab)
- .zshrc gh0stzk: paths plugins Debian + reflector alias fuera
- sxhkdrc: 82 binds capa JaKoolit (0 dups auditados) sobre bins gh0stzk
- install.sh v3: spinner + apt_with_retry (anti-lock) + per-package fallback + GF presets + ~/.RiceBackup + post_verify (21 checks)
- RiceInstaller (Arch) removido; LICENSE GPL-3.0 (gh0stzk) retiene, cambios en README

## v2.0.2 (MF-Rayo base — branch archive/v2-mfrayo)
- (ver readers anteriores)

## v0.1 (hand-made — branch archive/v0.1-handmade)
- (ver readers anteriores)
