FROM docker.io/jellyfin/jellyfin:latest

RUN apt-get -y update

RUN apt update && \
    apt install --no-install-recommends --no-install-suggests -y openssh-client python3-click python3-yaml wget nfs-common netbase
  
RUN mkdir -p /usr/local/bin && \
    wget https://raw.githubusercontent.com/joshuaboniface/rffmpeg/master/rffmpeg -O /usr/local/bin/rffmpeg && \
    chmod +x /usr/local/bin/rffmpeg && \
    ln -s /usr/local/bin/rffmpeg /usr/local/bin/ffmpeg && \
    ln -s /usr/local/bin/rffmpeg /usr/local/bin/ffprobe
    
RUN mkdir -p /config/rffmpeg && \
    chown transcodessh /config/rffmpeg && \
    chgrp users /config/rffmpeg && \
    wget https://raw.githubusercontent.com/joshuaboniface/rffmpeg/master/rffmpeg.yml.sample -O /config/rffmpeg/rffmpeg.yml && \
    sed -i 's;#logfile: "/var/log/jellyfin/rffmpeg.log";logfile: "/config/log/rffmpeg.log";' /config/rffmpeg/rffmpeg.yml && \
    sed -i 's;#datedlogfiles: false;datedlogfiles: true;' /config/rffmpeg/rffmpeg.yml && \
    sed -i 's;#datedlogdir: "/var/log/jellyfin";datedlogdir "/config/log";' /config/rffmpeg/rffmpeg.yml && \
    sed -i 's;#state: "/var/lib/rffmpeg";state: "/config/rffmpeg";' /config/rffmpeg/rffmpeg.yml && \
    sed -i 's;#persist: "/run/shm";persist: "/run";' /config/rffmpeg/rffmpeg.yml && \
    #sed -i 's;#owner: jellyfin;owner: root;' /config/rffmpeg/rffmpeg.yml && \
    sed -i 's;#owner: jellyfin;owner: transcodessh;' /config/rffmpeg/rffmpeg.yml && \
    sed -i 's;#group: sudo;group: users;' /config/rffmpeg/rffmpeg.yml && \
    #sed -i 's;#user: jellyfin;user: root;' /config/rffmpeg/rffmpeg.yml && \
    sed -i 's;#user: jellyfin;user: transcodessh;' /config/rffmpeg/rffmpeg.yml && \

    sed -i 's;#args:;args:;' /config/rffmpeg/rffmpeg.yml && \
    sed -i 's;#    - "-i";    - "-i";' /config/rffmpeg/rffmpeg.yml && \
    sed -i 's;#    - "/var/lib/jellyfin/id_rsa";    - "/config/rffmpeg/.ssh/id_rsa";' /config/rffmpeg/rffmpeg.yml

RUN mkdir -p /etc/rffmpeg && \
    ln -s /config/rffmpeg/rffmpeg.yml /etc/rffmpeg/rffmpeg.yml


# create transcodessh user
RUN useradd -u 7001 -g users -m transcodessh
RUN mkdir -p /home/transcodessh/.ssh
RUN chown transcodessh /home/transcodessh/.ssh
RUN chmod 700 /home/transcodessh/.ssh

# rffmpeg setup
RUN /usr/local/bin/rffmpeg init -y && \
    mkdir -p /config/rffmpeg/.ssh && \
    ssh-keygen -t rsa -f /config/rffmpeg/.ssh/id_rsa -q -N "" && \
    cp /config/rffmpeg/.ssh/id_rsa /config/rffmpeg/.ssh/authorized_keys && \
    chown transcodessh /config/rffmpeg/.ssh && \
    chown transcodessh /config/rffmpeg/.ssh/authorized_keys && \
    chmod 700 /config/rffmpeg/.ssh && \
    chmod 600 /config/rffmpeg/.ssh/authorized_keys

   
RUN sed -i 's;#   StrictHostKeyChecking ask;    StrictHostKeyChecking no;' /etc/ssh/ssh_config

# Make and set perms for /transcodes
RUN mkdir -p /transcodes
RUN chgrp users /transcodes

#RUN echo 'nfs-server:/transcodes /mnt nfs rw,nolock,actimeo=1 0 0' > /etc/fstab

RUN usermod -a -G users root

RUN sed -i 's;#   IdentityFile ~/.ssh/id_rsa;   IdentityFile /config/rffmpeg/.ssh/id_rsa;' /etc/ssh/ssh_config && \
    sed -i 's;#   UserKnownHostsFile ~/.ssh/known_hosts.d/%k;   UserKnownHostsFile /config/rffmpeg/.ssh/known_hosts;' /etc/ssh/ssh_config 
    
RUN apt purge wget -y && \
    rm -rf /var/lib/apt/lists/* && \
    apt autoremove --purge -y && \
    apt clean
    
ENTRYPOINT ["./jellyfin/jellyfin", \
    "--datadir", "/config", \
    "--cachedir", "/cache", \
    "--ffmpeg", "/usr/local/bin/ffmpeg"]
