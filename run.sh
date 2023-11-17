#!/bin/bash

# exit on error
set -e

IMAGE_NAME="ai-base-docker"
IMAGE_TAG="1.0.0"

echo $IMAGE_NAME:$IMAGE_TAG started!

CONTAINER_NAME="ai-base"

PATH_TO_SRC_FOLDER=""

MOUNT_SRC_PATH="-v $(dirname $PWD)/src:/home/user/src"
MOUNT_WEBCAM=""

if echo "$1" | grep -q "webcam"; then
        video_device=$(ls /dev/video* 2>/dev/null | head -n 1)
        if [ -n "$video_device" ]; then
                echo "setting device: $video_device"
                MOUNT_WEBCAM="--device ${video_device}:${video_device}"
        else
                echo "Could not find any video input device"
        fi
fi

# x11 forwarding
XSOCK=/tmp/.x11-unix
XAUTH=/tmp/.docker.xauth
xauth nlist $DISPLAY | sed -e 's/^..../ffff/' | xauth -f $XAUTH nmerge -
chmod 755 $XAUTH

launch_command="docker run "
base_options="--shm-size 2GB -ti --rm "                                 # set container shared memory to 2GB
                                                                        # start container with interactive mode
                                                                        # and enable auto-remove of the container

options="-v /media:/media "                                             # mount media directory
options+="-v /usr/lib/x86_64-linux-gnu:/usr/lib/x86_64-linux-gnu "      # mount GNU C library
options+="${MOUNT_SRC_PATH} "                                           # mount project directory
options+="-e http_proxy -e https_proxy "                                # set environment variables for http and https
options+="-e "DISPLAY" --env "QT_X11_NO_MITSHM=1" "                     # X11 display and disable memory share in MIT-SHM for Qt applications
options+="-v $XSOCK:$XSOCK -v $XAUTH:$XAUTH "                           # X11 forward settings
options+="-e XAUTHORITY=$XAUTH "                                        # set XAUTHORITY with host authorization path
options+="--name $CONTAINER_NAME "                                      # update container name
options+="--user $(id -u):$(id -g) "                                    # sync user ID and group ID
options+="--net=host "                                                  # add internet connetion
options+="--group-add video "                                           # add container to video group
options+="--device=/dev/dri:/dev/dri "                                  # map host DRI (Direct Rendering Infrastructure) to container
options+="${MOUNT_WEBCAM} "                                             # mount webcam path
options+="$IMAGE_NAME:$IMAGE_TAG "                                      # set image name and image tag

if command nvidia-docker > /dev/null 2>&1 && command nvcc -v > /dev/null 2>&1 && command nvidia-smi > /dev/null 2>&1; then
        launch_command="nvidia-docker run "
        options+="--device=/dev/nvidia-modeset "                        # nvidia modeset map to support graphic card acceleration
        base_options+="--gpus all "                                     # eat all gpus
fi

$launch_command $base_options $options