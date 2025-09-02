#!/bin/bash

set -e                  # Exit on error
set -o pipefail         # Exit on pipeline error

# define current source directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Include logging functions
source $SCRIPT_DIR/logging.sh

if [ -z "$1" ]; then
    log_error "Error: No parameters provided."
    log_info "Use: $0 <directory>"
    exit 1
fi

if [ ! -d "$1" ]; then
    log_error "Error: '$1' is not a valid directory."
    exit 1
fi

CHROOT_DIR="$1"

#*******************************************
log_title "Mount filesystem"
#*******************************************
shift # Remove first argument

ALL_SUCCESS=true

if [ $# -eq 0 ]; then
    log_error "The list of directories to mount was not provided."
    exit 1
fi

for dir in "$@"; do
    log_info "Mounting /$dir in ${CHROOT_DIR}/$dir"

    sudo mount --bind "/$dir" "${CHROOT_DIR}/$dir"

    if [ $? -ne 0 ]; then
        log_error "Failed to mount directory /$dir."
        ALL_SUCCESS=false 
        break             
    fi
done


if [ "$ALL_SUCCESS" = true ]; then
    log_success "All virtual directories were correctly mounted."
else
    log_error "The process was interrupted due to a mount error."
    exit 1
fi