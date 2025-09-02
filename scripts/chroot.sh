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

LIVE_USERNAME="spec"
LIVE_HOSTNAME="SpectrumOS"

#*******************************************

mount -a
export HOME=/root
export LC_ALL=C

apt update

apt install -y \
    ubuntu-standard \
    linux-image-generic \
    linux-headers-generic \
    linux-firmware \
    casper \
    live-boot \
    live-config \
    live-config-systemd \
    systemd-sysv \
    initramfs-tools \
    grub-efi-amd64 \
    grub-efi-amd64-signed \
    shim-signed \
    shim \
    efibootmgr \
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
    os-prober

#*******************************************
echo "Configuring system settings..."
#*******************************************
echo "$LIVE_HOSTNAME" > /etc/hostname

#*******************************************
echo "Creating Users ..."
#*******************************************
for USER in "${USERS_LIST[@]}"; do
    NAME=$(echo $USER | cut -d':' -f1)
    PASSWORD=$(echo $USER | cut -d':' -f2)
    SUDO=$(echo $USER | cut -d':' -f3)

    useradd -m -s /bin/bash "$NAME"

    if [ "$SUDO" == "true" ]; then
        usermod -aG sudo "$NAME"
    fi

cat << EOF
------------------------------------------
👤 User                    : $NAME
🔐 IS SUDO                : $SUDO
------------------------------------------
EOF

done # end for Creating Users

#*******************************************
echo "Configuring Live System..."
#*******************************************

# Configurar usuário live principal
echo "$LIVE_USERNAME" > /etc/casper.conf

# Variáveis de ambiente para o live-boot
cat <<EOF >> /etc/environment
CASPER_USERNAME=$LIVE_USERNAME
CASPER_HOSTNAME=$LIVE_HOSTNAME
CASPER_GENERATE_UUID=1
EOF

# Configurar live-config
mkdir -p /etc/live/config.conf.d
cat <<EOF > /etc/live/config.conf.d/username.conf
LIVE_USERNAME="$LIVE_USERNAME"
LIVE_USER_FULLNAME="Live User"
LIVE_HOSTNAME="$LIVE_HOSTNAME"
EOF

#*******************************************
echo "Live Boot Configuration"
#*******************************************

# Configurar initramfs para live boot
mkdir -p /etc/initramfs-tools/conf.d
echo 'BOOT=casper' > /etc/initramfs-tools/conf.d/live
echo 'COMPRESS=xz' >> /etc/initramfs-tools/conf.d/live

# Configurar módulos necessários
cat <<EOF >> /etc/initramfs-tools/modules
# Módulos necessários para live boot
squashfs
overlay
loop
EOF

#*******************************************
echo "Autologin Configuration"
#*******************************************
mkdir -p /etc/gdm3/

cat <<EOF > /etc/gdm3/custom.conf
[daemon]
AutomaticLoginEnable = true
AutomaticLogin = $LIVE_USERNAME

[security]

[xdmcp]

[chooser]

[debug]
EOF

#*******************************************
echo "Live User Permissions"
#*******************************************
# Remove senha do usuário live
passwd -d $LIVE_USERNAME

# Permite sudo sem senha para usuário live
echo "$LIVE_USERNAME ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/99_live_user
chmod 0440 /etc/sudoers.d/99_live_user

#*******************************************
echo "Filesystem Configuration for Live System"
#*******************************************
# Configurar fstab para sistema live
cat <<EOF > /etc/fstab
# /etc/fstab: static file system information for live system
proc /proc proc defaults 0 0
sys /sys sysfs defaults 0 0
tmpfs /tmp tmpfs defaults,nodev,nosuid,size=20% 0 0
EOF

#*******************************************
echo "Network Configuration"
#*******************************************
# Configurar NetworkManager para iniciar automaticamente
systemctl enable NetworkManager

# Configurar resolv.conf
cat <<EOF > /etc/systemd/resolved.conf
[Resolve]
DNS=8.8.8.8 1.1.1.1
FallbackDNS=8.8.4.4 1.0.0.1
EOF

#*******************************************
echo "Updating Initramfs"
#*******************************************
update-initramfs -c -k all

#*******************************************
echo "Cleaning the environment"
#*******************************************
apt clean
apt autoclean
apt autoremove --purge
rm -rf /tmp/* ~/.bash_history /var/tmp/*

# Limpar logs
find /var/log -type f -exec truncate -s 0 {} \;

# Limpar cache
rm -rf /var/cache/apt/archives/*.deb
rm -rf /var/cache/apt/archives/partial/*.deb

echo "Cleanup finished"

#*******************************************
echo "Final System Configuration"
#*******************************************
# Configurar timezone padrão
ln -sf /usr/share/zoneinfo/America/Sao_Paulo /etc/localtime

# Configurar locale
echo "en_US.UTF-8 UTF-8" > /etc/locale.gen
locale-gen
echo 'LANG="en_US.UTF-8"' > /etc/locale.conf

# Limpar resolv.conf para o live system
truncate -s 0 /etc/resolv.conf

#*******************************************
cat << EOF
------------------------------------------
⚙️ EXITING THE CHROOT
------------------------------------------
EOF
#*******************************************
exit