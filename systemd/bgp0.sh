#!/bin/sh
# Dummy interface that originates / carries 2a0e:aa07:e0e0::/44.
# Idempotent: safe to run repeatedly.
set -eu
IFACE=bgp0
ADDR=2a0e:aa07:e0e0::1/44
if ! ip link show "$IFACE" >/dev/null 2>&1; then
    ip link add "$IFACE" type dummy
fi
ip link set "$IFACE" up
ip addr replace "$ADDR" dev "$IFACE"