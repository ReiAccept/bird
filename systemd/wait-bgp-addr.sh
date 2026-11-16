#!/bin/sh
# BIRD binds its BGP source address to the box's SLAAC IPv6 address. SLAAC can
# arrive late on boot, so wait briefly and add the (MAC-derived, deterministic)
# address ourselves if it is still missing.
set -u

IFACE=enp1s0
ADDR=2401:c080:1c00:28f3:5400:5ff:fe19:b5d4

ready() {
    ip -6 addr show dev "$IFACE" 2>/dev/null \
        | grep -F "inet6 $ADDR/64" | grep -qv tentative
}

# Give SLAAC a moment first.
i=0
while [ "$i" -lt 10 ]; do
    ready && exit 0
    i=$((i + 1))
    sleep 0.5
done

# Not there yet: add it explicitly (idempotent).
ip -6 addr add "$ADDR/64" dev "$IFACE" noprefixroute 2>/dev/null || true

# Wait for DAD to finish so BIRD does not bind a tentative address.
i=0
while [ "$i" -lt 10 ]; do
    ready && exit 0
    i=$((i + 1))
    sleep 0.5
done
exit 0
