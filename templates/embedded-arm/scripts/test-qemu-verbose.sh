#!/bin/bash

echo "=== Verbose QEMU Test Script ==="
echo "Testing QEMU with detailed debug output"
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

echo "4. Checking QEMU version and capabilities..."
qemu-system-arm --version
echo

echo "5. Listing available QEMU machines..."
qemu-system-arm -M help | grep -E "(netduino|mps2|cortex)"
echo

echo "6. Testing QEMU with verbose debug output..."
echo "   Command: qemu-system-arm -M netduinoplus2 -cpu cortex-m4 -kernel build/bin/FixedQemuTest.elf -nographic -semihosting-config enable=on,target=native -d guest_errors,unimp,trace:semihosting*"
echo "   Timeout: 10 seconds"
echo "----------------------------------------"

# Run QEMU with verbose debug output
timeout 10s qemu-system-arm \
    -M netduinoplus2 \
    -cpu cortex-m4 \
    -kernel build/bin/FixedQemuTest.elf \
    -nographic \
    -semihosting-config enable=on,target=native \
    -d guest_errors,unimp \
    2>&1

QEMU_EXIT_CODE=$?
echo "----------------------------------------"
echo "QEMU exit code: $QEMU_EXIT_CODE"

echo
echo "7. Testing with different semihosting configuration..."
echo "   Command: qemu-system-arm -M netduinoplus2 -cpu cortex-m4 -kernel build/bin/FixedQemuTest.elf -nographic -semihosting-config enable=on"
echo "   Timeout: 10 seconds"
echo "----------------------------------------"

timeout 10s qemu-system-arm \
    -M netduinoplus2 \
    -cpu cortex-m4 \
    -kernel build/bin/FixedQemuTest.elf \
    -nographic \
    -semihosting-config enable=on \
    2>&1

QEMU_EXIT_CODE2=$?
echo "----------------------------------------"
echo "QEMU exit code: $QEMU_EXIT_CODE2"

echo
echo "8. Testing with legacy semihosting option..."
echo "   Command: qemu-system-arm -M netduinoplus2 -cpu cortex-m4 -kernel build/bin/FixedQemuTest.elf -nographic -semihosting"
echo "   Timeout: 10 seconds"
echo "----------------------------------------"

timeout 10s qemu-system-arm \
    -M netduinoplus2 \
    -cpu cortex-m4 \
    -kernel build/bin/FixedQemuTest.elf \
    -nographic \
    -semihosting \
    2>&1

QEMU_EXIT_CODE3=$?
echo "----------------------------------------"
echo "QEMU exit code: $QEMU_EXIT_CODE3"

echo
echo "=== Verbose Test Summary ==="
echo "Test 1 (target=native):  Exit code $QEMU_EXIT_CODE"
echo "Test 2 (enable=on):      Exit code $QEMU_EXIT_CODE2"
echo "Test 3 (legacy):         Exit code $QEMU_EXIT_CODE3"
echo
echo "This test helps identify:"
echo "1. QEMU version and machine compatibility"
echo "2. Semihosting configuration issues"
echo "3. Debug output from QEMU execution"
echo "4. Different semihosting option behaviors"