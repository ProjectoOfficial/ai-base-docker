#!/bin/bash

source ./libraries/devices.sh

# Detect the device type
device=$(detect_hostdevice_type)
echo "Detected device: $device"

DOCKER_DIRNAME="ai-base-docker"
if [ "$device" = "RASPBERRY_PI" ]; then
    DOCKERFILE_REL_PATH="$DOCKER_DIRNAME/dockerfiles/Dockerfile.raspberrypi"
    echo "Building for Raspberry Pi"
elif [ "$device" = "JETSON_NANO" ]; then
    DOCKERFILE_REL_PATH="$DOCKER_DIRNAME/dockerfiles/Dockerfile.jetsonNano"
    echo "Building for Nvidia Jetson Nano"
elif [ "$device" = "JETSON_ORIN_NANO" ]; then
    DOCKERFILE_REL_PATH="$DOCKER_DIRNAME/dockerfiles/Dockerfile.jetsonOrin"
    echo "Building for Nvidia Jetson Orin"
elif [ "$device" = "DESKTOP_COMPUTER" ]; then
    DOCKERFILE_REL_PATH="$DOCKER_DIRNAME/dockerfiles/Dockerfile"
    echo "Building for default desktop environment"
else
    echo "Device not supported yet"
    exit 1
fi


IMAGE_NAME="ai-base-docker"       # IMAGE NAME: if you change this, you have to change the name also in run.sh
IMAGE_TAG="latest"                  # IMAGE TAG: if you change this, you have to change the tag also in run.sh
echo "Started build for $IMAGE_NAME:$IMAGE_TAG"

# Absolute path of the Dockerfile
MAIN_DIR=$(dirname "$(cd "$(dirname "$0")" && pwd)")
echo "setting main directory as $MAIN_DIR"

# Run the build of the Docker image
echo "building: $MAIN_DIR/$DOCKERFILE_REL_PATH"
docker build -t "$IMAGE_NAME:$IMAGE_TAG" -f "$MAIN_DIR/$DOCKERFILE_REL_PATH" "$MAIN_DIR" \
        --build-arg UID=$(id -u) --build-arg GID=$(id -g) --build-arg USER_NAME="user"


# Check if the build has been successfully completed
if [ $? -eq 0 ]; then
    echo "Build of the image completed successfully."
    echo "now you can run the image with: ./run.sh"
    echo "-d /path/to/specific/folder to mount a specific folder in /home/user/src"
    echo "-w to mount the first video device found in /dev/video*"
else
    echo "An error occurred during the image build: $? ."
fi
