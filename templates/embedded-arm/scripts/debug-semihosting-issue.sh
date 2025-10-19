#!/bin/bash

echo "=== Semihosting Issue Debug Analysis ==="
echo "Comprehensive analysis of semihosting configuration problems"
echo

# Navigate to integration tests
cd tests/integration

echo "1. Environment Check..."
echo "QEMU version:"
qemu-system-arm --version | head -1
echo
echo "Renode version:"
renode --version 2>/dev/null | head -1 || echo "Renode not found or not working"
echo
echo "ARM toolchain:"
arm-none-eabi-gcc --version | head -1
echo

echo "2. Building ultra simple test..."
rm -rf build
cmake -B build -S . -G Ninja -DCMAKE_BUILD_TYPE=Debug
cmake --build build --target UltraSimpleSemihost.elf

if [ $? -ne 0 ]; then
    echo "   ❌ Build failed"
    exit 1
fi
echo "   ✓ Build successful"

echo
echo "3. Binary Analysis..."
echo "File size and type:"
ls -la build/bin/UltraSimpleSemihost.elf
file build/bin/UltraSimpleSemihost.elf
echo

echo "Memory layout:"
arm-none-eabi-size -A build/bin/UltraSimpleSemihost.elf
echo

echo "Entry point and sections:"
arm-none-eabi-readelf -h build/bin/UltraSimpleSemihost.elf | grep -E "(Entry|Machine|Class)"
echo

echo "Vector table (first 8 bytes):"
arm-none-eabi-objdump -s -j .isr_vector build/bin/UltraSimpleSemihost.elf | head -10
echo

echo "4. Semihosting Implementation Analysis..."
echo "Disassembly of main function:"
arm-none-eabi-objdump -d build/bin/UltraSimpleSemihost.elf | grep -A 20 "<main>:"
echo

echo "All semihosting breakpoints (bkpt #0xAB):"
arm-none-eabi-objdump -d build/bin/UltraSimpleSemihost.elf | grep -B 2 -A 2 "bkpt.*0xab"
echo

echo "5. QEMU Detailed Testing..."

echo "5a. QEMU with maximum verbosity:"
echo "Command: qemu-system-arm -M netduinoplus2 -cpu cortex-m4 -kernel build/bin/UltraSimpleSemihost.elf -nographic -semihosting -d in_asm,int,exec,cpu"
echo "----------------------------------------"

timeout 5s qemu-system-arm \
    -M netduinoplus2 \
    -cpu cortex-m4 \
    -kernel build/bin/UltraSimpleSemihost.elf \
    -nographic \
    -semihosting \
    -d in_asm,int,exec,cpu 2>&1 | head -50

echo "----------------------------------------"
echo

echo "5b. QEMU with semihosting debug:"
echo "Command: qemu-system-arm -M netduinoplus2 -cpu cortex-m4 -kernel build/bin/UltraSimpleSemihost.elf -nographic -semihosting -d guest_errors,unimp,trace:arm_semihosting*"
echo "----------------------------------------"

timeout 5s qemu-system-arm \
    -M netduinoplus2 \
    -cpu cortex-m4 \
    -kernel build/bin/UltraSimpleSemihost.elf \
    -nographic \
    -semihosting \
    -d guest_errors,unimp 2>&1 | head -30

echo "----------------------------------------"
echo

echo "5c. QEMU with different semihosting target:"
echo "Command: qemu-system-arm -M netduinoplus2 -cpu cortex-m4 -kernel build/bin/UltraSimpleSemihost.elf -nographic -semihosting-config enable=on,target=auto"
echo "----------------------------------------"

timeout 5s qemu-system-arm \
    -M netduinoplus2 \
    -cpu cortex-m4 \
    -kernel build/bin/UltraSimpleSemihost.elf \
    -nographic \
    -semihosting-config enable=on,target=auto 2>&1

echo "----------------------------------------"
echo

echo "6. Alternative Machine Types..."

echo "6a. Testing with lm3s6965evb (Stellaris):"
timeout 5s qemu-system-arm \
    -M lm3s6965evb \
    -cpu cortex-m3 \
    -kernel build/bin/UltraSimpleSemihost.elf \
    -nographic \
    -semihosting 2>&1 | head -10

echo

echo "6b. Testing with mps2-an385 (ARM MPS2):"
timeout 5s qemu-system-arm \
    -M mps2-an385 \
    -cpu cortex-m3 \
    -kernel build/bin/UltraSimpleSemihost.elf \
    -nographic \
    -semihosting 2>&1 | head -10

echo

echo "7. GDB Analysis..."
echo "Starting QEMU with GDB server for detailed analysis..."

# Start QEMU with GDB server
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

echo "Connecting with GDB for register and memory analysis..."
cat > build/detailed_gdb_commands.txt << 'EOF'
target remote localhost:1234
info registers
x/8wx 0x08000000
x/8wx 0x20000000
disassemble Reset_Handler
disassemble main
continue
info registers
quit
EOF

timeout 10s gdb-multiarch -batch -x build/detailed_gdb_commands.txt build/bin/UltraSimpleSemihost.elf

# Kill QEMU
kill $QEMU_PID 2>/dev/null
wait $QEMU_PID 2>/dev/null

echo
echo "8. Potential Issues Analysis..."
echo "Common semihosting problems:"
echo "- QEMU version compatibility (need 4.0+ for proper ARM semihosting)"
echo "- Machine type not supporting semihosting properly"
echo "- Incorrect breakpoint instruction (should be 'bkpt #0xAB')"
echo "- Missing or incorrect vector table setup"
echo "- Stack pointer not initialized correctly"
echo "- Semihosting not enabled in QEMU/Renode"
echo

echo "9. Recommendations..."
echo "If semihosting output is still not visible:"
echo "1. Try different QEMU machine types (lm3s6965evb, mps2-an385)"
echo "2. Use GDB to step through execution and verify semihosting calls"
echo "3. Check if QEMU was compiled with semihosting support"
echo "4. Consider using OpenOCD + real hardware for testing"
echo "5. Implement UART output as alternative to semihosting"
echo

echo "=== Debug Analysis Complete ==="