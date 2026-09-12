# Power Management & Safe Hibernation

This module defines the power management and hibernation configuration for the system (Lenovo ThinkPad with NVIDIA GPU + Intel UHD Graphics + Btrfs on Linux).

## What This Solves

1. **Fix for `nv_pmops_freeze returns -5` on Resume (Early KMS Elimination)**:
   - **Root Cause**: When NVIDIA drivers are loaded into early initramfs, the early boot kernel lacks access to the userspace procfs suspend interface and `/var/tmp`. When attempting to restore the hibernation image, the boot kernel's freeze callback (`nv_pmops_freeze`) fails with `-EIO (-5)`, aborting image recovery and discarding the saved session.
   - **Fix**: Omit `nvidia`, `nvidia_modeset`, `nvidia_uvm`, `nvidia_drm` from the dracut initramfs via `dracut-nvidia-omit.conf`. The laptop display is driven by the integrated Intel UHD graphics (`i915`), which handles boot and resume freezing flawlessly. NVIDIA drivers are loaded cleanly by udev once the root filesystem is mounted, and their VRAM is restored via `nvidia-resume.service`.

2. **NVIDIA VRAM Preservation across Sleep/Hibernate**:
   - Stores GPU memory allocations in `/var/tmp` (persistent filesystem on NVMe, not tmpfs).
   - Configures `NVreg_PreserveVideoMemoryAllocations=1`, `NVreg_TemporaryFilePath=/var/tmp`, and `NVreg_UseKernelSuspendNotifiers=1` via modprobe.
   - Removes hardcoded conflicting flags from GRUB kernel command line.
   - Enables all 4 required systemd services (`nvidia-suspend`, `nvidia-hibernate`, `nvidia-resume`, `nvidia-suspend-then-hibernate`).

3. **ZRAM Swap Management**:
   - `zram-hibernate.sh` disables zram during `hibernate`, `hybrid-sleep`, and `suspend-then-hibernate` so the kernel writes the memory image directly to the NVMe swap partition.

4. **Btrfs Crash Protection**:
   - `btrfs-sync-sleep.sh` executes a double `sync` before any sleep/hibernate transition, committing all Btrfs transactions to disk so no unsaved file changes can be rolled back if hardware freezes.

5. **Lid Action**:
   - Configures `HandleLidSwitch=suspend-then-hibernate` with a 2-hour suspend delay before transitioning to disk hibernation.

## Setup

Run:
```bash
sudo ./hypernation/setup-hibernate.sh
```

## Testing Hibernation

To test safely:
```bash
# Test device freeze/thaw cycle (dry run — no reboot, no disk write):
sudo ./hypernation/test-hibernate-dry-run.sh devices

# Test full real hibernation (writes to swap partition, powers off):
sudo ./hypernation/test-hibernate-dry-run.sh full
```
