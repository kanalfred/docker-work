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
RUN apt-get update && apt-get install -y mycli

#USER developer
#ENV HOME /home/developer
CMD /bin/bash
