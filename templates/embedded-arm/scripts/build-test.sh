#!/bin/bash

# ARM Embedded Build Test Script
# This script tests the build process for the ARM embedded project

set -e

echo "=== ARM Embedded Build Test ==="
echo "Target: STM32F407VG (ARM Cortex-M4)"
echo "Toolchain: ARM GCC"
echo ""

# Check if we're in the right directory
if [ ! -f "CMakeLists.txt" ]; then
    echo "❌ Error: CMakeLists.txt not found. Please run from project root."
    exit 1
fi

# Check ARM toolchain availability
echo "🔍 Checking ARM toolchain..."
if ! command -v arm-none-eabi-gcc >/dev/null 2>&1; then
    echo "❌ Error: arm-none-eabi-gcc not found"
    echo "   Please install ARM GCC toolchain or run in Dev Container"
    exit 1
fi

if ! command -v cmake >/dev/null 2>&1; then
    echo "❌ Error: cmake not found"
    exit 1
fi

if ! command -v ninja >/dev/null 2>&1; then
    echo "❌ Error: ninja not found"
    exit 1
fi

echo "✅ ARM GCC: $(arm-none-eabi-gcc --version | head -1)"
echo "✅ CMake: $(cmake --version | head -1)"
echo "✅ Ninja: $(ninja --version)"
echo ""

# Clean previous build
echo "🧹 Cleaning previous build..."
rm -rf build
mkdir -p build

# Configure
echo "⚙️  Configuring build..."
if cmake -B build -S . -G Ninja -DCMAKE_BUILD_TYPE=Debug -DCMAKE_EXPORT_COMPILE_COMMANDS=ON; then
    echo "✅ Configuration successful"
else
    echo "❌ Configuration failed"
    exit 1
fi

# Build
echo "🔨 Building project..."
if cmake --build build --parallel; then
    echo "✅ Build successful"
else
    echo "❌ Build failed"
    exit 1
fi

# Check output files
echo ""
echo "📁 Generated files:"
ls -la build/bin/ || echo "No bin directory found"

if [ -f "build/bin/EmbeddedArmProject.elf" ]; then
    echo ""
    echo "📊 Binary information:"
    arm-none-eabi-size build/bin/EmbeddedArmProject.elf
    
    echo ""
    echo "🎯 Memory sections:"
    arm-none-eabi-objdump -h build/bin/EmbeddedArmProject.elf | grep -E "(\.text|\.data|\.bss|\.rodata)"
    
    echo ""
    echo "✅ Build test completed successfully!"
    echo "   ELF file: build/bin/EmbeddedArmProject.elf"
    if [ -f "build/bin/EmbeddedArmProject.hex" ]; then
        echo "   HEX file: build/bin/EmbeddedArmProject.hex"
    fi
    if [ -f "build/bin/EmbeddedArmProject.bin" ]; then
        echo "   BIN file: build/bin/EmbeddedArmProject.bin"
    fi
else
    echo "❌ ELF file not generated"
    exit 1
fi

echo ""
echo "🎉 ARM embedded build test passed!"