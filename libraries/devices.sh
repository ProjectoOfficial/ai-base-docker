#!/bin/bash

detect_hostdevice_type(){
    local device="UNKNOWN"

    if [ -e /proc/device-tree/model ]; then
        if grep -qi "Raspberry Pi" /proc/device-tree/model; then
            device="RASPBERRY_PI"
        elif grep -qi "Jetson Nano" /proc/device-tree/model; then
            device="JETSON_NANO"
        elif grep -qi "Jetson Orin" /proc/device-tree/model; then
            device="JETSON_ORIN_NANO"
        else
            device="DESKTOP_COMPUTER"
        fi
    else
        device="DESKTOP_COMPUTER"
    fi

    echo "$device"
}

load_hostdevice_properties(){
    local device=$1
    options=""
    case $device in
        "RASPBERRY_PI")
            ;;
        "JETSON_NANO")
            options+="--privileged "
            options+="--runtime=nvidia "
            options+="--gpus all "
            #options+="--device=/dev/nvidia-modeset "
            options+="-v /proc/device-tree/compatible:/proc/device-tree/compatible "
            options+="-v /proc/device-tree/chosen:/proc/device-tree/chosen "            
            ;;
        "JETSON_ORIN_NANO")
            options+="--runtime=nvidia "
            options+="--gpus all "
            options+="--device=/dev/nvidia-modeset "
            options+="-v /proc/device-tree/compatible:/proc/device-tree/compatible "
            options+="-v /proc/device-tree/chosen:/proc/device-tree/chosen "
            options+="--device=/dev/dri:/dev/dri "
            ;;
        "DESKTOP_COMPUTER")
            if command nvcc -V > /dev/null 2>&1 && command nvidia-smi > /dev/null 2>&1; then
                options+="--gpus all "                                              # eat all gpus
                options+="--runtime=nvidia "
                options+="--device=/dev/nvidia-modeset "                            # nvidia modeset map to support graphic card acceleration
            fi
            options+="--device=/dev/dri:/dev/dri "                                  # map host DRI (Direct Rendering Infrastructure) to container
            ;;
        *)
            echo "Unknown device"
            ;;
    esac

    echo "$options"
}

load_videocameras() {
    local video_devices=$(ls /dev/video* 2>/dev/null)

    if [ -n "$video_devices" ]; then
        echo "$video_devices"
    else
        echo "No video device found" >&2
        return 1
    fi
}
