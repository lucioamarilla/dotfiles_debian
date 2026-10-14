#!/usr/bin/env bash
# get_interface.sh — detecta interfaz activa (wired y wireless, iproute2 nativo)

ACTIVE_INTERFACE=""
IS_WIRELESS=false

# ethernet conectada
for iface in $(ip -o link show 2>/dev/null | awk -F': ' '{print $2}' | grep -E '^e'); do
    if ip addr show "$iface" 2>/dev/null | grep -q "inet "; then
        ACTIVE_INTERFACE="$iface"
        break
    fi
done

# wireless conectada
if [ -z "$ACTIVE_INTERFACE" ]; then
    for iface in $(ip -o link show 2>/dev/null | awk -F': ' '{print $2}' | grep -E '^wl'); do
        if ip addr show "$iface" 2>/dev/null | grep -q "inet "; then
            ACTIVE_INTERFACE="$iface"
            IS_WIRELESS=true
            break
        fi
    done
fi
