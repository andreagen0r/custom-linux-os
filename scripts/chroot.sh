#!/bin/bash

#*******************************************
# Everything inside this file must be executed 
# inside the chroot
#*******************************************
cat << EOF

------------------------------------------
⚙️ RUNNING INSIDE CHROOT
------------------------------------------
EOF

#*******************************************
# Global Variables
#*******************************************
USERS_LIST=(
    "spec:spec:false"
    "vmi:spectrum2020:true"
)

#*******************************************

mount -a
export HOME=/root
export LC_ALL=C

apt update

apt install -y \
    linux-image-generic \
    linux-headers-generic \
    linux-firmware \
    systemd-sysv \
    initramfs-tools \
    grub-efi-amd64 \
    grub-efi-amd64-signed \
    shim-signed \
    shim \
    efibootmgr \
    casper \
    ubuntu-desktop-minimal \
    network-manager \
    gnome-shell \
    gdm3 \
    gnome-terminal \
    nautilus \
    gnome-control-center \
    gnome-session \
    gnome-session-canberra \
    gnome-bluetooth \
    wireless-tools \
    xdg-utils \
    xdg-user-dirs \
    xdg-user-dirs-gtk \
    bluez \
    bluez-cups \
    cups \
    cups-bsd \
    cups-client \
    calamares \
    os-prober \
    syslinux \
    isolinux

 
#*******************************************
echo "Creating Users ..."
#*******************************************
for USER in "${USERS_LIST[@]}"; do
    NAME=$(echo $USER | cut -d':' -f1)
    PASSWORD=$(echo $USER | cut -d':' -f2)
    SUDO=$(echo $USER | cut -d':' -f3)

    sudo useradd -m -s /bin/bash "$NAME"

    if [ "$SUDO" == "true" ]; then
        sudo usermod -aG sudo "$NAME"
    fi

cat << EOF
------------------------------------------
👤 Publisher               : $NAME
🫆 IS SUDO                 : $SUDO
------------------------------------------
EOF

done # end for Sreating Users


#*******************************************
echo "Initramfs and GRUB"
#*******************************************
update-initramfs -c -k all

#*******************************************
echo "Check UUIDs"
#*******************************************
blkid
cat /etc/fstab
cat /boot/grub/grub.cfg | grep -E 'linux|initrd|root=UUID'

#*******************************************
echo "Cleaning the environment"
#*******************************************
apt clean
apt autoclean
apt autoremove --purge
sudo apt-cache clean
rm -rf /tmp/* ~/.bash_history
echo "The cleanup is finished"
#*******************************************

#*******************************************
cat << EOF
------------------------------------------
⚙️ EXITING THE CHROOT
------------------------------------------
EOF
#*******************************************
exit
