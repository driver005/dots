# Power Management & Safe Hibernation

This module defines the power management and hibernation configuration for the system (Lenovo ThinkPad with NVIDIA GPU + Btrfs on Linux).

## What This Solves

1. **NVIDIA VRAM Preservation across Sleep/Hibernate**:
   - Stores GPU memory allocations in `/var/tmp` (persistent filesystem on NVMe, not tmpfs).
   - Enables all 4 required systemd services (`nvidia-suspend`, `nvidia-hibernate`, `nvidia-resume`, `nvidia-suspend-then-hibernate`).
   - Ensures `nvidia-suspend-then-hibernate.service` is enabled so the driver does not reject kernel freeze with `pci_pm_freeze returns -5`.

2. **ZRAM Swap Management**:
   - `zram-hibernate.sh` disables zram during `hibernate`, `hybrid-sleep`, and `suspend-then-hibernate` so the kernel writes the memory image directly to the NVMe swap partition.

3. **Btrfs Crash Protection**:
   - `btrfs-sync-sleep.sh` executes a double `sync` before any sleep/hibernate transition, committing all Btrfs transactions to disk so no unsaved file changes can be rolled back if hardware freezes.

4. **Lid Action**:
   - Configures `HandleLidSwitch=suspend-then-hibernate` with a 2-hour suspend delay before transitioning to disk hibernation.

## Setup

Run:
```bash
sudo ./hypernation/setup-hibernate.sh
```
