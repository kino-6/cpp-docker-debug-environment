#!/bin/bash

echo "=== Bare Metal QEMU Test Script ==="
echo "Building and testing the simplest possible ARM Cortex-M4 program"
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
ls -la build/bin/BareMetalTest.*
echo

echo "5. Analyzing ELF file..."
arm-none-eabi-size build/bin/BareMetalTest.elf
echo

echo "6. Starting Bare Metal QEMU Test..."
echo "   Target: STM32F407VG (QEMU netduinoplus2)"
echo "   Test: Bare metal with no library dependencies"
echo "   Timeout: 15 seconds"
echo "   Command: qemu-system-arm -M netduinoplus2 -cpu cortex-m4 -kernel build/bin/BareMetalTest.elf -nographic -semihosting-config enable=on,target=native"
echo "----------------------------------------"

# Run QEMU with timeout
timeout 15s qemu-system-arm \
    -M netduinoplus2 \
    -cpu cortex-m4 \
    -kernel build/bin/BareMetalTest.elf \
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
echo "=== Bare Metal Test Summary ==="
echo "If you saw test output above, semihosting is working correctly."
echo "Exit code 0 means the program completed and exited cleanly."
echo "Exit code 124 means timeout - the program is running but stuck in a loop."
echo "Any other exit code indicates an error condition."