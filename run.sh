#!/bin/bash

# exit on error
set -e

source ./libraries/devices.sh
source ./libraries/arguments.sh
source ./libraries/media.sh

IMAGE_NAME="ai-base-docker"
IMAGE_TAG="latest"

echo $IMAGE_NAME:$IMAGE_TAG started!

CONTAINER_NAME="ai-base"

# x11 forwarding
echo "Setting x11 forwarding"
XSOCK=/tmp/.x11-unix
XAUTH=/tmp/.docker.xauth
xauth nlist $DISPLAY | sed -e 's/^..../ffff/' | xauth -f $XAUTH nmerge -
chmod 755 $XAUTH

launch_command="docker run "
base_options="--shm-size 2GB -ti --rm "                                 # set container shared memory to 2GB
                                                                        # start container with interactive mode
                                                                        # and enable auto-remove of the container

echo "preparing docker run options"

device_type=$(detect_hostdevice_type)
dev_options+=$(load_hostdevice_properties "$device_type")
options+="$dev_options "                                                    # set device options
echo "Detected device type: $device_type"

options+="-v /media:/media "                                             # mount media directory
options+="${MOUNT_SRC_PATH} "                                           # mount project directory
options+="-e http_proxy -e https_proxy "                                # set environment variables for http and https
options+="-e "DISPLAY" --env "QT_X11_NO_MITSHM=1" "                     # X11 display and disable memory share in MIT-SHM for Qt applications
options+="-v $XSOCK:$XSOCK -v $XAUTH:$XAUTH "                           # X11 forward settings
options+="-e XAUTHORITY=$XAUTH "                                        # set XAUTHORITY with host authorization path
options+="--name $CONTAINER_NAME "                                      # update container name
options+="--user user:$(id -g) "                                        # sync user ID and group ID
options+="--net=host "                                                  # add internet connetion
options+="--group-add video "                                           # add container to video group
options+="-v $(dirname $PWD)/src:/home/user/src "                       # mount src path

args_options=$(load_arguments "$@")
options+="$args_options "                                               # set arguments options

options+="$IMAGE_NAME:$IMAGE_TAG "                                      # set image name and image tag

#echo $options
$launch_command $base_options $options
