#!/bin/bash

#*******************************************
log_info "1. Creating EFI System Partition image (efi.img)"
#*******************************************
# Define o tamanho da imagem da partição EFI (em MB)
EFI_IMG_SIZE=64


truncate -s "${EFI_IMG_SIZE}M" $EFI_IMG_FILE
mkfs.vfat -F 32 $EFI_IMG_FILE