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

nvidia-docker run  --shm-size 2GB -ti --rm --gpus all \
        -v /media:/media \
        -v /usr/lib/x86_64-linux-gnu:/usr/lib/x86_64-linux-gnu \
        ${MOUNT_SRC_PATH} \
        -e http_proxy -e https_proxy \
        -e HOST_USER_ID=$(id -u) -e HOST_GROUP_ID=$(id -g) \
        --device=/dev/nvidia-modeset \
        -e "DISPLAY" --env "QT_X11_NO_MITSHM=1" \
        -v $XSOCK:$XSOCK -v $XAUTH:$XAUTH \
        -e XAUTHORITY=$XAUTH \
        --name $CONTAINER_NAME \
        --user $(id -u):$(id -g) \
        --net='host' \
        --group-add video \
        --device=/dev/dri:/dev/dri \
        ${MOUNT_WEBCAM} \
        $IMAGE_NAME:$IMAGE_TAG
