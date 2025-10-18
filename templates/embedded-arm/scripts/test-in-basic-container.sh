#!/bin/bash

# Test ARM embedded build in basic-cpp container
# This script tests if ARM toolchain can be installed and used in the basic container

echo "=== ARM Toolchain Installation Test ==="
echo "Testing in basic-cpp Dev Container environment"
echo ""

# Install ARM toolchain
echo "📦 Installing ARM GCC toolchain..."
sudo apt-get update
sudo apt-get install -y gcc-arm-none-eabi binutils-arm-none-eabi libnewlib-arm-none-eabi

# Verify installation
echo ""
echo "🔍 Verifying ARM toolchain..."
arm-none-eabi-gcc --version
arm-none-eabi-ld --version
arm-none-eabi-objcopy --version
arm-none-eabi-size --version

# Test simple compilation
echo ""
echo "🧪 Testing ARM compilation..."
cat > test_arm.c << 'EOF'
int main(void) {
    volatile int counter = 0;
    while(1) {
        counter++;
        if (counter > 1000) break;
    }
    return 0;
}
EOF

# Compile test
if arm-none-eabi-gcc -mcpu=cortex-m4 -mthumb -O2 -c test_arm.c -o test_arm.o; then
    echo "✅ ARM compilation successful"
    arm-none-eabi-size test_arm.o
    rm -f test_arm.c test_arm.o
else
    echo "❌ ARM compilation failed"
    exit 1
fi

echo ""
echo "🎉 ARM toolchain test completed successfully!"
echo "   Ready to build embedded-arm project"