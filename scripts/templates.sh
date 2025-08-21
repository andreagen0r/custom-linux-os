#!/bin/bash

#*******************************************
# lsb-release
#*******************************************
cat <<EOF > "$TMP_DIR/etc/lsb-release"
DISTRIB_ID=$DISTRIB_ID
DISTRIB_RELEASE=$DISTRIB_RELEASE
DISTRIB_CODENAME=$DISTRIB_CODENAME
DISTRIB_DESCRIPTION=$DISTRIB_DESCRIPTION
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

cat <<EOF > "$BUILD_DIR/$EFI_DIR/grub.cfg"
insmod gfxterm
terminal_output gfxterm

set theme=\$prefix/themes/$DISTRIB_ID/theme.txt
set gfxmode="auto"
set gfxpayload="keep"

insmod all_video
insmod png
insmod jpeg
insmod font
insmod normal

set default="0"
set timeout="15"
set timeout_style="menu"

menuentry "Start $DISTRIB_ID in Live Mode" --class linux {
    search --set=root --file /casper/vmlinuz
    linux /casper/vmlinuz boot=casper quiet splash ---
    initrd /casper/initrd
}

menuentry "Automatic Install $DISTRIB_ID" --class install {
    search --set=root --file /casper/vmlinuz
    linux /casper/vmlinuz autoinstall quiet splash ---
    initrd /casper/initrd
}

menuentry "Memoy Test" --class memtest {
    linux16 /boot/memtest86+x64.bin
}

menuentry "Start from first HD" --class hdd {
    set root='(hd0)'
    chainloader +1
    boot
}

menuentry "Reboot" --class reboot {
    reboot
}

menuentry "Shutdown" --class shutdown {
    halt
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