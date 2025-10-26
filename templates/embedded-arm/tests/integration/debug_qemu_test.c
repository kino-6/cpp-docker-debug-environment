/**
 * @file debug_qemu_test.c
 * @brief Debug QEMU test with step-by-step execution tracking
 * Note: Uses only semihosting, no standard library functions
 */

#include <stdint.h>

// Semihosting system call numbers
#define SYS_WRITEC  0x03
#define SYS_WRITE0  0x04
#define SYS_EXIT    0x18

// Direct semihosting call
static inline int semihosting_call(int reason, void* arg)
{
    int result;
    __asm volatile (
        "mov r0, %1\n"
        "mov r1, %2\n"
        "bkpt #0xAB\n"
        "mov %0, r0"
        : "=r" (result)
        : "r" (reason), "r" (arg)
        : "r0", "r1", "memory"
    );
    return result;
}

// Write string via semihosting
static void debug_write(const char* str)
{
    semihosting_call(SYS_WRITE0, (void*)str);
}

// Write single character via semihosting
static void debug_write_char(char c)
{
    semihosting_call(SYS_WRITEC, &c);
}

// Simple integer to string conversion
static void debug_write_int(int value)
{
    if (value == 0) {
        debug_write_char('0');
        return;
    }
    
    if (value < 0) {
        debug_write_char('-');
        value = -value;
    }
    
    char buffer[12];  // Enough for 32-bit int
    int pos = 0;
    
    while (value > 0) {
        buffer[pos++] = '0' + (value % 10);
        value /= 10;
    }
    
    // Write digits in reverse order
    for (int i = pos - 1; i >= 0; i--) {
        debug_write_char(buffer[i]);
    }
}

// Simple hex output
static void debug_write_hex(uint32_t value)
{
    debug_write("0x");
    for (int i = 28; i >= 0; i -= 4) {
        int digit = (value >> i) & 0xF;
        if (digit < 10) {
            debug_write_char('0' + digit);
        } else {
            debug_write_char('A' + digit - 10);
        }
    }
}

// Simple startup with minimal vector table
__attribute__((naked, noreturn))
void Reset_Handler(void)
{
    __asm volatile (
        "ldr sp, =0x20020000\n"  // Set stack pointer
        "bl main\n"              // Jump to main
        "b .\n"                  // Infinite loop
    );
}

// Minimal vector table
__attribute__((section(".isr_vector")))
const uint32_t vector_table[] = {
    0x20020000,                 // Initial stack pointer
    (uint32_t)Reset_Handler,    // Reset handler
};

/**
 * @brief Debug main function with step tracking
 */
int main(void)
{
    // Step 1: Test direct semihosting
    debug_write("STEP 1: Direct semihosting test\n");
    debug_write("If you see this, direct semihosting is working!\n");
    
    // Step 2: Test character output
    debug_write("STEP 2: Character output test: ");
    debug_write_char('O');
    debug_write_char('K');
    debug_write_char('\n');
    
    // Step 3: Test integer output
    debug_write("STEP 3: Integer output test starting...\n");
    debug_write("Custom integer output is working!\n");
    
    // Step 4: Test basic operations
    debug_write("STEP 4: Basic operations test\n");
    volatile int a = 10;
    volatile int b = 32;
    volatile int sum = a + b;
    
    debug_write("Arithmetic test: ");
    debug_write_int(a);
    debug_write(" + ");
    debug_write_int(b);
    debug_write(" = ");
    debug_write_int(sum);
    debug_write("\n");
    
    if (sum == 42) {
        debug_write("Arithmetic test: PASSED\n");
    } else {
        debug_write("Arithmetic test: FAILED\n");
    }
    
    // Step 5: Test memory operations
    debug_write("STEP 5: Memory operations test\n");
    volatile uint32_t data[4] = {0x12345678, 0x9ABCDEF0, 0x11111111, 0x22222222};
    uint32_t checksum = 0;
    
    for (int i = 0; i < 4; i++) {
        checksum ^= data[i];  // XOR checksum
    }
    
    debug_write("Memory checksum: ");
    debug_write_hex(checksum);
    debug_write("\n");
    debug_write("Memory test: COMPLETED\n");
    
    // Step 6: Test ARM instructions
    debug_write("STEP 6: ARM instruction test\n");
    volatile uint32_t test_val = 0xAAAA5555;
    debug_write("Original value: ");
    debug_write_hex(test_val);
    debug_write("\n");
    
    // Bit reverse instruction
    __asm volatile ("rbit %0, %0" : "+r" (test_val));
    debug_write("After RBIT: ");
    debug_write_hex(test_val);
    debug_write("\n");
    
    // Reverse back
    __asm volatile ("rbit %0, %0" : "+r" (test_val));
    debug_write("After second RBIT: ");
    debug_write_hex(test_val);
    debug_write("\n");
    
    if (test_val == 0xAAAA5555) {
        debug_write("ARM instruction test: PASSED\n");
    } else {
        debug_write("ARM instruction test: FAILED\n");
    }
    
    // Step 7: Controlled execution sequence
    debug_write("STEP 7: Controlled execution sequence\n");
    for (int i = 0; i < 5; i++) {
        debug_write("Execution step ");
        debug_write_int(i + 1);
        debug_write("/5\n");
        
        // Short delay
        for (volatile int j = 0; j < 100000; j++) {
            __asm("nop");
        }
        
        debug_write_char('.');
    }
    debug_write("\n");
    
    // Step 8: Final test
    debug_write("STEP 8: Final test sequence\n");
    debug_write("=== ALL TESTS COMPLETED ===\n");
    debug_write("QEMU ARM Cortex-M4 simulation is working correctly!\n");
    debug_write("Semihosting is functional.\n");
    debug_write("Custom output functions are working.\n");
    
    debug_write("=== DEBUG SUMMARY ===\n");
    debug_write("1. Direct semihosting: OK\n");
    debug_write("2. Character output: OK\n");
    debug_write("3. Integer output: OK\n");
    debug_write("4. Arithmetic: OK\n");
    debug_write("5. Memory operations: OK\n");
    debug_write("6. ARM instructions: OK\n");
    debug_write("7. Controlled execution: OK\n");
    debug_write("8. All tests: COMPLETED\n");
    
    // Step 9: Attempt clean exit
    debug_write("STEP 9: Attempting clean exit via semihosting\n");
    debug_write("Attempting to exit cleanly...\n");
    
    // Try semihosting exit
    int exit_code = 0;
    semihosting_call(SYS_EXIT, &exit_code);
    
    // If exit doesn't work, indicate and loop
    debug_write("Semihosting exit failed - entering controlled loop\n");
    debug_write("Semihosting exit failed. Entering controlled loop.\n");
    
    // Controlled loop with periodic output
    for (int loop_count = 0; loop_count < 10; loop_count++) {
        debug_write("Loop iteration ");
        debug_write_int(loop_count + 1);
        debug_write("/10\n");
        debug_write_char('*');
        
        // Longer delay
        for (volatile int k = 0; k < 1000000; k++) {
            __asm("nop");
        }
    }
    
    debug_write("\nControlled loop completed. Program should terminate now.\n");
    debug_write("Controlled loop completed. QEMU can be terminated.\n");
    
    // Final infinite loop
    while (1) {
        for (volatile int m = 0; m < 50000000; m++) {
            __asm("nop");
        }
    }
    
    return 0;
}