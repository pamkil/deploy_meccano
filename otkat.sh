#!/bin/bash
if [[ -z "$1" ]]; then
    echo "usage ./otkat.sh version, version must be like 20170806135307 from /home/meccano/releases/20170806135307"
    echo $1
exit 1
else

version=$1
ln -sfn /home/meccano/releases/$version /home/meccano/releases/current
#/root/docker/docker_node.sh restart
#/root/docker/docker_php.sh restart
