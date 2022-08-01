#!/usr/bin/sh

set -o errexit -o nounset

case "${2:-}" in
    -start-script|--start-script)
        sed "s@ghcr.io/mook/wsl2-xpra-generic:latest@${3:-ghcr.io/mook/wsl2-xpra-generic:latest}@" </start.ps1
        exit 0
        ;;
esac

if test "$(id -u)" = 0 ; then
    exec /usr/bin/setpriv \
        --init-groups \
        --inh-caps=-all \
        --reuid=docker-user \
        --regid=docker-user \
        /usr/bin/env HOME=/home/docker-user \
        "$0" "$@"
fi

# Sleep a bit to let things settle down; otherwise things seem to break occasionally.
sleep 3

export XDG_RUNTIME_DIR="${XDG_RUNTIME_DIR:-/run/user/1000}"

/usr/bin/xpra start \
    --auth=exec:command=/bin/true \
    --exit-with-children \
    --html=off \
    --mdns=no \
    --printing=no \
    --pulseaudio=yes \
    --webcam=no \
    --start-child="$*" \
    >"${XDG_RUNTIME_DIR}/xpra-stdout.log" \
    2>"${XDG_RUNTIME_DIR}/xpra-stderr.log"

# Wait for XPRA to be ready; the only signal appears to be a line in the log.
timeout 30 tail --lines=+0 --follow=name --retry \
    "${XDG_RUNTIME_DIR}/xpra/:0.log" 2>/dev/null \
    | grep --quiet --line-buffered --max-count=1 'xpra is ready'

# Run `xpra initenv` first to silence some warnings
/usr/bin/xpra initenv
exec /usr/bin/xpra _proxy
