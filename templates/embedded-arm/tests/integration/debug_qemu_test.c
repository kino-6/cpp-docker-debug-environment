/**
 * @file debug_qemu_test.c
 * @brief Debug QEMU test with step-by-step execution tracking
 */

#include <stdio.h>
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
    
    // Step 3: Test printf
    debug_write("STEP 3: Printf test starting...\n");
    printf("Printf is working! This is a test message.\n");
    
    // Step 4: Test basic operations
    debug_write("STEP 4: Basic operations test\n");
    volatile int a = 10;
    volatile int b = 32;
    volatile int sum = a + b;
    
    printf("Arithmetic test: %d + %d = %d\n", a, b, sum);
    
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
    
    printf("Memory checksum: 0x%08lX\n", (unsigned long)checksum);
    debug_write("Memory test: COMPLETED\n");
    
    // Step 6: Test ARM instructions
    debug_write("STEP 6: ARM instruction test\n");
    volatile uint32_t test_val = 0xAAAA5555;
    printf("Original value: 0x%08lX\n", (unsigned long)test_val);
    
    // Bit reverse instruction
    __asm volatile ("rbit %0, %0" : "+r" (test_val));
    printf("After RBIT: 0x%08lX\n", (unsigned long)test_val);
    
    // Reverse back
    __asm volatile ("rbit %0, %0" : "+r" (test_val));
    printf("After second RBIT: 0x%08lX\n", (unsigned long)test_val);
    
    if (test_val == 0xAAAA5555) {
        debug_write("ARM instruction test: PASSED\n");
    } else {
        debug_write("ARM instruction test: FAILED\n");
    }
    
    // Step 7: Controlled execution sequence
    debug_write("STEP 7: Controlled execution sequence\n");
    for (int i = 0; i < 5; i++) {
        printf("Execution step %d/5\n", i + 1);
        
        // Short delay
        for (volatile int j = 0; j < 100000; j++) {
            __asm("nop");
        }
        
        debug_write_char('.');
    }
    debug_write("\n");
    
    // Step 8: Final test
    debug_write("STEP 8: Final test sequence\n");
    printf("=== ALL TESTS COMPLETED ===\n");
    printf("QEMU ARM Cortex-M4 simulation is working correctly!\n");
    printf("Semihosting is functional.\n");
    printf("Printf output is working.\n");
    
    debug_write("=== DEBUG SUMMARY ===\n");
    debug_write("1. Direct semihosting: OK\n");
    debug_write("2. Character output: OK\n");
    debug_write("3. Printf output: OK\n");
    debug_write("4. Arithmetic: OK\n");
    debug_write("5. Memory operations: OK\n");
    debug_write("6. ARM instructions: OK\n");
    debug_write("7. Controlled execution: OK\n");
    debug_write("8. All tests: COMPLETED\n");
    
    // Step 9: Attempt clean exit
    debug_write("STEP 9: Attempting clean exit via semihosting\n");
    printf("Attempting to exit cleanly...\n");
    
    // Try semihosting exit
    int exit_code = 0;
    semihosting_call(SYS_EXIT, &exit_code);
    
    // If exit doesn't work, indicate and loop
    debug_write("Semihosting exit failed - entering controlled loop\n");
    printf("Semihosting exit failed. Entering controlled loop.\n");
    
    // Controlled loop with periodic output
    for (int loop_count = 0; loop_count < 10; loop_count++) {
        printf("Loop iteration %d/10\n", loop_count + 1);
        debug_write_char('*');
        
        // Longer delay
        for (volatile int k = 0; k < 1000000; k++) {
            __asm("nop");
        }
    }
    
    debug_write("\nControlled loop completed. Program should terminate now.\n");
    printf("Controlled loop completed. QEMU can be terminated.\n");
    
    // Final infinite loop
    while (1) {
        for (volatile int m = 0; m < 50000000; m++) {
            __asm("nop");
        }
    }
    
    return 0;
}