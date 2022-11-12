FROM docker.io/jellyfin/jellyfin:latest

RUN apt update && \
    apt install --no-install-recommends --no-install-suggests -y openssh-client python3-click python3-yaml wget

RUN mkdir -p /usr/local/bin && \
    wget https://raw.githubusercontent.com/aleksasiriski/rffmpeg/main/rffmpeg -O /usr/local/bin/rffmpeg && \
    chmod +x /usr/local/bin/rffmpeg && \
    ln -s /usr/local/bin/rffmpeg /usr/local/bin/ffmpeg && \
    ln -s /usr/local/bin/rffmpeg /usr/local/bin/ffprobe

RUN mkdir -p /etc/rffmpeg && \
    wget https://raw.githubusercontent.com/aleksasiriski/rffmpeg/main/rffmpeg.yml.sample -O /etc/rffmpeg/rffmpeg.yml && \
    /usr/local/bin/rffmpeg init -y && \
    mkdir -p /config/rffmpeg/.ssh && \
    chmod 700 /config/rffmpeg/.ssh && \
    ssh-keygen -t rsa -f /config/rffmpeg/.ssh/id_rsa -q -N ""

RUN apt purge wget -y && \
    rm -rf /var/lib/apt/lists/* && \
    apt autoremove --purge -y && \
    apt clean

ENTRYPOINT ["./jellyfin/jellyfin", \
    "--datadir", "/config", \
    "--cachedir", "/cache", \
    "--ffmpeg", "/usr/local/bin/ffmpeg"]