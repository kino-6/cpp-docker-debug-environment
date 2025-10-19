/**
 * @file simple_working_test.c
 * @brief Simple test that should definitely work
 */

// Simple semihosting write
static void simple_write(const char* str)
{
    __asm volatile (
        "mov r0, #4\n"          // SYS_WRITE0
        "mov r1, %0\n"          // String pointer
        "bkpt #0xAB\n"          // Semihosting breakpoint
        :
        : "r" (str)
        : "r0", "r1"
    );
}

// Simple semihosting exit
static void simple_exit(void)
{
    int code = 0;
    __asm volatile (
        "mov r0, #24\n"         // SYS_EXIT
        "mov r1, %0\n"          // Exit code pointer
        "bkpt #0xAB\n"          // Semihosting breakpoint
        :
        : "r" (&code)
        : "r0", "r1"
    );
}

// Simple reset handler
__attribute__((naked, noreturn))
void Reset_Handler(void)
{
    __asm volatile (
        "ldr sp, =0x20020000\n"
        "bl main\n"
        "b .\n"
    );
}

// Simple vector table
__attribute__((section(".isr_vector")))
const void* vector_table[] = {
    (void*)0x20020000,
    Reset_Handler,
};

int main(void)
{
    simple_write("SIMPLE TEST: Hello from ARM Cortex-M4!\n");
    simple_write("If you see this, semihosting is working!\n");
    simple_write("Testing basic functionality...\n");
    
    // Simple test
    volatile int x = 21;
    volatile int y = 21;
    volatile int z = x + y;
    
    if (z == 42) {
        simple_write("Math test: PASSED (21 + 21 = 42)\n");
    } else {
        simple_write("Math test: FAILED\n");
    }
    
    simple_write("Test completed successfully!\n");
    simple_write("Attempting to exit...\n");
    
    simple_exit();
    
    // Should not reach here
    while (1) {
        __asm("nop");
    }
    
    return 0;
}