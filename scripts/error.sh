#!/bin/bash

set -e                  # Exit on error
set -o pipefail         # Exit on pipeline error
set -u                  # Treat unset variable as error

# define current source directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Include logging functions
source $SCRIPT_DIR/logging.sh

#*******************************************
log_title_error "Falback on error"
#*******************************************

if [ $# -lt 3 ]; then
    echo "Error: No parameters provided."
    echo "Use: $0 <Mounting point list> <Chroot directory> <Tmp directory> ..."
    exit 1
fi

for dir in $1 $2; do
    if [ ! -d "$dir" ]; then
        log_error "Error: '$dir' is not a valid directory."
        exit 1
    fi
done

CHROOT_DIR="$1"
TMP_DIR="$2"

MOUNT_LIST=("${@:3}")

#*******************************************
log_title "Unmount filesystem"
#*******************************************
$SCRIPT_DIR/umount.sh $CHROOT_DIR "${MOUNT_LIST[@]}"

#*******************************************
log_title "Clean tmp directories"
#*******************************************
rm -rf $TMP_DIR