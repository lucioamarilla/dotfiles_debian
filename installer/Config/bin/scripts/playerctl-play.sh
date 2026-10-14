#!/bin/sh
# playerctl-play.sh — label para polybar (estado de reproducción)
# Sin reproductor MPRIS activo: icono apagado. Con tail=true, espera eventos.
S=$(playerctl status 2>/dev/null)

if [ -z "$S" ] || [ "$S" = "Stopped" ]; then
    echo "󰎇"
    playerctl metadata -F --format '{{status()}}' >/dev/null 2>&1 &
    exit 0
fi

case "$S" in
    Paused*) SICON="󰐊 ";;
    play*)   SICON="󰏤 ";;
    *)       SICON="󰎇 " ;;
esac

TITLE=$(playerctl metadata --format "{{artist}} — {{title}}" 2>/dev/null | cut -c1-42)
echo "${SICON}${TITLE:--}"

# stream de eventos para tail=true (polybar tail)
playerctl metadata -F --format '{{ status }} {{ artist }} — {{ title }}' 2>/dev/null | while read -r _; do
    S=$(playerctl status 2>/dev/null)
    case "$S" in Paused*) SICON="󰐊 " ;; play*) SICON="󰏤 " ;; *) SICON="󰎇 " ;; esac
    TITLE=$(playerctl metadata --format "{{artist}} — {{title}}" 2>/dev/null | cut -c1-42)
    echo "${SICON}${TITLE:--}"
done
