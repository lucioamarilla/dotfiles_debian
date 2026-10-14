# CHANGELOG — dotfiles_debian

## v2.0.2 (fixes reportados en VM limpia)
- FIX clone_repositories idempotente: re-clona/actualiza si el destino ya existe (el `[ERROR] Clonando Qogir + p10k` en re-runs)
- FIX install_packages: propaga el exit code real de apt (fin del case-masking que pintaba de verde installs fallidos)
- FIX apt list: `python3-bs4` re-unido a la lista (estaba suelto sin `\` → jamás se instalaba)
- NEW apt_with_retry: si el lock de apt está ocupado (unattended-upgrades post-boot), reintenta 3×/30s; otros errores pasan visibles
- FIX post_verify dedupe: checklist único (16 checks, sin repetidos)

## v2.0.1 (auditoría + fixes VM reportados)
- FIX perms: `chmod -R` para todo `~/.config/bin/scripts` (music/net_config/color_picker ahora ejecutables — "Permission denied" del boot resuelto)
- FIX `ifconfig` → `ip` nativo en my_ip.sh, get_interface.sh, copy_ip.sh (sin net-tools)
- OUT final pentest: `target.sh`, `net_config/vpn.sh`, módulos `[module/vpn]`+`[module/target]` de los 5 temas (incl. barras Round), `HTB_active`/`tun0` de colores, funciones `mkt()/extractPorts()/rmk()` del zsh, `scrub` de la lista apt
- FIX backup_repo: ya no silencia errores, fallback `cp -a` sin rsync, excluye `.git` (el `[ERROR] Respaldo repo` ya muestra causa si ocurre)
- NUEVOS scripts que polybar llamaba y no existían: `calendar.sh`, `playerctl-{play,next,prev}.sh`, `conexion.sh`
- apt core: +`cava` `xdo` `xdg-user-dirs` `python3-bs4` (−`net-tools` `scrub`); pip: beautifulsoup4 vía apt; moewall.py shebang `#!/usr/bin/env python3`
- FIX ScratchPad: re-usa un único suscriptor `bspc subscribe` vía PID-file (leak de suscriptores en cada alt+s)
- FIX bspwm_settings movido a `~/.config/bin/scripts/` (sxhkdrc + rofi referencias single-source, sin `/usr/local`)
- I6: Qogir `-d` con `mkdir -p` previo; post_verify +3 checks (cava, xdo, music/network scripts ejecutables)

## v2.0.0-base (redo con base MF-Rayo)
- Base completa MF-Rayo/bspwm-dotfiles-debian (temas, polybar 5 estilos, rofi applets, fonts, scripts)
- Out: eww (Rust), picom/cava/i3lock-color/xwinwrap builds, NvChad+Mason, buffs pentest
- In: picom/cava/neovim/i3lock apt; ScreenLocker vanilla i3lock; PipeWire nativo
- Port JaKoolit completo a sxhkdrc (launcher, lock, power, workspaces silent, dropdown term, calc/emoji/search/clip, panel notifs, media keys, todas arrows/workspaces)
- Extras: DunstPanel, RofiCalc, Rofimoji, RofiSearch, ClipMenu, Updates (apt), HideNode, WinFloat, DropDownTerm, HideBar, TermSelector, IdleSetup, NetMenu, BlueMenu
- Installer v2: spinner heredado, flags --preset vm|hw / --no-power / --dry-run, zram/tlp laptop, backups ~/.config, post_verify, sin compilaciones
- Nuevos configs incluidos: thunar (super+E), flameshot, gtk-3.0 settings
- Perf target: idle < 800MB (polybar + p10k + kitty)

## v0.1 (archivado en branch archive/v0.1-handmade)
- Primeros dotfiles 100% handmade con port JaKoolit (base gh0stzk-like)
 — todo hecho a mano; queda como referencia si algún día querés scripts base propios.
