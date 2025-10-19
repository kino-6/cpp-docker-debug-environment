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
echo "4. Testing with QEMU (serial output to file)..."
echo "Command: qemu-system-arm -M netduinoplus2 -cpu cortex-m4 -kernel build/bin/UartOutputTest.elf -nographic -serial file:build/uart_output.log"
echo "----------------------------------------"

timeout 10s qemu-system-arm \
    -M netduinoplus2 \
    -cpu cortex-m4 \
    -kernel build/bin/UartOutputTest.elf \
    -nographic \
    -serial file:build/uart_output.log

echo "UART output log contents:"
if [ -f build/uart_output.log ]; then
    cat build/uart_output.log
    echo
    echo "✓ UART output captured to file"
else
    echo "❌ No UART output file created"
fi
echo "----------------------------------------"

echo
echo "5. Testing with different QEMU machine types..."

echo "5a. Testing with lm3s6965evb (Stellaris - has UART):"
timeout 5s qemu-system-arm \
    -M lm3s6965evb \
    -cpu cortex-m3 \
    -kernel build/bin/UartOutputTest.elf \
    -nographic 2>&1 | head -10

echo
echo "5b. Testing with mps2-an385 (ARM MPS2 - has UART):"
timeout 5s qemu-system-arm \
    -M mps2-an385 \
    -cpu cortex-m3 \
    -kernel build/bin/UartOutputTest.elf \
    -nographic 2>&1 | head -10

echo
echo "6. Testing with Renode (UART support)..."
cat > build/uart_renode.resc << 'EOF'
# UART Renode configuration
mach create "uart_test"

# Load STM32F4 platform (has UART support)
machine LoadPlatformDescription @platforms/boards/stm32f4_discovery-kit.repl

# Load UART test
sysbus LoadELF @build/bin/UartOutputTest.elf

# Set initial state
cpu PC `sysbus GetSymbolAddress "Reset_Handler"`
cpu SP 0x20020000

# Connect UART to console
connector Connect sysbus.usart2 Antmicro.Renode.Backends.Terminals.ServerSocketTerminal 3456

echo "=== UART Renode Test ==="
echo "UART output should appear on socket terminal (port 3456)"
start
sleep 5
pause
quit
EOF

echo "Command: renode --disable-xwt build/uart_renode.resc"
echo "----------------------------------------"

timeout 10s renode --disable-xwt build/uart_renode.resc

RENODE_EXIT_CODE=$?
echo "----------------------------------------"
echo "Renode exit code: $RENODE_EXIT_CODE"

echo
echo "=== UART Output Test Summary ==="
echo "QEMU test:        Exit code $QEMU_EXIT_CODE"
echo "Renode test:      Exit code $RENODE_EXIT_CODE"
echo
echo "This test uses:"
echo "- Direct UART register programming"
echo "- STM32F4 USART2 peripheral"
echo "- 115200 baud rate configuration"
echo "- No library dependencies"
echo
echo "Expected behavior:"
echo "- UART messages should appear in console or log file"
echo "- Heartbeat messages should continue indefinitely"
echo "- No semihosting dependencies"
echo
if [ -f build/uart_output.log ] && [ -s build/uart_output.log ]; then
    echo "✅ SUCCESS: UART output captured successfully"
    echo "   This proves the ARM code execution is working"
    echo "   Semihosting issue is likely QEMU/Renode configuration"
else
    echo "⚠️  PARTIAL: UART test completed but output capture needs verification"
    echo "   Try connecting to QEMU serial console manually"
fi