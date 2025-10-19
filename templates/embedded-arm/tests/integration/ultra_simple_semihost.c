/**
 * @file ultra_simple_semihost.c
 * @brief Ultra Simple Semihosting Test - Absolute Minimal Implementation
 */

// Ultra minimal semihosting implementation
static inline void semihost_write0(const char* str)
{
    __asm volatile (
        "mov r0, #4\n"          // SYS_WRITE0
        "mov r1, %0\n"          // String pointer
        "bkpt #0xAB\n"          // ARM semihosting breakpoint
        :
        : "r" (str)
        : "r0", "r1", "memory"
    );
}

static inline void semihost_exit(int status)
{
    __asm volatile (
        "mov r0, #24\n"         // SYS_EXIT
        "mov r1, %0\n"          // Status pointer
        "bkpt #0xAB\n"          // ARM semihosting breakpoint
        :
        : "r" (&status)
        : "r0", "r1", "memory"
    );
}

// Minimal vector table
__attribute__((section(".isr_vector")))
const void* vector_table[] = {
    (void*)0x20020000,          // Initial stack pointer
    (void*)0x08000009,          // Reset handler (thumb mode)
};

// Reset handler - ultra minimal
__attribute__((naked, noreturn))
void Reset_Handler(void)
{
    // Set stack pointer
    __asm volatile ("ldr sp, =0x20020000");
    
    // Call main
    __asm volatile ("bl main");
    
    // Infinite loop
    __asm volatile ("b .");
}

int main(void)
{
    // Test 1: Simple message
    semihost_write0("ULTRA SIMPLE TEST START\n");
    
    // Test 2: Multiple messages
    semihost_write0("Message 1: Hello World\n");
    semihost_write0("Message 2: Semihosting Works\n");
    semihost_write0("Message 3: Test Complete\n");
    
    // Test 3: Final message
    semihost_write0("ULTRA SIMPLE TEST END\n");
    
    // Clean exit
    semihost_exit(0);
    
    // Should never reach here
    while (1) {
        __asm("nop");
    }
    
    return 0;
}