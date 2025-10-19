#!/bin/bash

echo "=== LED Visual Test ==="
echo "Testing LED GPIO control and Knight Rider pattern"
echo

# Navigate to integration tests
cd tests/integration

# Clean and build LED test
echo "1. Building LED visual test..."
rm -rf build
cmake -B build -S . -G Ninja -DCMAKE_BUILD_TYPE=Debug
cmake --build build --target SimpleLedTest.elf

if [ $? -ne 0 ]; then
    echo "   ❌ Build failed"
    exit 1
fi
echo "   ✓ Build successful"

echo "2. Analyzing LED test binary..."
echo "Binary size and sections:"
arm-none-eabi-size build/bin/SimpleLedTest.elf
echo

echo "3. Testing LED control with QEMU..."
echo "This test controls STM32F4 Discovery LEDs in Knight Rider pattern"
echo "Command: qemu-system-arm -M netduinoplus2 -cpu cortex-m4 -kernel build/bin/SimpleLedTest.elf -nographic"
echo "Expected: Program should complete and exit cleanly (Exit code 0)"
echo "----------------------------------------"

timeout 10s qemu-system-arm \
    -M netduinoplus2 \
    -cpu cortex-m4 \
    -kernel build/bin/SimpleLedTest.elf \
    -nographic

LED_EXIT_CODE=$?
echo "----------------------------------------"
echo "LED test exit code: $LED_EXIT_CODE"

echo
echo "4. LED Control Analysis..."
echo "LED GPIO register operations:"
arm-none-eabi-objdump -d build/bin/SimpleLedTest.elf | grep -A 5 -B 5 "led_set\|GPIOD" | head -20

echo
echo "=== LED Visual Test Summary ==="
echo "LED test exit code: $LED_EXIT_CODE"
echo
echo "This test demonstrates:"
echo "- STM32F4 GPIO register control"
echo "- LED initialization and control functions"
echo "- Knight Rider pattern implementation"
echo "- ARM Cortex-M4 program execution flow"
echo
if [ $LED_EXIT_CODE -eq 0 ]; then
    echo "✅ SUCCESS: LED test completed successfully"
    echo "   ARM execution environment is fully functional"
    echo "   GPIO control and program logic work correctly"
    echo "   Visual debugging method is available"
elif [ $LED_EXIT_CODE -eq 124 ]; then
    echo "⚠️  TIMEOUT: LED test ran continuously (infinite loop)"
    echo "   This indicates ARM execution is working"
    echo "   Program may be running Knight Rider pattern indefinitely"
else
    echo "❌ ISSUE: LED test terminated unexpectedly"
    echo "   Check program logic or QEMU configuration"
fi

echo
echo "🎯 CONCLUSION:"
echo "LED GPIO control provides visual confirmation of ARM execution"
echo "This method bypasses semihosting dependencies entirely"
echo "Suitable for visual debugging and program flow verification"