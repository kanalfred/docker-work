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
# Docker:
#     Default coreos docker group id : 233
#     get host docker group id :
#       stat -c '%g' /var/run/docker.sock
#     Update docker group Id to host docker group id for :
#        groupmod -g 3000 {host docker group id}
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
        bash-completion \
        # service
        openssh-client openssh-server \
        # development
        tmux \
        mycli \
        vim \
        ctags \
        git \
        subversion \
        jq \
        python python-pip \
        mysql-client \
        libxml2-utils

# mycli - mysql command line require lang env
RUN locale-gen en_CA.UTF-8  
ENV LANG en_CA.UTF-8  
ENV LANGUAGE en_CA:en  
ENV LC_ALL en_CA.UTF-8

# Setup & install repo packages
RUN echo "Setup & install repo packages" && \
    # docker
    groupadd -g 233 docker && \
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add - && \
    add-apt-repository \
    "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
    $(lsb_release -cs) \
    stable" && \
    # kubectl
    curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add - && \
    echo "deb https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee -a /etc/apt/sources.list.d/kubernetes.list && \
    apt-get update && apt-get install -y docker-ce kubectl

# User Setup
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
    # test if file exist /user_config/user_p.txt
    # RUN cat /user_config/user_p.txt | chpasswd
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

# ssh 
RUN \
    # ssh key file permission
    # alfred
    chmod 700 /home/alfred/.ssh && \
    chmod 600 /home/alfred/.ssh/authorized_keys && \
    chown -R alfred:alfred /home/alfred/.ssh &&\
    # root
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

# workspace
USER alfred
RUN \
    # vim
    cd ~/ && \
    git clone https://github.com/kanalfred/vim.git && \
    mv vim .vim && ln -s ~/.vim/vimrc ~/.vimrc && \
    cd ~/.vim && \
    git submodule init && \
    git submodule update && \

    # symbolic links
    ln -s /data/work/workspace ~/workspace && \

    # git config
    git config --global user.email "kanalfred@gmail.com" && \
    git config --global user.name "Alfred Kan" && \

    # tmux
    cd ~/ && \
    ln -s ~/.vim/tmux.conf ~/.tmux.conf && \
    # tmux plugins
    git clone https://github.com/tmux-plugins/tmux-resurrect ~/tmux-resurrect && \
    echo 'run-shell ~/tmux-resurrect/resurrect.tmux' >> ~/.tmux.conf && \

    # bashrc
    # stop ctrl s abnormal action
    echo 'stty -ixon' >> ~/.bashrc && \

    # aws cli
    pip install awscli --upgrade --user && \

    # digitalocean cli
    cd ~/ && \
    curl -sL https://github.com/digitalocean/doctl/releases/download/v1.31.2/doctl-1.31.2-linux-amd64.tar.gz | tar -xzv && \
    sudo mv ~/doctl /usr/local/bin


USER root

#USER developer
#ENV HOME /home/developer
#ENTRYPOINT ["/bin/bash"]
#ENTRYPOINT ["/run.sh"]
#CMD ["/run.sh"]
#CMD /bin/bash 
EXPOSE 22

CMD ["/usr/bin/supervisord", "-n", "-c", "/etc/supervisor/supervisord.conf"]
