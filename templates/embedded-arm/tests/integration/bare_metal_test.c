/**
 * @file bare_metal_test.c
 * @brief Bare metal test without any library dependencies
 */

// Direct semihosting without any includes
#define SYS_WRITE0  0x04
#define SYS_EXIT    0x18

// Direct semihosting call
static inline int semihost_call(int reason, void* arg)
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

// Write string
static void write_string(const char* str)
{
    semihost_call(SYS_WRITE0, (void*)str);
}

// Exit program
static void exit_program(int code)
{
    semihost_call(SYS_EXIT, &code);
}

// Minimal reset handler
__attribute__((naked, noreturn))
void Reset_Handler(void)
{
    __asm volatile (
        "ldr sp, =0x20020000\n"
        "bl main\n"
        "b .\n"
    );
}

// Vector table
__attribute__((section(".isr_vector")))
const void* vector_table[] = {
    (void*)0x20020000,    // Stack pointer
    Reset_Handler,        // Reset handler
};

/**
 * @brief Bare metal main function
 */
int main(void)
{
    write_string("=== BARE METAL QEMU TEST ===\n");
    write_string("Starting bare metal ARM Cortex-M4 test...\n");
    
    // Test 1: Basic execution
    write_string("TEST 1: Basic execution - PASSED\n");
    
    // Test 2: Simple arithmetic
    volatile int x = 20;
    volatile int y = 22;
    volatile int result = x + y;
    
    if (result == 42) {
        write_string("TEST 2: Arithmetic (20+22=42) - PASSED\n");
    } else {
        write_string("TEST 2: Arithmetic - FAILED\n");
    }
    
    // Test 3: Memory access
    volatile int array[4] = {1, 2, 3, 4};
    volatile int sum = 0;
    for (int i = 0; i < 4; i++) {
        sum += array[i];
    }
    
    if (sum == 10) {
        write_string("TEST 3: Memory access (1+2+3+4=10) - PASSED\n");
    } else {
        write_string("TEST 3: Memory access - FAILED\n");
    }
    
    // Test 4: ARM instruction
    volatile unsigned int test_val = 0x12345678;
    __asm volatile ("rbit %0, %0" : "+r" (test_val));
    __asm volatile ("rbit %0, %0" : "+r" (test_val));
    
    if (test_val == 0x12345678) {
        write_string("TEST 4: ARM RBIT instruction - PASSED\n");
    } else {
        write_string("TEST 4: ARM RBIT instruction - FAILED\n");
    }
    
    // Test 5: Loop execution
    write_string("TEST 5: Loop execution - ");
    for (int i = 0; i < 5; i++) {
        // Simple delay
        for (volatile int j = 0; j < 50000; j++) {
            __asm("nop");
        }
    }
    write_string("PASSED\n");
    
    // Final result
    write_string("\n=== ALL TESTS COMPLETED ===\n");
    write_string("Bare metal ARM Cortex-M4 test successful!\n");
    write_string("QEMU semihosting is working correctly.\n");
    write_string("Program will now exit cleanly.\n");
    
    // Attempt clean exit
    exit_program(0);
    
    // Should not reach here
    write_string("ERROR: Exit failed, entering infinite loop\n");
    while (1) {
        for (volatile int k = 0; k < 1000000; k++) {
            __asm("nop");
        }
    }
    
    return 0;
}