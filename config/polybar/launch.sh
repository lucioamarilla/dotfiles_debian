#!/bin/sh
# =============================================================
# launch.sh — levanta polybar en el monitor primario
# Exporta BAT/AC/NETIF desde system.ini (producido por SetSysVars)
# =============================================================

CONF="$HOME/.config/polybar"

# Monitor primario (fallback: primera pantalla conectada)
MON=$(xrandr --query 2>/dev/null | awk '/primary/ {print $1; exit}')
[ -z "$MON" ] && MON=$(xrandr --query 2>/dev/null | awk '/ connected/ {print $1; exit}')
export MONITOR="$MON"

# Variables de sistema desde SetSysVars
SYSC="$HOME/.config/bspwm/config/system.ini"
if [ -f "$SYSC" ]; then
    BAT=$(awk -F' = ' '/sys_battery/ {print $2}' "$SYSC" | tr -d ' ')
    AC=$(awk -F' = ' '/sys_adapter/ {print $2}' "$SYSC" | tr -d ' ')
    NETIF=$(awk -F' = ' '/sys_network_interface/ {print $2}' "$SYSC" | tr -d ' ')
else
    BAT=$(ls /sys/class/power_supply 2>/dev/null | grep -m1 '^BAT' )
    AC=$(ls /sys/class/power_supply 2>/dev/null | grep -m1 -E '^(AC|ADP)')
    NETIF=$(ip route show default 2>/dev/null | awk '{print $5; exit}')
fi
export BAT AC NETIF

# Kill silencioso
killall -q polybar 2>/dev/null
while pgrep -x polybar >/dev/null 2>&1; do sleep 0.2; done

# Lanzar
polybar --reload -q main -c "$CONF/config.ini" 2>/dev/null &
echo "polybar lanzado en ${MON:-default}"
