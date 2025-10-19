/**
 * @file simple_official_sample.c
 * @brief Simple ARM Official Semihosting Sample (nosys.specs compatible)
 */

// Simple semihosting without stdio dependencies
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

// SYS_WRITE0 - write null-terminated string
static void semihost_write0(const char* str)
{
    semihost_call(4, (void*)str);
}

// SYS_EXIT - exit with status
static void semihost_exit(int status)
{
    semihost_call(24, &status);
}

// Reset handler
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
    (void*)0x20020000,
    Reset_Handler,
};

int main(void)
{
    semihost_write0("ARM Official Simple Semihosting Test\n");
    semihost_write0("====================================\n");
    semihost_write0("Test 1: Basic string output - PASSED\n");
    semihost_write0("Test 2: Multiple calls - PASSED\n");
    semihost_write0("Test 3: Program flow - PASSED\n");
    semihost_write0("====================================\n");
    semihost_write0("All tests completed successfully!\n");
    semihost_write0("Attempting clean exit...\n");
    
    semihost_exit(0);
    
    // Should not reach here
    while (1) {
        __asm("nop");
    }
    
    return 0;
}