#*******************************************
# lsb-release
#*******************************************
cat <<EOF > "$TMP_DIR/etc/lsb-release"
DISTRIB_ID="$DISTRIB_ID"
DISTRIB_RELEASE="$DISTRIB_RELEASE"
DISTRIB_CODENAME="$DISTRIB_CODENAME"
DISTRIB_DESCRIPTION="$DISTRIB_DESCRIPTION"
EOF

#*******************************************
# os-release
#*******************************************
cat <<EOF > "$TMP_DIR/etc/os-release"
NAME="$DISTRIB_ID"
VERSION="$DISTRIB_RELEASE"
ID=$(echo "${DISTRIB_ID,,}")
ID_LIKE=$(echo "${DISTRIB_ID,,}")
PRETTY_NAME="$DISTRIB_ID $DISTRIB_RELEASE"
VERSION_ID="$DISTRIB_RELEASE"
HOME_URL="$DISTRIB_URL"
SUPPORT_URL="$DISTRIB_URL"
BUG_REPORT_URL="$DISTRIB_URL"
EOF



#*******************************************
# Grub configuration
#*******************************************

# Configuração GRUB corrigida para templates.sh

cat <<EOF > "$BUILD_DIR/$EFI_DIR/grub.cfg"
insmod gfxterm
terminal_output gfxterm

loadfont DejaVuSans

set theme=\$prefix/themes/$DISTRIB_ID/theme.txt
set gfxmode="auto"

insmod all_video
insmod png
insmod jpeg
insmod font
insmod normal

set default="0"
set timeout="15"
set timeout_style="menu"

menuentry "Start $DISTRIB_ID in Live Mode" --class linux {
    set gfxpayload=keep
    linux	/casper/vmlinuz boot=casper username=spec hostname=SpectrumOS quiet splash ---
    initrd	/casper/initrd
}

menuentry "Start $DISTRIB_ID (Safe Graphics)" --class linux {
    set gfxpayload=keep
    linux	/casper/vmlinuz boot=casper username=spec hostname=SpectrumOS nomodeset quiet splash ---
    initrd	/casper/initrd
}

menuentry "Start $DISTRIB_ID (Debug Mode)" --class linux {
    set gfxpayload=keep
    linux	/casper/vmlinuz boot=casper username=spec hostname=SpectrumOS debug ---
    initrd	/casper/initrd
}

menuentry "Automatic Install $DISTRIB_ID" --class install {
    set gfxpayload=keep
    linux	/casper/vmlinuz boot=casper username=spec hostname=SpectrumOS autoinstall quiet splash ---
    initrd	/casper/initrd
}

grub_platform
if [ "\$grub_platform" = "efi" ]; then
menuentry 'Boot from next volume' {
	exit 1
}
menuentry 'UEFI Firmware Settings' {
	fwsetup
}
else
menuentry 'Test memory' {
	linux16 /boot/memtest86+x64.bin
}
fi

menuentry "Reboot" --class reboot {
    reboot
}

menuentry "Shutdown" --class shutdown {
    halt
}
EOF

cat <<EOF > "$BUILD_DIR/$EFI_DIR/loopback.cfg"

menuentry "Try or Install $DISTRIB_ID" {
	set gfxpayload=keep
	linux	/casper/vmlinuz  iso-scan/filename=\${iso_path} --- quiet splash
	initrd	/casper/initrd
}
menuentry "$DISTRIB_ID (safe graphics)" {
	set gfxpayload=keep
	linux	/casper/vmlinuz nomodeset  iso-scan/filename=\${iso_path} --- quiet splash
	initrd	/casper/initrd
}
EOF


#*******************************************
# Grub Theme
#*******************************************
cat <<EOF > "$BUILD_DIR/$EFI_DIR/themes/$DISTRIB_ID/theme.txt"
title-text:""
title-font:"DejaVu Sans Regular 32"
desktop-image:"background.png"
desktop-color:"#404041"
terminal-width: "100%"
terminal-height: "100%"
terminal-border: "0"
terminal-box:"terminal_box_*.png"

+ boot_menu {
    left=35%
    top=30%
    width=30%
    height=30%
    item_font = "DejaVu Sans Regular 18"
    item_color = "#000000"
    item_height = 36
    item_padding = 6
    item_spacing = 6
    selected_item_color = "#f4b41f"
    selected_item_font = "DejaVu Sans Regular 18"
    selected_item_pixmap_style = "select_*.png"
    icon_width=32
    icon_height=32
    item_icon_space=12
    icon_valign="center"
}

+ label {
    top=85%
    left=35%
    width=30%
    align="center"
    font="DejaVu Sans Regular 16"
    color="#000000"
    text="Use arrows keys to navigate and Enter to select."
}

+ label {
    id="__timeout__"
    top=88%
    left=35%
    width=30%
    align="center"
    font="DejaVuSans Bold 16"
    color="#000000"
    text="Booting in %d seconds"
}
EOF