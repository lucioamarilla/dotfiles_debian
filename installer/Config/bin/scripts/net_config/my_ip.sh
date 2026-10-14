#!/bin/bash
# my_ip.sh — módulo polybar: IP + SSID de la interfaz activa (iproute2 nativo)

source ~/.config/theme/colors/bin.sh
source ~/.config/bin/scripts/net_config/get_interface.sh

if [ -n "$ACTIVE_INTERFACE" ]; then
    IP=$(ip -4 addr show dev "$ACTIVE_INTERFACE" 2>/dev/null | awk '/inet /{print $2}' | cut -d/ -f1)

    if [ "$IS_WIRELESS" = "true" ]; then
        SSID=$(iwgetid -r 2>/dev/null)
        echo "%{F$icon}󰤨 %{F$fg_icon}${SSID:--} · %{F$fg_icon}${IP:--}%{u-}"
    else
        echo "%{F$icon}󰈀 %{F$fg_icon}${IP:--}%{u-}"
    fi
else
    echo "%{F$icon}󰈀 No IP%{u-}"
fi
