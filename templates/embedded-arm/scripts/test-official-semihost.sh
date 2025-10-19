#!/bin/bash

echo "=== ARM Official Semihosting Test ==="
echo "Testing with ARM official semihosting sample and configuration"
echo

# Navigate to integration tests
cd tests/integration

# Clean and build
echo "1. Building ARM official semihosting sample..."
rm -rf build
cmake -B build -S . -G Ninja -DCMAKE_BUILD_TYPE=Debug
cmake --build build --target SimpleOfficialSample.elf

if [ $? -ne 0 ]; then
    echo "   ❌ Build failed"
    exit 1
fi
echo "   ✓ Build successful"

echo "2. Analyzing official sample binary..."
echo "Binary size and sections:"
arm-none-eabi-size build/bin/SimpleOfficialSample.elf
echo
echo "Checking semihosting implementation:"
arm-none-eabi-objdump -d build/bin/SimpleOfficialSample.elf | grep -A 2 -B 2 "bkpt" | head -10
echo

echo "3. Testing with QEMU (ARM official approach)..."
echo "Command: qemu-system-arm -M netduinoplus2 -cpu cortex-m4 -kernel build/bin/SimpleOfficialSample.elf -nographic -semihosting"
echo "Timeout: 10 seconds"
echo "----------------------------------------"

timeout 10s qemu-system-arm \
    -M netduinoplus2 \
    -cpu cortex-m4 \
    -kernel build/bin/SimpleOfficialSample.elf \
    -nographic \
    -semihosting

QEMU_EXIT_CODE=$?
echo "----------------------------------------"
echo "QEMU exit code: $QEMU_EXIT_CODE"

echo
echo "4. Testing with Renode (ARM official approach)..."
cat > build/official_renode.resc << 'EOF'
# ARM Official Renode configuration
mach create "official_test"

# Load STM32F4 platform
machine LoadPlatformDescription @platforms/boards/stm32f4_discovery-kit.repl

# Enable semihosting
sysbus.cpu EnableProfiler "Antmicro.Renode.Analyzers.SemihostingAnalyzer"

# Load official sample
sysbus LoadELF @build/bin/SimpleOfficialSample.elf

# Set initial state
cpu PC `sysbus GetSymbolAddress "Reset_Handler"`
cpu SP 0x20020000

echo "=== ARM Official Renode Test ==="
start
sleep 3
pause
quit
EOF

echo "Command: renode --disable-xwt build/official_renode.resc"
echo "----------------------------------------"

timeout 10s renode --disable-xwt build/official_renode.resc

RENODE_EXIT_CODE=$?
echo "----------------------------------------"
echo "Renode exit code: $RENODE_EXIT_CODE"

echo
echo "5. Alternative QEMU configurations..."

echo "Testing with different semihosting options:"
echo "a) Legacy semihosting:"
timeout 5s qemu-system-arm -M netduinoplus2 -cpu cortex-m4 -kernel build/bin/OfficialSemihostSample.elf -nographic -semihosting 2>&1 | head -10

echo "b) Semihosting with target=native:"
timeout 5s qemu-system-arm -M netduinoplus2 -cpu cortex-m4 -kernel build/bin/SimpleOfficialSample.elf -nographic -semihosting-config enable=on,target=native 2>&1 | head -10

echo "c) Different machine type (mps2-an385):"
timeout 5s qemu-system-arm -M mps2-an385 -cpu cortex-m3 -kernel build/bin/SimpleOfficialSample.elf -nographic -semihosting 2>&1 | head -10

echo
echo "=== Official Semihosting Test Summary ==="
echo "QEMU test:   Exit code $QEMU_EXIT_CODE"
echo "Renode test: Exit code $RENODE_EXIT_CODE"
echo
echo "This test uses:"
echo "- ARM official semihosting sample code"
echo "- ARM official linker script"
echo "- rdimon.specs for proper semihosting support"
echo "- Standard ARM Cortex-M4 vector table"
echo
echo "Expected behavior:"
echo "- printf output should be visible"
echo "- exit(0) should terminate cleanly"
echo "- Both QEMU and Renode should show output"