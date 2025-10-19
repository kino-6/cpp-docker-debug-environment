#!/bin/bash

echo "=== QEMU Debug Script ==="
echo "Building and testing QEMU execution with detailed diagnostics"
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
ls -la build/bin/
echo

echo "5. Analyzing ELF file..."
arm-none-eabi-size build/bin/MinimalQemuTest.elf
echo
arm-none-eabi-objdump -h build/bin/MinimalQemuTest.elf | head -20
echo

echo "6. Testing QEMU execution with verbose output..."
echo "   Command: qemu-system-arm -M netduinoplus2 -cpu cortex-m4 -kernel build/bin/MinimalQemuTest.elf -nographic -semihosting-config enable=on,target=native -d guest_errors,unimp"
echo "   Timeout: 15 seconds"
echo "   Starting QEMU..."
echo "----------------------------------------"

# Run QEMU with debug output and timeout
timeout 15s qemu-system-arm \
    -M netduinoplus2 \
    -cpu cortex-m4 \
    -kernel build/bin/MinimalQemuTest.elf \
    -nographic \
    -semihosting-config enable=on,target=native \
    -d guest_errors,unimp

QEMU_EXIT_CODE=$?
echo "----------------------------------------"
echo "QEMU exit code: $QEMU_EXIT_CODE"

if [ $QEMU_EXIT_CODE -eq 124 ]; then
    echo "   ⚠️  QEMU timed out (15 seconds) - this may be normal if the program is running"
elif [ $QEMU_EXIT_CODE -eq 0 ]; then
    echo "   ✓ QEMU exited normally"
else
    echo "   ❌ QEMU exited with error code $QEMU_EXIT_CODE"
fi

echo
echo "7. Alternative test with SimpleQemuTest..."
echo "   Command: qemu-system-arm -M netduinoplus2 -cpu cortex-m4 -kernel build/bin/SimpleQemuTest.elf -nographic -semihosting-config enable=on,target=native"
echo "   Timeout: 10 seconds"
echo "----------------------------------------"

timeout 10s qemu-system-arm \
    -M netduinoplus2 \
    -cpu cortex-m4 \
    -kernel build/bin/SimpleQemuTest.elf \
    -nographic \
    -semihosting-config enable=on,target=native

QEMU_EXIT_CODE2=$?
echo "----------------------------------------"
echo "SimpleQemuTest exit code: $QEMU_EXIT_CODE2"

echo
echo "8. Testing WorkingQemuTest with direct semihosting..."
echo "   Command: qemu-system-arm -M netduinoplus2 -cpu cortex-m4 -kernel build/bin/WorkingQemuTest.elf -nographic -semihosting-config enable=on,target=native"
echo "   Timeout: 15 seconds"
echo "----------------------------------------"

timeout 15s qemu-system-arm \
    -M netduinoplus2 \
    -cpu cortex-m4 \
    -kernel build/bin/WorkingQemuTest.elf \
    -nographic \
    -semihosting-config enable=on,target=native

QEMU_EXIT_CODE3=$?
echo "----------------------------------------"
echo "WorkingQemuTest exit code: $QEMU_EXIT_CODE3"

echo
echo "=== QEMU Debug Summary ==="
echo "MinimalQemuTest:  Exit code $QEMU_EXIT_CODE"
echo "SimpleQemuTest:   Exit code $QEMU_EXIT_CODE2"
echo "WorkingQemuTest:  Exit code $QEMU_EXIT_CODE3"
echo
echo "Exit code meanings:"
echo "  0   = Normal exit (semihosting exit worked)"
echo "  124 = Timeout (program running, infinite loop)"
echo "  Other = Error condition"
echo
echo "If you see printf output above, semihosting is working correctly."
echo "If WorkingQemuTest shows exit code 0, semihosting exit is functional."