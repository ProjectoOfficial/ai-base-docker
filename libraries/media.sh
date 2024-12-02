#!/bin/bash

source libraries/logging.sh

import_directory(){
    if [ -z "$1" ]; then
        log_error "import_directory: Missing directory path argument."
        exit 1
    elif [ ! -d "$1" ]; then
        log_error "import_directory: '$1' is not a valid directory."
        exit 1
    fi

    echo "$1"
}