#!/bin/sh
# =============================================================
# DropDownTerm.sh — terminal flotante dropdown (JaKoolit style)
# kitty flotante 70%x55% centrado. Un solo drop a la vez.
# =============================================================

# ¿ya hay un dropdown? toggle: maximizarlo/minimizarlo
NODE=$(bspc query -N -n mark.drop 2>/dev/null)
if [ -n "$NODE" ]; then
    if bspc query -N -n ".hidden" | grep -q "$NODE"; then
        bspc node "$NODE" -g hidden=off -f
    else
        bspc node "$NODE" -g hidden=on
    fi
    exit 0
fi

# geometría del monitor bajo el cursor
eval "$(xrandr --query 2>/dev/null | awk '/ primary| connected/ {split($4,xy,"+"); split(xy[1],wh,"x"); print "SW=" wh[1] " SH=" wh[2] " X=" xy[2] " Y=" xy[3]; exit}')"
[ -z "$SW" ] && { SW=1920; SH=1080; X=0; Y=0; }
W=$(( SW * 70 / 100 )); H=$(( SH * 55 / 100 ))
PX=$(( (SW - W) / 2 )); PY=$(( SH * 4 / 100 ))

LIBGL_ALWAYS_SOFTWARE=1 kitty --class=dropdown -T dropdown &

sleep 0.25
NODE=$(bspc query -N -n focused 2>/dev/null)
[ -n "$NODE" ] && {
    bspc node "$NODE" -t floating -g "${W}x${H}+${PX}+${PY}"
    bspc node "$NODE" -n drop
    bspc node "$NODE" -g sticky=on 2>/dev/null
}
