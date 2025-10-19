#!/bin/bash

echo "=== Minimal Semihosting Test Script ==="
echo "Testing the absolute simplest semihosting implementation"
echo

# Navigate to integration tests
cd tests/integration

# Clean and build
echo "1. Building minimal semihosting test..."
rm -rf build
cmake -B build -S . -G Ninja -DCMAKE_BUILD_TYPE=Debug
cmake --build build --parallel

if [ $? -ne 0 ]; then
    echo "   ❌ Build failed"
    exit 1
fi
echo "   ✓ Build successful"

echo "2. Analyzing minimal test binary..."
arm-none-eabi-size build/bin/MinimalSemihostTest.elf
echo

echo "3. Disassembling main function to verify semihosting calls..."
arm-none-eabi-objdump -d build/bin/MinimalSemihostTest.elf | grep -A 20 "<main>:"
echo

echo "4. Testing minimal semihosting with different QEMU options..."
echo

# Test 1: Standard semihosting
echo "TEST 1: Standard semihosting configuration"
echo "Command: qemu-system-arm -M netduinoplus2 -cpu cortex-m4 -kernel build/bin/MinimalSemihostTest.elf -nographic -semihosting-config enable=on,target=native"
echo "----------------------------------------"
timeout 5s qemu-system-arm \
    -M netduinoplus2 \
    -cpu cortex-m4 \
    -kernel build/bin/MinimalSemihostTest.elf \
    -nographic \
    -semihosting-config enable=on,target=native
echo "Exit code: $?"
echo

# Test 2: Legacy semihosting
echo "TEST 2: Legacy semihosting option"
echo "Command: qemu-system-arm -M netduinoplus2 -cpu cortex-m4 -kernel build/bin/MinimalSemihostTest.elf -nographic -semihosting"
echo "----------------------------------------"
timeout 5s qemu-system-arm \
    -M netduinoplus2 \
    -cpu cortex-m4 \
    -kernel build/bin/MinimalSemihostTest.elf \
    -nographic \
    -semihosting
echo "Exit code: $?"
echo

# Test 3: Different machine type
echo "TEST 3: Different machine type (mps2-an385)"
echo "Command: qemu-system-arm -M mps2-an385 -cpu cortex-m3 -kernel build/bin/MinimalSemihostTest.elf -nographic -semihosting"
echo "----------------------------------------"
timeout 5s qemu-system-arm \
    -M mps2-an385 \
    -cpu cortex-m3 \
    -kernel build/bin/MinimalSemihostTest.elf \
    -nographic \
    -semihosting
echo "Exit code: $?"
echo

echo "=== Minimal Test Summary ==="
echo "This test uses the simplest possible semihosting implementation:"
echo "- Direct assembly with bkpt #0xAB"
echo "- SYS_WRITE0 (4) for string output"
echo "- SYS_EXIT (24) for program termination"
echo
echo "If none of these tests show output, there may be a fundamental"
echo "issue with QEMU semihosting support or the ARM binary format."