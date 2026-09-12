#!/bin/bash
# Disable zram before hibernate or suspend-then-hibernate so the kernel writes the image to the real swap partition
case "$1" in
    pre)
        if [ "$2" = "hibernate" ] || [ "$2" = "hybrid-sleep" ] || [ "$2" = "suspend-then-hibernate" ]; then
            systemctl stop systemd-zram-setup@zram0.service 2>/dev/null || true
            systemctl mask systemd-zram-setup@zram0.service 2>/dev/null || true
            swapoff /dev/zram0 2>/dev/null || true
        fi
        ;;
    post)
        if [ "$2" = "hibernate" ] || [ "$2" = "hybrid-sleep" ] || [ "$2" = "suspend-then-hibernate" ]; then
            systemctl unmask systemd-zram-setup@zram0.service 2>/dev/null || true
            systemctl start systemd-zram-setup@zram0.service 2>/dev/null || true
        fi
        ;;
esac
