#!/bin/bash

echo "=== Debug QEMU Test Script ==="
echo "Building and testing ARM Cortex-M4 program with step-by-step tracking"
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

echo "5. Analyzing ELF file..."
arm-none-eabi-size build/bin/DebugQemuTest.elf
echo

echo "6. Starting Debug QEMU Test..."
echo "   Target: STM32F407VG (QEMU netduinoplus2)"
echo "   Test: Step-by-step execution tracking"
echo "   Timeout: 30 seconds"
echo "   Command: qemu-system-arm -M netduinoplus2 -cpu cortex-m4 -kernel build/bin/DebugQemuTest.elf -nographic -semihosting-config enable=on,target=native"
echo "----------------------------------------"

# Run QEMU with timeout
timeout 30s qemu-system-arm \
    -M netduinoplus2 \
    -cpu cortex-m4 \
    -kernel build/bin/DebugQemuTest.elf \
    -nographic \
    -semihosting-config enable=on,target=native

QEMU_EXIT_CODE=$?
echo "----------------------------------------"
echo "QEMU exit code: $QEMU_EXIT_CODE"

if [ $QEMU_EXIT_CODE -eq 0 ]; then
    echo "   ✅ QEMU exited normally (semihosting exit worked!)"
elif [ $QEMU_EXIT_CODE -eq 124 ]; then
    echo "   ⚠️  QEMU timed out (program may be running in infinite loop)"
else
    echo "   ❌ QEMU exited with error code $QEMU_EXIT_CODE"
fi

echo
echo "=== Debug Test Summary ==="
echo "This test provides detailed step-by-step execution tracking."
echo "If you saw STEP 1, STEP 2, etc. output above, the program is executing correctly."
echo "Each step tests different aspects of ARM Cortex-M4 execution."