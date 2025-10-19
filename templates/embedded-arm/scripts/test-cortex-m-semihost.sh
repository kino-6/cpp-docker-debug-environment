#!/bin/bash

echo "=== Cortex-M Semihosting Test Script ==="
echo "Testing ARM Cortex-M specific semihosting implementation"
echo

# Navigate to integration tests
cd tests/integration

# Clean and build
echo "1. Building Cortex-M semihosting test..."
rm -rf build
cmake -B build -S . -G Ninja -DCMAKE_BUILD_TYPE=Debug
cmake --build build --parallel

if [ $? -ne 0 ]; then
    echo "   ❌ Build failed"
    exit 1
fi
echo "   ✓ Build successful"

echo "2. Analyzing Cortex-M test binary..."
echo "Binary size and sections:"
arm-none-eabi-size build/bin/CortexMSemihostTest.elf
echo
echo "Vector table (first 64 bytes):"
arm-none-eabi-objdump -s -j .isr_vector build/bin/CortexMSemihostTest.elf
echo

echo "3. Disassembling semihosting calls..."
echo "BKPT instructions:"
arm-none-eabi-objdump -d build/bin/CortexMSemihostTest.elf | grep -A 2 -B 2 "bkpt"
echo
echo "SVC instructions:"
arm-none-eabi-objdump -d build/bin/CortexMSemihostTest.elf | grep -A 2 -B 2 "svc"
echo

echo "4. Testing Cortex-M semihosting with different configurations..."
echo

# Test 1: Standard configuration
echo "TEST 1: Standard semihosting (netduinoplus2)"
echo "Command: qemu-system-arm -M netduinoplus2 -cpu cortex-m4 -kernel build/bin/CortexMSemihostTest.elf -nographic -semihosting-config enable=on,target=native"
echo "----------------------------------------"
timeout 8s qemu-system-arm \
    -M netduinoplus2 \
    -cpu cortex-m4 \
    -kernel build/bin/CortexMSemihostTest.elf \
    -nographic \
    -semihosting-config enable=on,target=native
echo "Exit code: $?"
echo

# Test 2: Legacy semihosting
echo "TEST 2: Legacy semihosting (netduinoplus2)"
echo "Command: qemu-system-arm -M netduinoplus2 -cpu cortex-m4 -kernel build/bin/CortexMSemihostTest.elf -nographic -semihosting"
echo "----------------------------------------"
timeout 8s qemu-system-arm \
    -M netduinoplus2 \
    -cpu cortex-m4 \
    -kernel build/bin/CortexMSemihostTest.elf \
    -nographic \
    -semihosting
echo "Exit code: $?"
echo

# Test 3: MPS2 board (known to work well with semihosting)
echo "TEST 3: MPS2-AN385 board (Cortex-M3)"
echo "Command: qemu-system-arm -M mps2-an385 -cpu cortex-m3 -kernel build/bin/CortexMSemihostTest.elf -nographic -semihosting"
echo "----------------------------------------"
timeout 8s qemu-system-arm \
    -M mps2-an385 \
    -cpu cortex-m3 \
    -kernel build/bin/CortexMSemihostTest.elf \
    -nographic \
    -semihosting
echo "Exit code: $?"
echo

# Test 4: With debug output
echo "TEST 4: With QEMU debug output"
echo "Command: qemu-system-arm -M netduinoplus2 -cpu cortex-m4 -kernel build/bin/CortexMSemihostTest.elf -nographic -semihosting -d guest_errors"
echo "----------------------------------------"
timeout 5s qemu-system-arm \
    -M netduinoplus2 \
    -cpu cortex-m4 \
    -kernel build/bin/CortexMSemihostTest.elf \
    -nographic \
    -semihosting \
    -d guest_errors 2>&1
echo "Exit code: $?"
echo

echo "=== Cortex-M Test Summary ==="
echo "This test uses ARM Cortex-M specific features:"
echo "- Complete vector table with proper entries"
echo "- Cortex-M register initialization"
echo "- Both BKPT and SVC semihosting methods"
echo "- WFI instruction for low-power loop"
echo
echo "If any test shows output, that configuration works."
echo "If all tests timeout without output, there may be a"
echo "fundamental issue with QEMU semihosting support."