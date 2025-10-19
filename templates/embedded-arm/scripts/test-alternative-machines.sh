#!/bin/bash

echo "=== Alternative QEMU Machine Test Script ==="
echo "Testing different QEMU machine types for ARM Cortex-M compatibility"
echo

# Navigate to integration tests
cd tests/integration

# Clean and build
echo "1. Cleaning previous build..."
rm -rf build
echo "   ✓ Build directory cleaned"

echo "2. Configuring CMake..."
cmake -B build -S . -G Ninja -DCMAKE_BUILD_TYPE=Debug
if [ $? -ne 0 ]; then
    echo "   ❌ CMake configuration failed"
    exit 1
fi
echo "   ✓ CMake configuration successful"

echo "3. Building project..."
cmake --build build --parallel
if [ $? -ne 0 ]; then
    echo "   ❌ Build failed"
    exit 1
fi
echo "   ✓ Build successful"

echo "4. Checking generated files..."
ls -la build/bin/DebugQemuTest.*
echo

echo "5. Testing different QEMU machine types..."
echo

# Test 1: mps2-an385 (ARM Cortex-M3)
echo "TEST 1: mps2-an385 (ARM Cortex-M3)"
echo "Command: qemu-system-arm -M mps2-an385 -cpu cortex-m3 -kernel build/bin/DebugQemuTest.elf -nographic -semihosting-config enable=on,target=native"
echo "----------------------------------------"
timeout 10s qemu-system-arm \
    -M mps2-an385 \
    -cpu cortex-m3 \
    -kernel build/bin/DebugQemuTest.elf \
    -nographic \
    -semihosting-config enable=on,target=native

EXIT_CODE_1=$?
echo "----------------------------------------"
echo "mps2-an385 exit code: $EXIT_CODE_1"
echo

# Test 2: mps2-an511 (ARM Cortex-M3)
echo "TEST 2: mps2-an511 (ARM Cortex-M3)"
echo "Command: qemu-system-arm -M mps2-an511 -cpu cortex-m3 -kernel build/bin/DebugQemuTest.elf -nographic -semihosting-config enable=on,target=native"
echo "----------------------------------------"
timeout 10s qemu-system-arm \
    -M mps2-an511 \
    -cpu cortex-m3 \
    -kernel build/bin/DebugQemuTest.elf \
    -nographic \
    -semihosting-config enable=on,target=native

EXIT_CODE_2=$?
echo "----------------------------------------"
echo "mps2-an511 exit code: $EXIT_CODE_2"
echo

# Test 3: netduinoplus2 (ARM Cortex-M4) - Original
echo "TEST 3: netduinoplus2 (ARM Cortex-M4) - Original"
echo "Command: qemu-system-arm -M netduinoplus2 -cpu cortex-m4 -kernel build/bin/DebugQemuTest.elf -nographic -semihosting-config enable=on,target=native"
echo "----------------------------------------"
timeout 10s qemu-system-arm \
    -M netduinoplus2 \
    -cpu cortex-m4 \
    -kernel build/bin/DebugQemuTest.elf \
    -nographic \
    -semihosting-config enable=on,target=native

EXIT_CODE_3=$?
echo "----------------------------------------"
echo "netduinoplus2 exit code: $EXIT_CODE_3"
echo

echo "=== Alternative Machine Test Summary ==="
echo "mps2-an385 (Cortex-M3):   Exit code $EXIT_CODE_1"
echo "mps2-an511 (Cortex-M3):   Exit code $EXIT_CODE_2"
echo "netduinoplus2 (Cortex-M4): Exit code $EXIT_CODE_3"
echo
echo "Exit code meanings:"
echo "  0   = Normal exit (semihosting exit worked)"
echo "  124 = Timeout (program running, may be in infinite loop)"
echo "  Other = Error condition"
echo
echo "The machine type with the best results should be used for future tests."