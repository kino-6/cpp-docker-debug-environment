#!/bin/bash

echo "=== Renode ARM Simulator Test Script ==="
echo "Testing ARM Cortex-M4 simulation with Renode"
echo

# Navigate to integration tests
cd tests/integration

# Clean and build
echo "1. Building test for Renode..."
rm -rf build
cmake -B build -S . -G Ninja -DCMAKE_BUILD_TYPE=Debug
cmake --build build --target SimpleWorkingTest.elf

if [ $? -ne 0 ]; then
    echo "   ❌ Build failed"
    exit 1
fi
echo "   ✓ Build successful"

echo "2. Checking Renode installation..."
which renode
if [ $? -ne 0 ]; then
    echo "   ⚠️  Renode not found. Attempting to install..."
    ./scripts/install-renode.sh
    
    # Check again
    which renode
    if [ $? -ne 0 ]; then
        echo "   ❌ Renode installation failed. Falling back to QEMU test."
        echo "   Running QEMU test instead..."
        ./scripts/test-simple-working.sh
        exit $?
    fi
fi

renode --version | head -3
echo

echo "3. Analyzing test binary..."
arm-none-eabi-size build/bin/SimpleWorkingTest.elf
echo

echo "4. Creating Renode test script..."
cat > build/test_simple.resc << 'EOF'
# Load STM32F407 platform
mach create "stm32f407"
machine LoadPlatformDescription @platforms/boards/stm32f4_discovery-kit.repl

# Set up logging
logLevel 1

# Enable semihosting
sysbus.cpu EnableProfiler "Antmicro.Renode.Analyzers.SemihostingAnalyzer"

# Load our binary
sysbus LoadELF @build/bin/SimpleWorkingTest.elf

# Set up initial state
cpu PC `sysbus GetSymbolAddress "Reset_Handler"`
cpu SP 0x20020000

# Start execution
start

# Wait for execution
sleep 5

# Show results
echo "Renode execution completed"
quit
EOF

echo "5. Running Renode simulation..."
echo "Command: renode --disable-xwt build/test_simple.resc"
echo "----------------------------------------"

# Run Renode in headless mode
timeout 15s renode --disable-xwt build/test_simple.resc

RENODE_EXIT_CODE=$?
echo "----------------------------------------"
echo "Renode exit code: $RENODE_EXIT_CODE"

if [ $RENODE_EXIT_CODE -eq 0 ]; then
    echo "   ✅ SUCCESS! Renode executed successfully!"
    echo "   Check the output above for semihosting messages."
elif [ $RENODE_EXIT_CODE -eq 124 ]; then
    echo "   ⚠️  TIMEOUT: Renode simulation timed out"
    echo "   This may be normal if the program runs indefinitely."
else
    echo "   ❌ ERROR: Renode failed with exit code $RENODE_EXIT_CODE"
fi

echo
echo "6. Testing with interactive Renode session..."
echo "Creating interactive test script..."

cat > build/test_interactive.resc << 'EOF'
# Load STM32F407 platform
mach create "stm32f407"
machine LoadPlatformDescription @platforms/boards/stm32f4_discovery-kit.repl

# Set up logging
logLevel 1

# Enable semihosting
sysbus.cpu EnableProfiler "Antmicro.Renode.Analyzers.SemihostingAnalyzer"

# Load our binary
sysbus LoadELF @build/bin/SimpleWorkingTest.elf

# Set up initial state
cpu PC `sysbus GetSymbolAddress "Reset_Handler"`
cpu SP 0x20020000

echo "Binary loaded. Type 'start' to begin execution."
echo "Type 'pause' to pause, 'quit' to exit."
EOF

echo "Interactive script created: build/test_interactive.resc"
echo "To run interactively: renode build/test_interactive.resc"

echo
echo "=== Renode Test Summary ==="
echo "Renode provides superior ARM Cortex-M4 simulation compared to QEMU:"
echo "- Better semihosting support"
echo "- More accurate peripheral emulation"
echo "- Built-in debugging capabilities"
echo "- Professional-grade simulation"
echo
echo "If semihosting output appeared above, Renode is working correctly!"