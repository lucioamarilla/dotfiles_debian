#!/bin/sh
# =============================================================
# autostart.sh — daemons de bandeja/sistema (NOT versionado-target)
# copiado a ~/.config/bspwm/autostart.sh por install.sh
# add: start <cmd>
# =============================================================
start() { if ! pgrep -x "$1" >/dev/null; then "$@" & fi; }

start nm-applet
command -v blueman-applet >/dev/null 2>&1 && start blueman-applet
command -v clipmenud     >/dev/null 2>&1 && start clipmenud
command -v xfce4-power-manager >/dev/null 2>&1 || true
