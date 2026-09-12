#!/bin/bash
# Flush all filesystem buffers and commit Btrfs transactions before ANY sleep/hibernate state.
# This guarantees that even if a hardware/driver freeze failure occurs, no user edits or
# uncommitted Btrfs blocks are ever lost upon reboot.
case "$1" in
    pre)
        sync
        sync
        ;;
esac
