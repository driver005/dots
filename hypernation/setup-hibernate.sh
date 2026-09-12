#!/usr/bin/env bash
# setup-hibernate.sh — Configure rock-solid NVIDIA hibernation and power management
# Usage: sudo ./hypernation/setup-hibernate.sh
set -euo pipefail

if [ "${EUID:-$(id -u)}" -ne 0 ]; then
    echo "Error: This script must be run as root. Please run: sudo $0" >&2
    exit 1
fi

HYPERNATION_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "=========================================================="
echo " Setting up Safe Power Management & NVIDIA Hibernation"
echo "=========================================================="

# 1. Verify Swap Partition
SWAP_UUID=$(lsblk -no UUID /dev/nvme1n1p3 2>/dev/null || true)
if [ -n "$SWAP_UUID" ]; then
    echo "==> Verified NVMe swap partition: /dev/nvme1n1p3 (UUID=$SWAP_UUID)"
else
    echo "==> Warning: /dev/nvme1n1p3 not found, checking active swap..."
fi

# 2. Install logind configuration
echo "==> Installing /etc/systemd/logind.conf.d/hibernate-lid.conf"
mkdir -p /etc/systemd/logind.conf.d
install -m 644 "$HYPERNATION_DIR/logind-hibernate-lid.conf" /etc/systemd/logind.conf.d/hibernate-lid.conf

# 3. Install sleep configuration
echo "==> Installing /etc/systemd/sleep.conf.d/hibernate-delay.conf"
mkdir -p /etc/systemd/sleep.conf.d
install -m 644 "$HYPERNATION_DIR/sleep-hibernate-delay.conf" /etc/systemd/sleep.conf.d/hibernate-delay.conf

# 4. Install NVIDIA modprobe override
echo "==> Installing /etc/modprobe.d/zz-hibernate-nvidia-override.conf"
mkdir -p /etc/modprobe.d
install -m 644 "$HYPERNATION_DIR/zz-hibernate-nvidia-override.conf" /etc/modprobe.d/zz-hibernate-nvidia-override.conf

# 5. Install system-sleep hooks
echo "==> Installing /etc/systemd/system-sleep hooks (zram & btrfs-sync)"
mkdir -p /etc/systemd/system-sleep
install -m 755 "$HYPERNATION_DIR/zram-hibernate.sh" /etc/systemd/system-sleep/zram-hibernate.sh
install -m 755 "$HYPERNATION_DIR/btrfs-sync-sleep.sh" /etc/systemd/system-sleep/btrfs-sync-sleep.sh
# Also update /usr/lib/systemd/system-sleep/zram-hibernate.sh if it exists from earlier setup
if [ -f /usr/lib/systemd/system-sleep/zram-hibernate.sh ]; then
    install -m 755 "$HYPERNATION_DIR/zram-hibernate.sh" /usr/lib/systemd/system-sleep/zram-hibernate.sh
fi

# 6. Remove broken systemd-suspend redirect symlink if present
if [ -L /etc/systemd/system/systemd-suspend.service ]; then
    TARGET=$(readlink /etc/systemd/system/systemd-suspend.service)
    if [[ "$TARGET" =~ suspend-then-hibernate ]]; then
        echo "==> Removing broken systemd-suspend.service redirect symlink"
        rm -f /etc/systemd/system/systemd-suspend.service
    fi
fi

# 7. Enable all 4 required NVIDIA power management services
echo "==> Enabling NVIDIA power management services in systemd"
systemctl daemon-reload
systemctl enable nvidia-suspend.service || true
systemctl enable nvidia-hibernate.service || true
systemctl enable nvidia-resume.service || true
systemctl enable nvidia-suspend-then-hibernate.service || true

# 8. Ensure Dracut resume module is configured
mkdir -p /etc/dracut.conf.d
if [ ! -f /etc/dracut.conf.d/hibernate.conf ]; then
    echo 'add_dracutmodules+=" resume "' > /etc/dracut.conf.d/hibernate.conf
    echo "==> Created /etc/dracut.conf.d/hibernate.conf"
fi

# 9. Update initramfs if dracut is present
if [ -x /usr/share/libalpm/scripts/dracut-install-garuda ]; then
    echo "==> Rebuilding initramfs via Garuda dracut helper..."
    echo "usr/lib/modules/$(uname -r)/pkgbase" | /usr/share/libalpm/scripts/dracut-install-garuda
elif [ -f "/boot/initramfs-linux-zen.img" ]; then
    KVER=$(uname -r)
    echo "==> Rebuilding /boot/initramfs-linux-zen.img for $KVER..."
    dracut --force --hostonly "/boot/initramfs-linux-zen.img" --kver "$KVER"
elif command -v dracut &>/dev/null; then
    echo "==> Rebuilding initramfs with dracut..."
    dracut --force
fi

echo "=========================================================="
echo " Hibernation & Power Management configured successfully!"
echo "=========================================================="
