#!/bin/bash

source libraries/logging.sh

load_arguments(){
    options=""

    while [ "$#" -gt 0 ]; do
        case "$1" in
            -w)
                video_devices=$(load_videocameras) 
                if [ $? -eq 0 ]; then
                    for device in $video_devices; do
                        options+="--device $device:$device "
                    done
                fi
                ;;
            -d)
                shift
                directory=$(import_directory "$1")
                if [ $? -eq 0 ]; then
                    folder_name=$(basename "$directory")
                    options+="-v $directory:/home/user/"$folder_name" "
                else
                    log_error "load_arguments: could not import path $directory"
                    exit 1
                fi
                ;;
            *)
                log_error "load_arguments: unrecognized argument $1"
                exit 1
                ;;
        esac
        shift
    done

    echo "$options"
}