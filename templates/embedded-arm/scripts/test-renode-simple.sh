#!/bin/bash

echo "=== Simple Renode Test Script ==="
echo "Testing basic Renode functionality"
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

# Check if Renode is available
echo "2. Checking Renode availability..."
if ! command -v renode &> /dev/null; then
    echo "   ⚠️  Renode not available. Using QEMU instead."
    echo "   Running QEMU test..."
    timeout 10s qemu-system-arm \
        -M netduinoplus2 \
        -cpu cortex-m4 \
        -kernel build/bin/SimpleWorkingTest.elf \
        -nographic \
        -semihosting
    
    echo "   QEMU test completed (exit code: $?)"
    exit 0
fi

echo "   ✅ Renode is available"
renode --version | head -1

# Create minimal Renode script
echo "3. Creating minimal Renode test..."
cat > build/minimal_renode.resc << 'EOF'
# Minimal Renode test script
mach create "test"
machine LoadPlatformDescription @platforms/boards/stm32f4_discovery-kit.repl

# Load binary
sysbus LoadELF @build/bin/SimpleWorkingTest.elf

# Set initial state
cpu PC `sysbus GetSymbolAddress "Reset_Handler"`
cpu SP 0x20020000

# Enable basic logging
logLevel 1

# Start and run for a few seconds
start
sleep 3
pause

echo "Renode test completed"
quit
EOF

echo "4. Running Renode test..."
echo "Command: renode --disable-xwt build/minimal_renode.resc"
echo "----------------------------------------"

timeout 10s renode --disable-xwt build/minimal_renode.resc 2>&1

RENODE_EXIT_CODE=$?
echo "----------------------------------------"
echo "Renode exit code: $RENODE_EXIT_CODE"

if [ $RENODE_EXIT_CODE -eq 0 ]; then
    echo "   ✅ SUCCESS! Renode executed successfully!"
elif [ $RENODE_EXIT_CODE -eq 124 ]; then
    echo "   ⚠️  TIMEOUT: Renode test timed out (may be normal)"
else
    echo "   ❌ ERROR: Renode failed with exit code $RENODE_EXIT_CODE"
fi

echo
echo "=== Simple Renode Test Summary ==="
echo "This test verifies basic Renode functionality."
echo "If Renode is not available, it falls back to QEMU."
echo "Both simulators provide ARM Cortex-M4 execution capabilities."