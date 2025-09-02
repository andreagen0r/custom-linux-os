#*******************************************
log_title "Creating EFI System Partition image (efi.img)"
#*******************************************
EFI_IMG_FILE=$BUILD_DIR/boot/grub/efi.img

# Define o tamanho da imagem da partição EFI (em MB)
EFI_IMG_SIZE=64

truncate -s "${EFI_IMG_SIZE}M" $EFI_IMG_FILE
mkfs.vfat -F 32 $EFI_IMG_FILE

MOUNT_POINT=$(mktemp -d)
sudo mount -o loop $EFI_IMG_FILE $MOUNT_POINT

sudo mkdir -p $MOUNT_POINT/EFI/BOOT

sudo cp $CHROOT_DIR/usr/lib/shim/shimx64.efi $MOUNT_POINT/EFI/BOOT/bootx64.efi
sudo cp $CHROOT_DIR/usr/lib/shim/shimx64.efi $MOUNT_POINT/EFI/BOOT/
sudo cp $CHROOT_DIR/usr/lib/shim/mmx64.efi $MOUNT_POINT/EFI/BOOT/
sudo cp -r $CHROOT_DIR/usr/lib/grub/x86_64-efi/monolithic/. $MOUNT_POINT/EFI/BOOT/
sudo cp $BUILD_DIR/$EFI_DIR/grub.cfg $MOUNT_POINT/EFI/BOOT/
sudo cp $BUILD_DIR/$EFI_DIR/loopback.cfg $MOUNT_POINT/EFI/BOOT/

# Desmonta a imagem
sudo umount $MOUNT_POINT
sudo rm -rf $MOUNT_POINT