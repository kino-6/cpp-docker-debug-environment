#!/bin/bash

echo "=== Fixed QEMU Test Script ==="
echo "Testing comprehensive semihosting implementation"
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
ls -la build/bin/FixedQemuTest.*
echo

echo "5. Analyzing ELF file..."
arm-none-eabi-size build/bin/FixedQemuTest.elf
echo

echo "6. Starting Fixed QEMU Test..."
echo "   Target: STM32F407VG (QEMU netduinoplus2)"
echo "   Test: Comprehensive semihosting (SYS_WRITE0, SYS_WRITEC, SYS_WRITE)"
echo "   Timeout: 20 seconds"
echo "   Command: qemu-system-arm -M netduinoplus2 -cpu cortex-m4 -kernel build/bin/FixedQemuTest.elf -nographic -semihosting-config enable=on,target=native"
echo "----------------------------------------"

# Run QEMU with timeout
timeout 20s qemu-system-arm \
    -M netduinoplus2 \
    -cpu cortex-m4 \
    -kernel build/bin/FixedQemuTest.elf \
    -nographic \
    -semihosting-config enable=on,target=native

QEMU_EXIT_CODE=$?
echo "----------------------------------------"
echo "QEMU exit code: $QEMU_EXIT_CODE"

if [ $QEMU_EXIT_CODE -eq 0 ]; then
    echo "   ✅ QEMU exited normally (semihosting exit worked perfectly!)"
    echo "   🎉 This means the program completed successfully and exited cleanly."
elif [ $QEMU_EXIT_CODE -eq 124 ]; then
    echo "   ⚠️  QEMU timed out after 20 seconds"
    echo "   This could mean:"
    echo "   - Program is running but stuck in infinite loop"
    echo "   - Semihosting output is not working properly"
    echo "   - Program is executing but exit call failed"
else
    echo "   ❌ QEMU exited with error code $QEMU_EXIT_CODE"
    echo "   This indicates a problem with QEMU execution or the program."
fi

echo
echo "=== Fixed Test Analysis ==="
echo "This test uses three different semihosting methods:"
echo "1. SYS_WRITE0 - Write null-terminated string"
echo "2. SYS_WRITEC - Write single character"
echo "3. SYS_WRITE  - Write to file descriptor (stdout)"
echo
echo "If you saw test output above, at least one semihosting method is working."
echo "If QEMU exited with code 0, the semihosting exit call is also functional."
echo
echo "Expected output should include:"
echo "- Method 1, 2, 3 working messages"
echo "- Basic test results (PASSED/FAILED)"
echo "- Countdown sequence"
echo "- Clean exit message"