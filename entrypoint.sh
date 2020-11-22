#!/usr/bin/sh

if test "$(id -u)" = 0 ; then
    printf "%bERROR: Unexpected root privilieges%b\n" "\033[0;1;31m" "\033[0m" >&2
    exit 1
fi

exec \
    /usr/bin/catatonit -- /usr/bin/xpra start \
    --auth=exec:command=/bin/true \
    --daemon=no \
    --exit-with-children \
    --html=off \
    --mdns=no \
    --printing=no \
    --pulseaudio=yes \
    --webcam=no \
    --start-child="$*"
