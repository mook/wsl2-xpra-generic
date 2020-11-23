#!/usr/bin/sh

set -o errexit -o nounset

if [ $$ == "1" ]; then
    exec /usr/bin/catatonit -- "$0" "$@"
fi

if test "$(id -u)" = 0 ; then
    printf "%bERROR: Unexpected root privilieges%b\n" "\033[0;1;31m" "\033[0m" >&2
    exit 1
fi

# Sleep a bit to let things settle down; otherwise things seem to break occasionally.
sleep 3

/usr/bin/xpra start \
    --auth=exec:command=/bin/true \
    --exit-with-children \
    --html=off \
    --mdns=no \
    --printing=no \
    --pulseaudio=yes \
    --webcam=no \
    --start-child="$*" \
    >/run/user/1000/xpra-stdout.log \
    2>/run/user/1000/xpra-stderr.log

# Wait for XPRA to be ready; the only signal appears to be a line in the log.
timeout 30 tail --lines=+0 --follow=name --retry \
    /run/user/1000/xpra/:0.log \
    | grep --quiet --line-buffered --max-count=1 'xpra is ready'

exec /usr/bin/xpra _proxy
