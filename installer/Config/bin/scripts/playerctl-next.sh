#!/bin/sh
# playerctl-next.sh / prev — labels para polybar Lofi (iconos)
echo "󰒭"
if [ "$1" = "--click" ]; then
    playerctl next 2>/dev/null
fi
