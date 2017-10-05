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
#######################
FROM ubuntu:16.04

#ADD run.sh /
# mycli - mysql command line
# http://mycli.net/
RUN apt-get update && apt-get install -y mycli sudo vim
ENV LC_ALL C.UTF-8
ENV LANG C.UTF-8
#RUN set -xe \
#&& export LC_ALL="C.UTF-8" \
#&& export LANG="C.UTF-8"

RUN groupadd -g 1000 -r alfred \
    && useradd -u 1000 -r -g alfred alfred \
    && usermod -a -G root alfred \
    && usermod -aG sudo alfred && \
    echo  "alfred ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers 
#RUN /run.sh
#RUN echo 'export LC_ALL=C.UTF-8\r\n' >> /etc/profile.d/docker.sh
#RUN echo 'export LANG=C.UTF-8\r\n' >> /etc/profile.d/docker.sh
#RUN export LC_ALL=C.UTF-8 
#RUN export LANG=C.UTF-8

#USER developer
#ENV HOME /home/developer
#ENTRYPOINT ["/bin/bash"]
#ENTRYPOINT ["/run.sh"]
#CMD ["/run.sh"]
#CMD /bin/bash 
