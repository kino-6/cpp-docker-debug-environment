#!/bin/bash

# Quick build test for ARM embedded project
# Can be run in any container with ARM GCC installed

set -e

echo "=== Quick ARM Build Test ==="

# Check if ARM toolchain is available
if ! command -v arm-none-eabi-gcc >/dev/null 2>&1; then
    echo "❌ ARM toolchain not found. Installing..."
    sudo apt-get update
    sudo apt-get install -y gcc-arm-none-eabi binutils-arm-none-eabi libnewlib-arm-none-eabi
fi

echo "✅ ARM GCC: $(arm-none-eabi-gcc --version | head -1)"

# Simple build test without full CMake setup
echo ""
echo "🔨 Testing basic ARM compilation..."

# Test main.c compilation
if arm-none-eabi-gcc -mcpu=cortex-m4 -mthumb -Wall -Wextra -Og -g3 \
   -Iinclude -Isrc/hal -Isrc/drivers \
   -c src/main.c -o build_test_main.o; then
    echo "✅ main.c compilation successful"
else
    echo "❌ main.c compilation failed"
    exit 1
fi

# Test HAL compilation
if arm-none-eabi-gcc -mcpu=cortex-m4 -mthumb -Wall -Wextra -Og -g3 \
   -Iinclude -c src/hal/system_init.c -o build_test_system.o; then
    echo "✅ system_init.c compilation successful"
else
    echo "❌ system_init.c compilation failed"
    exit 1
fi

# Test GPIO compilation
if arm-none-eabi-gcc -mcpu=cortex-m4 -mthumb -Wall -Wextra -Og -g3 \
   -Iinclude -c src/hal/gpio.c -o build_test_gpio.o; then
    echo "✅ gpio.c compilation successful"
else
    echo "❌ gpio.c compilation failed"
    exit 1
fi

# Test LED driver compilation
if arm-none-eabi-gcc -mcpu=cortex-m4 -mthumb -Wall -Wextra -Og -g3 \
   -Iinclude -c src/drivers/led.c -o build_test_led.o; then
    echo "✅ led.c compilation successful"
else
    echo "❌ led.c compilation failed"
    exit 1
fi

# Test startup assembly
if arm-none-eabi-gcc -mcpu=cortex-m4 -mthumb -x assembler-with-cpp \
   -c src/startup/startup_stm32f4xx.s -o build_test_startup.o; then
    echo "✅ startup_stm32f4xx.s compilation successful"
else
    echo "❌ startup_stm32f4xx.s compilation failed"
    exit 1
fi

# Test linking (without linker script for now)
echo ""
echo "🔗 Testing basic linking..."
if arm-none-eabi-gcc -mcpu=cortex-m4 -mthumb -specs=nosys.specs \
   build_test_*.o -o build_test_embedded.elf; then
    echo "✅ Basic linking successful"
    arm-none-eabi-size build_test_embedded.elf
else
    echo "❌ Basic linking failed"
    exit 1
fi

# Cleanup
rm -f build_test_*.o build_test_embedded.elf

echo ""
echo "🎉 Quick ARM build test completed successfully!"
echo "   All source files compile correctly"
echo "   Ready for full CMake build"