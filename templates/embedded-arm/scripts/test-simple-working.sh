#!/bin/bash

echo "=== Simple Working Test Script ==="
echo "Testing the most basic semihosting implementation"
echo

# Navigate to integration tests
cd tests/integration

# Clean and build
echo "1. Building simple working test..."
rm -rf build
cmake -B build -S . -G Ninja -DCMAKE_BUILD_TYPE=Debug
cmake --build build --target SimpleWorkingTest.elf

if [ $? -ne 0 ]; then
    echo "   ❌ Build failed"
    exit 1
fi
echo "   ✓ Build successful"

echo "2. Analyzing simple test binary..."
arm-none-eabi-size build/bin/SimpleWorkingTest.elf
echo

echo "3. Testing simple semihosting..."
echo "Command: qemu-system-arm -M netduinoplus2 -cpu cortex-m4 -kernel build/bin/SimpleWorkingTest.elf -nographic -semihosting"
echo "Timeout: 10 seconds"
echo "----------------------------------------"

timeout 10s qemu-system-arm \
    -M netduinoplus2 \
    -cpu cortex-m4 \
    -kernel build/bin/SimpleWorkingTest.elf \
    -nographic \
    -semihosting

SIMPLE_EXIT_CODE=$?
echo "----------------------------------------"
echo "Simple test exit code: $SIMPLE_EXIT_CODE"

if [ $SIMPLE_EXIT_CODE -eq 0 ]; then
    echo "   ✅ SUCCESS! Semihosting is working and program exited cleanly!"
    echo "   This means the semihosting exit call worked perfectly."
elif [ $SIMPLE_EXIT_CODE -eq 124 ]; then
    echo "   ⚠️  TIMEOUT: Program is running but may be stuck in loop"
    echo "   Check if you saw any output above."
else
    echo "   ❌ ERROR: QEMU failed with exit code $SIMPLE_EXIT_CODE"
fi

echo
echo "=== Simple Test Summary ==="
echo "This is the most basic possible semihosting test."
echo "If this doesn't work, there's a fundamental issue with:"
echo "1. QEMU semihosting support"
echo "2. ARM binary format"
echo "3. QEMU installation or configuration"
echo
echo "Expected output should include:"
echo "- 'Hello from ARM Cortex-M4!'"
echo "- 'semihosting is working!'"
echo "- 'Math test: PASSED'"
echo "- 'Test completed successfully!'"