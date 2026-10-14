#!/bin/sh
# =============================================================
# conexion.sh — estado de red para polybar Pacman
# 󰤨 SSID (wifi) · 󰈀 IP (eth) · 󰤭 sin conexión
# deps: nmcli (network-manager), rowspan: interval 5s
# =============================================================

C=$(nmcli -t --fields STATE general 2>/dev/null | head -1)

if [ "$C" != "connected" ]; then
    echo " 󰤭 " ; exit 0
fi

DEV=$(nmcli -t --fields DEVICE,TYPE,STATE device 2>/dev/null | awk -F: '$3=="connected"' | head -1)

case "$DEV" in
    *:802-11-wireless*)
        SSID=$(nmcli -t --fields ACTIVE,SSID device wifi 2>/dev/null | grep '^yes:' | cut -d: -f2 | head -1)
        echo " ${SSID:--} "
        ;;
    *:ethernet*)
        IP=$(ip -4 route show default 2>/dev/null | awk '{print $7; exit}')
        echo " ${IP}%{u-} "
        ;;
esac
