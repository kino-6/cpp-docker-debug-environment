#!/bin/bash

echo "=== Basic QEMU Test Script ==="
echo "Testing basic ARM execution without semihosting"
echo

# Navigate to integration tests
cd tests/integration

# Clean and build
echo "1. Building basic ARM test..."
rm -rf build
cmake -B build -S . -G Ninja -DCMAKE_BUILD_TYPE=Debug
cmake --build build --parallel

if [ $? -ne 0 ]; then
    echo "   ❌ Build failed"
    exit 1
fi
echo "   ✓ Build successful"

echo "2. Checking QEMU installation and version..."
which qemu-system-arm
qemu-system-arm --version | head -3
echo

echo "3. Listing available ARM machines..."
qemu-system-arm -M help | grep -E "(netduino|mps2|cortex)" | head -5
echo

echo "4. Analyzing basic test binary..."
echo "Binary size:"
arm-none-eabi-size build/bin/NoSemihostTest.elf
echo
echo "Entry point and sections:"
arm-none-eabi-objdump -h build/bin/NoSemihostTest.elf | head -10
echo

echo "5. Testing basic ARM execution (no semihosting)..."
echo "Command: qemu-system-arm -M netduinoplus2 -cpu cortex-m4 -kernel build/bin/NoSemihostTest.elf -nographic"
echo "This test should run ARM code and timeout (expected behavior)"
echo "----------------------------------------"
timeout 3s qemu-system-arm \
    -M netduinoplus2 \
    -cpu cortex-m4 \
    -kernel build/bin/NoSemihostTest.elf \
    -nographic

BASIC_EXIT_CODE=$?
echo "----------------------------------------"
echo "Basic test exit code: $BASIC_EXIT_CODE"

if [ $BASIC_EXIT_CODE -eq 124 ]; then
    echo "   ✅ Basic ARM execution is working (timeout as expected)"
    echo "   This confirms QEMU can execute ARM Cortex-M4 code"
elif [ $BASIC_EXIT_CODE -eq 0 ]; then
    echo "   ⚠️  Program exited normally (unexpected for infinite loop)"
else
    echo "   ❌ QEMU failed to execute ARM code (exit code: $BASIC_EXIT_CODE)"
fi

echo
echo "6. Testing with different machine types..."

echo "Testing mps2-an385 (Cortex-M3):"
timeout 2s qemu-system-arm \
    -M mps2-an385 \
    -cpu cortex-m3 \
    -kernel build/bin/NoSemihostTest.elf \
    -nographic \
    2>/dev/null
echo "mps2-an385 exit code: $?"

echo "Testing mps2-an511 (Cortex-M3):"
timeout 2s qemu-system-arm \
    -M mps2-an511 \
    -cpu cortex-m3 \
    -kernel build/bin/NoSemihostTest.elf \
    -nographic \
    2>/dev/null
echo "mps2-an511 exit code: $?"

echo
echo "=== Basic Test Summary ==="
echo "This test verifies basic QEMU ARM execution without semihosting."
echo "If the basic test shows exit code 124 (timeout), QEMU is working."
echo "If it shows other codes, there may be fundamental QEMU issues."
echo
echo "Next step: If basic execution works, the problem is specifically"
echo "with semihosting configuration or implementation."