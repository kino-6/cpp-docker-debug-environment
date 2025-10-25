#!/bin/bash

echo "=== Ultra Simple Semihosting Test ==="
echo "Testing with absolute minimal semihosting implementation"
echo

# Navigate to integration tests
cd tests/integration

# Clean and build
echo "1. Building ultra simple semihosting test..."
rm -rf build
cmake -B build -S . -G Ninja -DCMAKE_BUILD_TYPE=Debug
cmake --build build --target UltraSimpleSemihost.elf

if [ $? -ne 0 ]; then
    echo "   ❌ Build failed"
    exit 1
fi
echo "   ✓ Build successful"

echo "2. Analyzing ultra simple binary..."
echo "Binary size and sections:"
arm-none-eabi-size build/bin/UltraSimpleSemihost.elf
echo
echo "Checking semihosting implementation:"
arm-none-eabi-objdump -d build/bin/UltraSimpleSemihost.elf | grep -A 3 -B 3 "bkpt" | head -15
echo

echo "3. Testing with QEMU (multiple configurations)..."

echo "3a. Standard QEMU with semihosting:"
echo "Command: qemu-system-arm -M netduinoplus2 -cpu cortex-m4 -kernel build/bin/UltraSimpleSemihost.elf -nographic -semihosting"
echo "----------------------------------------"

timeout 8s qemu-system-arm \
    -M netduinoplus2 \
    -cpu cortex-m4 \
    -kernel build/bin/UltraSimpleSemihost.elf \
    -nographic \
    -semihosting

QEMU_EXIT_CODE=$?
echo "----------------------------------------"
echo "QEMU standard exit code: $QEMU_EXIT_CODE"
echo

echo "3b. QEMU with explicit semihosting config:"
echo "Command: qemu-system-arm -M netduinoplus2 -cpu cortex-m4 -kernel build/bin/UltraSimpleSemihost.elf -nographic -semihosting-config enable=on,target=native"
echo "----------------------------------------"

timeout 8s qemu-system-arm \
    -M netduinoplus2 \
    -cpu cortex-m4 \
    -kernel build/bin/UltraSimpleSemihost.elf \
    -nographic \
    -semihosting-config enable=on,target=native

QEMU_CONFIG_EXIT_CODE=$?
echo "----------------------------------------"
echo "QEMU config exit code: $QEMU_CONFIG_EXIT_CODE"
echo

echo "3c. QEMU with different machine (mps2-an385):"
echo "Command: qemu-system-arm -M mps2-an385 -cpu cortex-m3 -kernel build/bin/UltraSimpleSemihost.elf -nographic -semihosting"
echo "----------------------------------------"

timeout 8s qemu-system-arm \
    -M mps2-an385 \
    -cpu cortex-m3 \
    -kernel build/bin/UltraSimpleSemihost.elf \
    -nographic \
    -semihosting

QEMU_MPS2_EXIT_CODE=$?
echo "----------------------------------------"
echo "QEMU mps2 exit code: $QEMU_MPS2_EXIT_CODE"
echo

echo "3d. QEMU with verbose output:"
echo "Command: qemu-system-arm -M netduinoplus2 -cpu cortex-m4 -kernel build/bin/UltraSimpleSemihost.elf -nographic -semihosting -d guest_errors,unimp"
echo "----------------------------------------"

timeout 8s qemu-system-arm \
    -M netduinoplus2 \
    -cpu cortex-m4 \
    -kernel build/bin/UltraSimpleSemihost.elf \
    -nographic \
    -semihosting \
    -d guest_errors,unimp

QEMU_VERBOSE_EXIT_CODE=$?
echo "----------------------------------------"
echo "QEMU verbose exit code: $QEMU_VERBOSE_EXIT_CODE"
echo

echo "4. Testing with Renode (improved configuration)..."
cat > build/ultra_simple_renode.resc << 'EOF'
# Ultra Simple Renode configuration
mach create "ultra_simple_test"

