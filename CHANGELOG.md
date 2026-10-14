# CHANGELOG — dotfiles_debian

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
