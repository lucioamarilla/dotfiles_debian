#!/bin/sh
# =============================================================
# calendar.sh — mini-calendario del mes en rofi (click derecho en date)
# deps: cal (util-linux, core), rofi
# =============================================================

T="$HOME/.config/rofi/themes/config.rasi"
CAL=$(cal | sed 's/\<\($(date +%_d|tr -d " ")\)\>/【&】/')
rofi -e "$(echo "$CAL")" -theme "$T" 2>/dev/null
