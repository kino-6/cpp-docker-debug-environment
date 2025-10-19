/**
 * @file minimal_semihost_test.c
 * @brief Absolute minimal semihosting test
 */

// Minimal semihosting call
static inline void semihost_write0(const char* str)
{
    __asm volatile (
        "mov r0, #4\n"          // SYS_WRITE0 = 4
        "mov r1, %0\n"          // String pointer
        "bkpt #0xAB\n"          // ARM semihosting breakpoint
        :
        : "r" (str)
        : "r0", "r1"
    );
}

// Minimal exit
static inline void semihost_exit(int code)
{
    __asm volatile (
        "mov r0, #24\n"         // SYS_EXIT = 0x18 = 24
        "mov r1, %0\n"          // Exit code pointer
        "bkpt #0xAB\n"          // ARM semihosting breakpoint
        :
        : "r" (&code)
        : "r0", "r1"
    );
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

// Minimal vector table
__attribute__((section(".isr_vector")))
const void* vector_table[] = {
    (void*)0x20020000,
    Reset_Handler,
};

int main(void)
{
    semihost_write0("MINIMAL TEST START\n");
    semihost_write0("If you see this, basic semihosting works!\n");
    semihost_write0("Testing exit...\n");
    
    semihost_exit(0);
    
    // Should not reach here
    while (1) {
        __asm("nop");
    }
    
    return 0;
}