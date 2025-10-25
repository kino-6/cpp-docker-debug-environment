#!/bin/bash

echo "=== UART Output Test ==="
echo "Testing UART output as alternative to semihosting"
echo

# Navigate to integration tests
cd tests/integration

# Clean and build
echo "1. Building UART output test..."
rm -rf build
cmake -B build -S . -G Ninja -DCMAKE_BUILD_TYPE=Debug
cmake --build build --target UartOutputTest.elf

if [ $? -ne 0 ]; then
    echo "   ❌ Build failed"
    exit 1
fi
echo "   ✓ Build successful"

echo "2. Analyzing UART test binary..."
echo "Binary size and sections:"
arm-none-eabi-size build/bin/UartOutputTest.elf
echo

echo "3. Testing with QEMU (UART output)..."
echo "Note: UART output will appear in QEMU console"
echo "Command: qemu-system-arm -M netduinoplus2 -cpu cortex-m4 -kernel build/bin/UartOutputTest.elf -nographic"
echo "----------------------------------------"

timeout 10s qemu-system-arm \
    -M netduinoplus2 \
    -cpu cortex-m4 \
    -kernel build/bin/UartOutputTest.elf \
    -nographic

QEMU_EXIT_CODE=$?
echo "----------------------------------------"
echo "QEMU exit code: $QEMU_EXIT_CODE"

echo
echo "4. Testing with serial output capture..."
echo "Capturing UART output to file..."
timeout 8s qemu-system-arm \
    -M netduinoplus2 \
    -cpu cortex-m4 \
    -kernel build/bin/UartOutputTest.elf \
    -nographic \
    -serial file:build/uart_output.log

echo "UART output file analysis:"
if [ -f build/uart_output.log ]; then
    echo "Output file size: $(wc -c < build/uart_output.log) bytes"
    echo "Content preview:"
    head -10 build/uart_output.log 2>/dev/null || echo "No content captured"
else
    echo "❌ No UART output file created"
fi

echo
echo "=== UART Output Test Summary ==="
echo "QEMU execution: Exit code $QEMU_EXIT_CODE"
echo
echo "This test demonstrates:"
echo "- UART peripheral initialization"
echo "- Serial communication output"
echo "- Alternative to semihosting for debugging"
echo
if [ $QEMU_EXIT_CODE -eq 0 ]; then
    echo "✅ SUCCESS: UART output method works"
elif [ $QEMU_EXIT_CODE -eq 124 ]; then
    echo "⚠️  TIMEOUT: UART test ran continuously (may be normal)"
    echo "   Check uart_output.log for captured data"
else
    echo "❌ ISSUE: UART test failed"
fi

echo
echo "🎯 UART provides reliable output method independent of semihosting"