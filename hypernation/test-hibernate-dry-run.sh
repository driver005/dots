#!/usr/bin/env bash
# test-hibernate-dry-run.sh — Safe kernel dry run or full test for hibernation
# Usage:
#   sudo ./test-hibernate-dry-run.sh devices    # Test device freeze/thaw (NO reboot, NO disk write)
#   sudo ./test-hibernate-dry-run.sh core       # Test core CPU/device freeze/thaw (NO reboot)
#   sudo ./test-hibernate-dry-run.sh full       # Test real full hibernation (writes to swap, powers off)
set -euo pipefail

if [ "${EUID:-$(id -u)}" -ne 0 ]; then
    echo "Error: Must be run as root. Please run: sudo $0 [mode]" >&2
    echo "Supported modes: devices (default dry run), core, processors, platform, full" >&2
    exit 1
fi

MODE="${1:-devices}"

if [ "$MODE" = "full" ]; then
    echo "=========================================================="
    echo " Executing FULL Hibernation Test"
    echo "=========================================================="
    echo " This will save memory to swap and power off your machine."
    echo " Press the power button to resume."
    echo "=========================================================="
    echo none > /sys/power/pm_test
    systemctl hibernate
    exit 0
fi

if ! grep -qw "$MODE" /sys/power/pm_test; then
    echo "Error: Invalid mode '$MODE'. Available modes: $(cat /sys/power/pm_test) full" >&2
    exit 1
fi

echo "=========================================================="
echo " Safe Hibernation Dry Run (mode: $MODE)"
echo "=========================================================="
echo " Steps:"
echo " 1. Set /sys/power/pm_test to '$MODE'"
echo " 2. Trigger kernel freeze via /sys/power/state"
echo " 3. Screen may blank for ~5 seconds during hardware freeze/thaw"
echo " 4. Automatic return to desktop (NO poweroff, NO image write)"
echo " 5. Reset /sys/power/pm_test to 'none'"
echo "=========================================================="

# Reset pm_test to none on exit
cleanup() {
    echo none > /sys/power/pm_test 2>/dev/null || true
    echo "==> Reset /sys/power/pm_test to none."
}
trap cleanup EXIT

echo "$MODE" > /sys/power/pm_test

# Sync filesystems before test
sync; sync

echo "==> Executing kernel freeze dry run..."
# Writing disk to /sys/power/state with pm_test != none causes the kernel to
# execute the freeze steps up to the selected level, wait 5s, and thaw without rebooting.
echo disk > /sys/power/state || {
    echo "==> Warning: Direct write to /sys/power/state returned $?"
}

echo "=========================================================="
echo " Test completed! Checking kernel log for NVIDIA / PM status:"
echo "=========================================================="
dmesg | tail -n 40 | grep -iE "nvidia|pci_pm_freeze|hibernation|PM:|nvAssert" || echo "No errors found."
