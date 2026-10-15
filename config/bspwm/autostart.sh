#!/bin/sh
# autostart del usuario (no versionado al instalar; installer lo copia si no existe)
start() { if ! pgrep -x "$1" >/dev/null; then "$@" & fi }

start nm-applet
command -v blueman-applet >/dev/null 2>&1 && start blueman-applet
command -v clipmenud     >/dev/null 2>&1 && start clipmenud
