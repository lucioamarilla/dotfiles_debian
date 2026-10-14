#!/bin/bash
# copy_ip.sh — copia la IP pública al portapapeles (utilidad general)
# Uso: copy_ip.sh --myip   (bind F1)

case "$1" in
    --myip)
        pub=$(curl -4 -s --max-time 3 ipinfo.io/ip 2>/dev/null \
              || curl -s --max-time 3 ifconfig.me 2>/dev/null)
        [ -z "$pub" ] && { dunstify -t 2000 -u critical "IP" "Sin internet / no se pudo consultar"; exit 1; }
        printf '%s' "$pub" | xclip -selection clipboard
        dunstify -t 1800 "IP copiada" "$pub"
        exit 0
        ;;
    --local)
        ip4=$(ip -4 route show default 2>/dev/null | awk '{print $7; exit}')
        [ -n "$ip4" ] && printf '%s' "$ip4" | xclip -selection clipboard
        dunstify -t 1800 "IP local copiada" "$ip4"
        exit 0
        ;;
esac
echo "uso: copy_ip.sh --myip | --local"
exit 1
