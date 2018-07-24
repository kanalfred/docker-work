#######################
#
# docker run -ti --rm \
#        -e DISPLAY=$DISPLAY \
#        -v /tmp/.X11-unix:/tmp/.X11-unix \
#        kanalfred/ui
# 
# Give docker user permission for local x11
# xhost +local:docker
# docker run --rm -it kanalfred/work mycli -h192.168.3.103 -uroot
#
# Run:
#   docker run --name work -h work -p 2222:22 -v /data:/data -v /var/run/docker.sock:/var/run/docker.sock -d kanalfred/work
#
# Build:
#     docker build -t local/work .
#
#######################
FROM ubuntu:16.04

ENV TERM=xterm

# Add files
ADD container-files/etc /etc 

# Packages
RUN apt-get update \
    && apt-get install -y sudo \
        # system
        software-properties-common \
        supervisor \
        locales \
        # util
        iputils-ping \
        apt-transport-https \
        ca-certificates \
        rsync \
        wget \
        curl \
        sendmail \
        # service
        openssh-client openssh-server \
        # development
        tmux \
        mycli \
        vim \
        ctags \
        git \
        jq \
        python python-pip \
        mysql-client \
        libxml2-utils

# mycli - mysql command line require lang env
RUN locale-gen en_CA.UTF-8  
ENV LANG en_CA.UTF-8  
ENV LANGUAGE en_CA:en  
ENV LC_ALL en_CA.UTF-8

# Docker
RUN \
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add - && \
    add-apt-repository \
    "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
    $(lsb_release -cs) \
    stable" && \
    apt-get update && apt-get install -y docker-ce

# Setup
RUN \
    # user
    useradd -ms /bin/bash -u 500 alfred \
    # delete password after create new user to unlock the new account accesable from ssh
    # "!" mean the account locked
    # /etc/shadow - alfred:!:12121:0:99999:7:::
    && passwd -d alfred \
    && usermod -a -G root alfred \
    && usermod -aG sudo alfred \
    && echo  "alfred ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers \
    && usermod -aG docker alfred

    # password
    #RUN echo "root:xxxxx" | chpasswd
    #RUN echo "alfred:xxxxx" | chpasswd
    #RUN cat /root/root.txt | chpasswd

ADD container-files/alfred/.ssh /home/alfred/.ssh
ADD container-files/alfred/.ssh /root/.ssh

    # setup ssh
#   add ssh config /etc/ssh/sshd_config

# setup vim, tmux and bachrc

# ssh alice

# install docker
# https://www.digitalocean.com/community/tutorials/how-to-install-and-use-docker-on-ubuntu-16-04
# https://docs.docker.com/install/linux/docker-ce/ubuntu/#install-using-the-repository

# install aws cli
# set up aws profile

# npm node js manager

# radius cli

#ADD run.sh /

RUN \
    # ssh key file permission
    chmod 700 /home/alfred/.ssh && \
    chmod 600 /home/alfred/.ssh/authorized_keys && \
    chown -R alfred:alfred /home/alfred/.ssh &&\

    chmod 700 /root/.ssh && \
    chmod 600 /root/.ssh/authorized_keys && \
    chown -R root:root /root/.ssh &&\

    # sshd
    sed -i "s/UsePrivilegeSeparation.*/UsePrivilegeSeparation no/g" /etc/ssh/sshd_config && \
    sed -i "s/UsePAM.*/UsePAM no/g" /etc/ssh/sshd_config && \
    #sed -i "s/#PasswordAuthentication.*/PasswordAuthentication no/g" /etc/ssh/sshd_config && \
    echo 'PermitEmptyPasswords yes' >> /etc/ssh/sshd_config && \
    # SSH to bind port 8000 on the wildcard address
    echo 'GatewayPorts yes' >> /etc/ssh/sshd_config

USER alfred
RUN \
    # vim
    cd ~/ && \
    git clone https://github.com/kanalfred/vim.git && \
    mv vim .vim && ln -s ~/.vim/vimrc ~/.vimrc && \
    cd ~/.vim && \
    git submodule init && \
    git submodule update && \

    # tmux
    cd ~/ && \
    ln -s ~/.vim/tmux.conf ~/.tmux.conf && \

    # aws cli
    pip install awscli --upgrade --user

USER root

#USER developer
#ENV HOME /home/developer
#ENTRYPOINT ["/bin/bash"]
#ENTRYPOINT ["/run.sh"]
#CMD ["/run.sh"]
#CMD /bin/bash 
EXPOSE 22

CMD ["/usr/bin/supervisord", "-n", "-c", "/etc/supervisor/supervisord.conf"]
