#!/bin/bash

echo "=== Official Renode Docker Test ==="
echo "Testing with official Renode Docker image"
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

echo "2. Checking if Docker is available..."
if ! command -v docker &> /dev/null; then
    echo "   ❌ Docker not available. Skipping official Docker test."
    exit 1
fi

echo "   ✅ Docker is available"

echo "3. Creating Renode script for official Docker..."
cat > build/official_docker_test.resc << 'EOF'
# Official Docker Renode test
echo "=== Official Renode Docker Test ==="

# Create machine
mach create "stm32f407"

# Try to load STM32F4 platform
machine LoadPlatformDescription @platforms/boards/stm32f4_discovery-kit.repl

# Load binary
sysbus LoadELF @/workspace/build/bin/SimpleWorkingTest.elf

# Set initial state
cpu PC `sysbus GetSymbolAddress "Reset_Handler"`
cpu SP 0x20020000

echo "Binary loaded, starting execution..."

# Start execution
start

# Run for a few seconds
sleep 3

echo "Execution completed"
pause
quit
EOF

echo "4. Testing with official Renode Docker image..."
echo "Command: docker run --rm -v $(pwd):/workspace renode/renode:latest renode --disable-xwt /workspace/build/official_docker_test.resc"
echo "----------------------------------------"

# Try official Docker image
timeout 30s docker run --rm -v $(pwd):/workspace renode/renode:latest renode --disable-xwt /workspace/build/official_docker_test.resc 2>&1

DOCKER_EXIT_CODE=$?
echo "----------------------------------------"
echo "Official Docker exit code: $DOCKER_EXIT_CODE"

if [ $DOCKER_EXIT_CODE -eq 0 ]; then
    echo "   ✅ SUCCESS! Official Renode Docker worked!"
elif [ $DOCKER_EXIT_CODE -eq 124 ]; then
    echo "   ⚠️  TIMEOUT: Official Docker test timed out"
elif [ $DOCKER_EXIT_CODE -eq 125 ]; then
    echo "   ⚠️  Docker image not available, trying to pull..."
    docker pull renode/renode:latest
    if [ $? -eq 0 ]; then
        echo "   Retrying with pulled image..."
        timeout 20s docker run --rm -v $(pwd):/workspace renode/renode:latest renode --disable-xwt /workspace/build/official_docker_test.resc
        echo "   Retry exit code: $?"
    fi
else
    echo "   ❌ Official Docker test failed with exit code $DOCKER_EXIT_CODE"
fi

echo
echo "5. Alternative: Testing with different platform..."
cat > build/alternative_platform_test.resc << 'EOF'
# Alternative platform test
echo "=== Alternative Platform Test ==="

# Create machine
mach create "cortex_m"

# Try different platform approach
machine LoadPlatformDescription @platforms/cpus/cortex-m4.repl

# Load binary
sysbus LoadELF @/workspace/build/bin/SimpleWorkingTest.elf

# Set initial state
cpu PC `sysbus GetSymbolAddress "Reset_Handler"`
cpu SP 0x20020000

echo "Alternative platform loaded"

# Start execution
start
sleep 2

echo "Alternative test completed"
quit
EOF

echo "Testing alternative platform approach..."
timeout 15s docker run --rm -v $(pwd):/workspace renode/renode:latest renode --disable-xwt /workspace/build/alternative_platform_test.resc 2>&1

ALT_EXIT_CODE=$?
echo "Alternative platform exit code: $ALT_EXIT_CODE"

echo
echo "=== Official Docker Test Summary ==="
echo "Official Docker test: Exit code $DOCKER_EXIT_CODE"
echo "Alternative platform: Exit code $ALT_EXIT_CODE"
echo
echo "This test helps determine:"
echo "- If official Renode Docker image works better"
echo "- Correct platform file usage"
echo "- Proper Docker volume mounting"
echo "- Binary compatibility with official Renode"