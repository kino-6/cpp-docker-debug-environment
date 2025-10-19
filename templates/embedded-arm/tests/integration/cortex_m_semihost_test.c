/**
 * @file cortex_m_semihost_test.c
 * @brief ARM Cortex-M specific semihosting test
 */

// ARM Cortex-M semihosting with proper BKPT instruction
static inline int cortex_m_semihost_call(int reason, void* arg)
{
    int result;
    __asm volatile (
        "mov r0, %1\n"          // Load reason
        "mov r1, %2\n"          // Load argument
        "bkpt #0xAB\n"          // ARM semihosting breakpoint
        "mov %0, r0\n"          // Store result
        : "=r" (result)
        : "r" (reason), "r" (arg)
        : "r0", "r1", "memory"
    );
    return result;
}

// Alternative semihosting call using SVC (simplified)
static inline int cortex_m_svc_semihost_call(int reason, void* arg)
{
    int result;
    __asm volatile (
        "mov r0, %1\n"          // Load reason
        "mov r1, %2\n"          // Load argument
        "svc #0\n"              // Supervisor call (simplified)
        "mov %0, r0\n"          // Store result
        : "=r" (result)
        : "r" (reason), "r" (arg)
        : "r0", "r1", "memory"
    );
    return result;
}

// Write string using BKPT method
static void write_string_bkpt(const char* str)
{
    cortex_m_semihost_call(4, (void*)str);  // SYS_WRITE0 = 4
}

// Write string using SVC method
static void write_string_svc(const char* str)
{
    cortex_m_svc_semihost_call(4, (void*)str);  // SYS_WRITE0 = 4
}

// Exit using BKPT method
static void exit_bkpt(int code)
{
    cortex_m_semihost_call(24, &code);  // SYS_EXIT = 24
}

// Reset handler with proper Cortex-M initialization
__attribute__((naked, noreturn))
void Reset_Handler(void)
{
    __asm volatile (
        // Set up stack pointer
        "ldr sp, =0x20020000\n"
        
        // Initialize core registers
        "mov r0, #0\n"
        "mov r1, #0\n"
        "mov r2, #0\n"
        "mov r3, #0\n"
        "mov r4, #0\n"
        "mov r5, #0\n"
        "mov r6, #0\n"
        "mov r7, #0\n"
        
        // Call main
        "bl main\n"
        
        // Infinite loop if main returns
        "b .\n"
    );
}

// Complete Cortex-M vector table
__attribute__((section(".isr_vector")))
const void* vector_table[] = {
    (void*)0x20020000,          // 0: Initial stack pointer
    Reset_Handler,              // 1: Reset handler
    0,                          // 2: NMI handler
    0,                          // 3: Hard fault handler
    0,                          // 4: Memory management fault
    0,                          // 5: Bus fault handler
    0,                          // 6: Usage fault handler
    0, 0, 0, 0,                // 7-10: Reserved
    0,                          // 11: SVCall handler
    0,                          // 12: Debug monitor handler
    0,                          // 13: Reserved
    0,                          // 14: PendSV handler
    0,                          // 15: SysTick handler
};

int main(void)
{
    // Test 1: BKPT method
    write_string_bkpt("=== CORTEX-M SEMIHOSTING TEST ===\n");
    write_string_bkpt("Method 1: BKPT #0xAB - ");
    write_string_bkpt("Testing...\n");
    
    // Test 2: SVC method (alternative) - commented out for now
    // write_string_svc("Method 2: SVC call - ");
    // write_string_svc("Testing...\n");
    write_string_bkpt("Method 2: SVC call - SKIPPED (using BKPT only)\n");
    
    // Test basic functionality
    write_string_bkpt("Basic tests:\n");
    
    // Arithmetic test
    volatile int a = 30;
    volatile int b = 12;
    volatile int result = a + b;
    
    write_string_bkpt("- Arithmetic (30 + 12 = 42): ");
    if (result == 42) {
        write_string_bkpt("PASSED\n");
    } else {
        write_string_bkpt("FAILED\n");
    }
    
    // Memory test
    volatile int data[3] = {10, 20, 30};
    volatile int sum = data[0] + data[1] + data[2];
    
    write_string_bkpt("- Memory (10 + 20 + 30 = 60): ");
    if (sum == 60) {
        write_string_bkpt("PASSED\n");
    } else {
        write_string_bkpt("FAILED\n");
    }
    
    // ARM Cortex-M instruction test
    volatile unsigned int test_val = 0xF0F0F0F0;
    write_string_bkpt("- ARM instruction test: ");
    
    // Use REV instruction (byte reverse)
    __asm volatile ("rev %0, %0" : "+r" (test_val));
    __asm volatile ("rev %0, %0" : "+r" (test_val));
    
    if (test_val == 0xF0F0F0F0) {
        write_string_bkpt("PASSED\n");
    } else {
        write_string_bkpt("FAILED\n");
    }
    
    // Final message
    write_string_bkpt("\n=== TEST COMPLETED ===\n");
    write_string_bkpt("All Cortex-M semihosting tests finished.\n");
    write_string_bkpt("Attempting clean exit...\n");
    
    // Try to exit cleanly
    exit_bkpt(0);
    
    // Should not reach here
    write_string_bkpt("ERROR: Exit failed, entering loop\n");
    
    // Controlled loop
    for (volatile int i = 0; i < 10000000; i++) {
        __asm("nop");
    }
    
    // Final infinite loop
    while (1) {
        __asm("wfi");  // Wait for interrupt (low power)
    }
    
    return 0;
}