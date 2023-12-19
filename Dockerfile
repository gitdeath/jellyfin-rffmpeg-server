FROM docker.io/jellyfin/jellyfin:10.8.13

RUN apt-get -y update

RUN apt update && \
    apt install --no-install-recommends --no-install-suggests -y openssh-client cron python3-click python3-yaml wget nfs-common netbase iputils-ping
  
RUN mkdir -p /usr/local/bin && \
    wget https://raw.githubusercontent.com/joshuaboniface/rffmpeg/master/rffmpeg -O /usr/local/bin/rffmpeg && \
    chmod +x /usr/local/bin/rffmpeg && \
    ln -s /usr/local/bin/rffmpeg /usr/local/bin/ffmpeg && \
    ln -s /usr/local/bin/rffmpeg /usr/local/bin/ffprobe

# create transcodessh user
RUN useradd -u 7001 -g users -m transcodessh
RUN mkdir -p /home/transcodessh/.ssh
RUN chown transcodessh /home/transcodessh/.ssh
RUN chmod 700 /home/transcodessh/.ssh

# make rffmpeg config
RUN mkdir -p /rffmpeg && \
    wget https://raw.githubusercontent.com/joshuaboniface/rffmpeg/master/rffmpeg.yml.sample -O /rffmpeg/rffmpeg.yml && \
    sed -i 's;#logfile: "/var/log/jellyfin/rffmpeg.log";logfile: "/config/log/rffmpeg.log";' /rffmpeg/rffmpeg.yml && \
    sed -i 's;#datedlogfiles: false;datedlogfiles: true;' /rffmpeg/rffmpeg.yml && \
    sed -i 's;#datedlogdir: "/var/log/jellyfin";datedlogdir "/config/log";' /rffmpeg/rffmpeg.yml && \
    sed -i 's;#state: "/var/lib/rffmpeg";state: "/rffmpeg";' /rffmpeg/rffmpeg.yml && \
    sed -i 's;#persist: "/run/shm";persist: "/run";' /rffmpeg/rffmpeg.yml && \
    sed -i 's;#owner: jellyfin;owner: root;' /rffmpeg/rffmpeg.yml && \
    sed -i 's;#group: sudo;group: users;' /rffmpeg/rffmpeg.yml && \
    sed -i 's;#user: jellyfin;user: transcodessh;' /rffmpeg/rffmpeg.yml && \
    sed -i 's;#args:;args:;' /rffmpeg/rffmpeg.yml && \
    sed -i 's;#    - "-i";    - "-i";' /rffmpeg/rffmpeg.yml && \
    sed -i 's;#    - "/var/lib/jellyfin/id_rsa";    - "/rffmpeg/.ssh/id_rsa";' /rffmpeg/rffmpeg.yml

RUN mkdir -p /etc/rffmpeg && \
    ln -s /rffmpeg/rffmpeg.yml /etc/rffmpeg/rffmpeg.yml

# Testing 10.8.13 and onward fix for FFmpeg
#RUN sed -i "/.*EncoderApp/d" /config/config/encoding.xml
#RUN sed -i "/.*EncodingOptions>/d" /config/config/encoding.xml
#RUN echo '  <EncoderAppPath>/usr/local\/bin/ffmpeg</EncoderAppPath>' >> /config/config/encoding.xml
#RUN echo '  <EncoderAppPathDisplay>/usr/local/bin/ffmpeg</EncoderAppPathDisplay>' >> /config/config/encoding.xml
#RUN echo '</EncodingOptions>' >> /config/config/encoding.xml

# rffmpeg setup
RUN /usr/local/bin/rffmpeg init -y 
RUN mkdir -p /rffmpeg/.ssh && \
    ssh-keygen -t rsa -f /rffmpeg/.ssh/id_rsa -q -N "" && \
    cp /rffmpeg/.ssh/id_rsa.pub /rffmpeg/.ssh/authorized_keys
    
RUN chown transcodessh /rffmpeg/.ssh && \
    chown transcodessh /rffmpeg/.ssh/authorized_keys && \
    chmod 700 /rffmpeg/.ssh && \
    chmod 600 /rffmpeg/.ssh/authorized_keys

RUN sed -i 's;#   IdentityFile ~/.ssh/id_rsa;   IdentityFile /rffmpeg/.ssh/id_rsa;' /etc/ssh/ssh_config && \
    sed -i 's;#   UserKnownHostsFile ~/.ssh/known_hosts.d/%k;   UserKnownHostsFile /dev/null ;' /etc/ssh/ssh_config &&\
    sed -i 's;#   StrictHostKeyChecking ask;    StrictHostKeyChecking no;' /etc/ssh/ssh_config

# Make and set perms for /transcodes
RUN mkdir -p /transcodes
RUN chgrp users /transcodes

# Make and set perms for /cache
RUN mkdir -p /cache
RUN chgrp users /cache

# Make and set perms for /config
RUN mkdir -p /config
RUN chgrp users /config

# Add root user to the users group
RUN usermod -a -G users root

# Add hostscale script
COPY rffmpeg-hostscale.sh /rffmpeg-hostscale.sh
RUN chmod +x /rffmpeg-hostscale.sh
RUN echo "*/15 * * * * /rffmpeg-hostscale.sh" | crontab - 

RUN apt purge wget -y && \
    rm -rf /var/lib/apt/lists/* && \
    apt autoremove --purge -y && \
    apt clean

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
#ENTRYPOINT ["./jellyfin/jellyfin", "--datadir", "/config", "--cachedir", "/cache"]
