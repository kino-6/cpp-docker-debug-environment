#!/bin/bash

echo "=== Correct Renode Configuration Test ==="
echo "Using proper platform files and semihosting configuration"
echo

# Navigate to integration tests
cd tests/integration

# Build test
echo "1. Building test binary..."
rm -rf build
cmake -B build -S . -G Ninja -DCMAKE_BUILD_TYPE=Debug
cmake --build build --target SimpleWorkingTest.elf

if [ $? -ne 0 ]; then
    echo "   ❌ Build failed"
    exit 1
fi
echo "   ✓ Build successful"

echo "2. Finding correct STM32F4 platform files..."
PLATFORM_FILE=""

# Search for STM32F4 platform files
for path in /opt/renode /usr/share/renode /usr/local/share/renode; do
    if [ -f "$path/platforms/boards/stm32f4_discovery-kit.repl" ]; then
        PLATFORM_FILE="@platforms/boards/stm32f4_discovery-kit.repl"
        echo "   ✅ Found STM32F4 platform: $path/platforms/boards/stm32f4_discovery-kit.repl"
        break
    elif [ -f "$path/platforms/cpus/stm32f4.repl" ]; then
        PLATFORM_FILE="@platforms/cpus/stm32f4.repl"
        echo "   ✅ Found STM32F4 CPU platform: $path/platforms/cpus/stm32f4.repl"
        break
    fi
done

if [ -z "$PLATFORM_FILE" ]; then
    echo "   ⚠️  STM32F4 platform not found, using generic Cortex-M4"
    PLATFORM_FILE="@platforms/cpus/cortex-m4.repl"
fi

echo "3. Creating correct Renode configuration..."
cat > build/correct_renode.resc << EOF
# Correct Renode configuration based on documentation

# Create machine with proper name
mach create "stm32f407_test"

# Load appropriate platform
machine LoadPlatformDescription $PLATFORM_FILE

# Set logging level for debugging
logLevel 1

# Configure semihosting properly
# Method 1: Enable semihosting analyzer
sysbus.cpu EnableProfiler "Antmicro.Renode.Analyzers.SemihostingAnalyzer"

# Method 2: Create terminal for semihosting output
emulation CreateServerSocketTerminal 3456 "semihost_out"

# Load our binary
sysbus LoadELF @build/bin/SimpleWorkingTest.elf

# Set proper initial state
cpu PC \`sysbus GetSymbolAddress "Reset_Handler"\`
cpu SP 0x20020000

# Show initial state
echo "=== Initial CPU State ==="
cpu

# Enable execution logging
cpu LogFunctionNames true

echo "=== Starting Execution with Semihosting ==="
start

# Let it run
sleep 3

# Check state
echo "=== CPU State After Execution ==="
cpu

# Show execution statistics
echo "=== Execution Statistics ==="
cpu GetExecutedInstructions

pause
echo "=== Correct Renode Test Completed ==="
quit
EOF

echo "4. Running correct Renode configuration..."
echo "Platform: $PLATFORM_FILE"
echo "Command: renode --disable-xwt build/correct_renode.resc"
echo "----------------------------------------"

timeout 15s renode --disable-xwt build/correct_renode.resc

CORRECT_EXIT_CODE=$?
echo "----------------------------------------"
echo "Correct configuration exit code: $CORRECT_EXIT_CODE"

echo
echo "5. Testing with monitor mode (interactive)..."
cat > build/monitor_renode.resc << EOF
# Monitor mode test
mach create "stm32f407_monitor"
machine LoadPlatformDescription $PLATFORM_FILE

# Enable semihosting
sysbus.cpu EnableProfiler "Antmicro.Renode.Analyzers.SemihostingAnalyzer"

# Load binary
sysbus LoadELF @build/bin/SimpleWorkingTest.elf
cpu PC \`sysbus GetSymbolAddress "Reset_Handler"\`
cpu SP 0x20020000

echo "=== Monitor Mode Test ==="
echo "Binary loaded. Monitor available on port 1234"
echo "Connect with: telnet localhost 1234"
echo "Commands: start, pause, cpu, quit"

# Start execution
start

# Run briefly
sleep 2

echo "=== Monitor Test Results ==="
cpu
pause
quit
EOF

echo "Running monitor mode test..."
timeout 10s renode --disable-xwt build/monitor_renode.resc

MONITOR_EXIT_CODE=$?
echo "Monitor mode exit code: $MONITOR_EXIT_CODE"

echo
echo "=== Correct Configuration Test Summary ==="
echo "Correct config test: Exit code $CORRECT_EXIT_CODE"
echo "Monitor mode test:   Exit code $MONITOR_EXIT_CODE"
echo
echo "Key improvements in this test:"
echo "- Proper platform file selection"
echo "- Correct semihosting analyzer setup"
echo "- Terminal creation for output"
echo "- CPU state monitoring"
echo "- Execution statistics"
echo
echo "If CPU state shows changes, the program is executing correctly."
echo "Semihosting output should appear in the terminal or logs."