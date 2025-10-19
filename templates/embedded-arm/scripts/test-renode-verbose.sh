#!/bin/bash

echo "=== Verbose Renode Test Script ==="
echo "Testing Renode with detailed output and semihosting"
echo

# Navigate to integration tests
cd tests/integration

# Build simple test
echo "1. Building simple test..."
rm -rf build
cmake -B build -S . -G Ninja -DCMAKE_BUILD_TYPE=Debug
cmake --build build --target SimpleWorkingTest.elf

if [ $? -ne 0 ]; then
    echo "   ❌ Build failed"
    exit 1
fi
echo "   ✓ Build successful"

echo "2. Analyzing binary..."
arm-none-eabi-size build/bin/SimpleWorkingTest.elf
echo

echo "3. Creating verbose Renode test with semihosting..."
cat > build/verbose_renode.resc << 'EOF'
# Verbose Renode test with semihosting
mach create "stm32f407"

# Load STM32F4 Discovery platform
machine LoadPlatformDescription @platforms/boards/stm32f4_discovery-kit.repl

# Enable detailed logging
logLevel 0

# Enable semihosting
sysbus.cpu EnableProfiler "Antmicro.Renode.Analyzers.SemihostingAnalyzer"

# Load binary
sysbus LoadELF @build/bin/SimpleWorkingTest.elf

# Set initial state
cpu PC `sysbus GetSymbolAddress "Reset_Handler"`
cpu SP 0x20020000

# Show initial state
echo "=== Initial CPU State ==="
cpu

# Start execution with monitoring
echo "=== Starting Execution ==="
start

# Let it run for a bit
sleep 2

# Check CPU state
echo "=== CPU State After 2 seconds ==="
cpu

# Continue for a bit more
sleep 3

# Final state
echo "=== Final CPU State ==="
cpu

# Show any semihosting output
echo "=== Semihosting Analysis ==="

pause
echo "Renode verbose test completed"
quit
EOF

echo "4. Running verbose Renode test..."
echo "Command: renode --disable-xwt build/verbose_renode.resc"
echo "----------------------------------------"

timeout 15s renode --disable-xwt build/verbose_renode.resc

RENODE_EXIT_CODE=$?
echo "----------------------------------------"
echo "Verbose Renode exit code: $RENODE_EXIT_CODE"

echo
echo "5. Testing with different semihosting configuration..."
cat > build/semihost_renode.resc << 'EOF'
# Semihosting-focused Renode test
mach create "stm32f407"

# Load platform
machine LoadPlatformDescription @platforms/boards/stm32f4_discovery-kit.repl

# Set logging level for semihosting
logLevel 1

# Enable semihosting with explicit configuration
sysbus.cpu EnableProfiler "Antmicro.Renode.Analyzers.SemihostingAnalyzer"

# Create a terminal for semihosting output
emulation CreateServerSocketTerminal 3456 "semihost_terminal"

# Load binary
sysbus LoadELF @build/bin/SimpleWorkingTest.elf

# Set initial state
cpu PC `sysbus GetSymbolAddress "Reset_Handler"`
cpu SP 0x20020000

echo "=== Semihosting Test Starting ==="
echo "Monitor semihosting output on terminal"

# Start execution
start

# Run for 5 seconds
sleep 5

echo "=== Semihosting Test Completed ==="
pause
quit
EOF

echo "Running semihosting-focused test..."
echo "Command: renode --disable-xwt build/semihost_renode.resc"
echo "----------------------------------------"

timeout 10s renode --disable-xwt build/semihost_renode.resc

SEMIHOST_EXIT_CODE=$?
echo "----------------------------------------"
echo "Semihosting test exit code: $SEMIHOST_EXIT_CODE"

echo
echo "=== Verbose Renode Test Summary ==="
echo "Verbose test exit code: $RENODE_EXIT_CODE"
echo "Semihosting test exit code: $SEMIHOST_EXIT_CODE"
echo
echo "This test provides detailed information about:"
echo "- CPU state during execution"
echo "- Semihosting analyzer status"
echo "- Execution flow monitoring"
echo
echo "If you see CPU state changes above, Renode is executing the program."
echo "If semihosting output is missing, it may need different configuration."