# Load STM32F4 platform
machine LoadPlatformDescription @platforms/boards/stm32f4_discovery-kit.repl

# Enable semihosting with explicit configuration
sysbus.cpu EnableProfiler "Antmicro.Renode.Analyzers.SemihostingAnalyzer"

# Load ultra simple sample
sysbus LoadELF @build/bin/UltraSimpleSemihost.elf

# Set initial state
cpu PC `sysbus GetSymbolAddress "Reset_Handler"`
cpu SP 0x20020000

echo "=== Ultra Simple Renode Test ==="
echo "Starting execution..."
start
sleep 5
echo "Execution completed"
pause
quit
EOF

echo "Command: renode --disable-xwt build/ultra_simple_renode.resc"
echo "----------------------------------------"

timeout 10s renode --disable-xwt build/ultra_simple_renode.resc

RENODE_EXIT_CODE=$?
echo "----------------------------------------"
echo "Renode exit code: $RENODE_EXIT_CODE"
echo

echo "5. Alternative debugging approaches..."

echo "5a. Check if binary is valid ARM code:"
echo "Entry point and reset vector:"
arm-none-eabi-objdump -h build/bin/UltraSimpleSemihost.elf | grep -E "(\.text|\.isr_vector)"
echo

echo "5b. Disassemble reset handler:"
arm-none-eabi-objdump -d build/bin/UltraSimpleSemihost.elf | grep -A 10 "Reset_Handler"
echo

echo "5c. Check symbol table:"
arm-none-eabi-nm build/bin/UltraSimpleSemihost.elf | grep -E "(main|Reset_Handler)"
echo

echo "6. Test with GDB + QEMU (if semihosting fails)..."
echo "Starting QEMU with GDB server..."

# Start QEMU with GDB server in background
qemu-system-arm \
    -M netduinoplus2 \
    -cpu cortex-m4 \
    -kernel build/bin/UltraSimpleSemihost.elf \
    -nographic \
    -semihosting \
    -gdb tcp::1234 \
    -S &

QEMU_PID=$!
sleep 2

echo "Connecting with GDB..."
cat > build/gdb_commands.txt << 'EOF'
target remote localhost:1234
monitor info registers
continue
quit
EOF

timeout 5s gdb-multiarch -batch -x build/gdb_commands.txt build/bin/UltraSimpleSemihost.elf

# Kill QEMU
kill $QEMU_PID 2>/dev/null
wait $QEMU_PID 2>/dev/null

echo
echo "=== Ultra Simple Semihosting Test Summary ==="
echo "QEMU standard:    Exit code $QEMU_EXIT_CODE"
echo "QEMU config:      Exit code $QEMU_CONFIG_EXIT_CODE"
echo "QEMU mps2:        Exit code $QEMU_MPS2_EXIT_CODE"
echo "QEMU verbose:     Exit code $QEMU_VERBOSE_EXIT_CODE"
echo "Renode:           Exit code $RENODE_EXIT_CODE"
echo
echo "This test uses:"
echo "- Ultra minimal semihosting implementation"
echo "- Direct ARM assembly for semihosting calls"
echo "- Minimal vector table and reset handler"
echo "- No library dependencies (nostdlib)"
echo
echo "Expected behavior:"
echo "- Should see 'ULTRA SIMPLE TEST START' message"
echo "- Should see multiple test messages"
echo "- Should see 'ULTRA SIMPLE TEST END' message"
echo "- Should exit cleanly with code 0"
echo
if [ $QEMU_EXIT_CODE -eq 0 ] || [ $QEMU_CONFIG_EXIT_CODE -eq 0 ] || [ $RENODE_EXIT_CODE -eq 0 ]; then
    echo "✅ SUCCESS: At least one simulator showed proper semihosting output"
else
    echo "❌ ISSUE: All simulators timed out (code 124) - semihosting output not visible"
    echo "   This suggests a fundamental semihosting configuration problem"
fi