set -x
# todo shell: check if the volume path exit and create as need
# change MYSQL_ROOT_PASSWORD password
# Set password : export DOCKER_PASS='xxxx'
# Unit linkl
# https://coreos.com/os/docs/latest/getting-started-with-systemd.html
IPADDRESS="192.168.3.112"
DOCKER_PASS=${DOCKER_PASS:='docker!'}
docker run --name work -p 2222:22 -h work -v /data:/data -v /var/run/docker.sock:/var/run/docker.sock -d kanalfred/work
