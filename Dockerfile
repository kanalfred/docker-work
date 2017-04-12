#######################
#
# docker run -ti --rm \
#        -e DISPLAY=$DISPLAY \
#        -v /tmp/.X11-unix:/tmp/.X11-unix \
#        kanalfred/ui
# 
# Give docker user permission for local x11
# xhost +local:docker
#
#######################
FROM ubuntu:16.04

# mycli - mysql command line
# http://mycli.net/
RUN apt-get update && apt-get install -y mycli &&\
    export LC_ALL=C.UTF-8 && export LANG=C.UTF-8

#USER developer
#ENV HOME /home/developer
CMD /bin/bash
