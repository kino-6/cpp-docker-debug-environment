#!/bin/bash

echo "=== Archiving Development Scripts ==="
echo "Moving diagnostic and experimental scripts to archive/"

# List of scripts to archive
ARCHIVE_SCRIPTS=(
    "test-basic-qemu.sh"
    "test-fixed-qemu.sh"
    "test-qemu-verbose.sh"
    "test-bare-metal-qemu.sh"
    "test-debug-qemu.sh"
    "debug-qemu.sh"
    "test-cortex-m-semihost.sh"
    "test-minimal-semihost.sh"
    "test-alternative-machines.sh"
    "test-alternative-outputs.sh"
    "test-uart-output.sh"
    "test-simple-working.sh"
    "test-in-basic-container.sh"
    "test-in-qemu.sh"
    "test-renode-simple.sh"
    "test-renode-verbose.sh"
    "test-renode-correct.sh"
    "install-renode.sh"
    "check-renode-docs.sh"
    "try-official-renode-docker.sh"
)

# Create archive directory if it doesn't exist
mkdir -p archive

# Move scripts to archive
for script in "${ARCHIVE_SCRIPTS[@]}"; do
    if [ -f "$script" ]; then
        echo "Moving: $script"
        mv "$script" "archive/"
    else
        echo "Not found: $script"
    fi
done

echo
echo "=== Archive Complete ==="
echo "Archived $(ls archive/*.sh | wc -l) scripts"
echo
echo "Remaining active scripts:"
ls -1 *.sh | grep -v archive_scripts.sh