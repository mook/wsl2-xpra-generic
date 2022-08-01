# https://build.opensuse.org metadata
#!BuildTag: wsl2-xpra-generic
#!UseOBSRepositories

FROM opensuse/leap:15.4 AS user-base

RUN useradd --uid 1000 --create-home --user-group docker-user

FROM user-base AS fs-layout
RUN mkdir --parents /run/user/1000
RUN chown docker-user:docker-user /run/user/1000
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod ugo=rx /usr/local/bin/entrypoint.sh
USER docker-user
RUN mkdir --parents /home/docker-user/.config/pulse/
RUN chmod u=rwx,og=rx /home/docker-user/.config /home/docker-user/.config/pulse

FROM user-base
RUN true \
    && zypper --non-interactive install \
        adobe-sourcecodepro-fonts \
        adobe-sourcesanspro-fonts \
        adobe-sourceserifpro-fonts \
        dejavu-fonts \
        file \
        google-caladea-fonts \
        google-carlito-fonts \
        google-droid-fonts \
        google-roboto-fonts \
        google-opensans-fonts \
        iproute2 \
        khmeros-fonts \
        libXt6 \
        noto-sans-fonts \
        patterns-fonts-fonts \
        pulseaudio \
        pulseaudio-module-x11 \
        python3-netifaces \
        python3-pyinotify \
        python3-pyaml \
        python3-pyxdg \
        which \
        xdg-user-dirs \
        xorg-x11-server \
    && zypper --non-interactive install --recommends xpra \
    && tr --delete --complement 0-9a-f < /dev/urandom | head --bytes=32 \
        | tee /var/lib/dbus/machine-id \
        | tee /etc/machine-id \
    && zypper --non-interactive clean --all \
    && true
COPY --from=fs-layout /usr/local/bin/entrypoint.sh /usr/local/bin/
COPY --from=fs-layout /run/user/ /run/user/
COPY --from=fs-layout /home/docker-user/ /home/docker-user/
ADD  start.ps1 /

ENTRYPOINT [ "/usr/local/bin/entrypoint.sh", "/bin/false" ]
