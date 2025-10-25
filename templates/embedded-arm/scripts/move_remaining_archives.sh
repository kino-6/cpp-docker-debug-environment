#!/bin/bash

echo "=== Moving Remaining Archive Scripts ==="

# Scripts to archive (diagnostic and experimental)
SCRIPTS_TO_ARCHIVE=(
    "test-basic-qemu.sh"
    "test-fixed-qemu.sh"
    "test-qemu-verbose.sh"
    "test-bare-metal-qemu.sh"
    "test-debug-qemu.sh"
    "debug-qemu.sh"
    "test-cortex-m-semihost.sh"
    "test-minimal-semihost.sh"
    "test-alternative-machines.sh"
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

# Move each script
for script in "${SCRIPTS_TO_ARCHIVE[@]}"; do
    if [ -f "$script" ]; then
        echo "Archiving: $script"
        cp "$script" "archive/"
        rm "$script"
    fi
done

echo
echo "=== Archive Summary ==="
echo "Archived scripts: $(ls archive/*.sh | wc -l)"
echo
echo "Active scripts remaining:"
ls -1 *.sh | grep -v "move_remaining_archives.sh" | grep -v "archive_scripts.sh"