/**
 * @file no_semihost_test.c
 * @brief Test without any semihosting - just basic ARM execution
 */

// Simple reset handler
__attribute__((naked, noreturn))
void Reset_Handler(void)
{
    __asm volatile (
        "ldr sp, =0x20020000\n"    // Set stack pointer
        "bl main\n"                // Call main
        "b .\n"                    // Infinite loop
    );
}

// Vector table
__attribute__((section(".isr_vector")))
const void* vector_table[] = {
    (void*)0x20020000,    // Stack pointer
    Reset_Handler,        // Reset handler
};

int main(void)
{
    // Test basic ARM execution without any semihosting
    volatile int counter = 0;
    volatile int test_value = 0x12345678;
    
    // Basic arithmetic
    for (int i = 0; i < 1000; i++) {
        counter += i;
    }
    
    // ARM instruction test
    __asm volatile ("rbit %0, %0" : "+r" (test_value));
    __asm volatile ("rbit %0, %0" : "+r" (test_value));
    
    // Memory test
    volatile int array[10];
    for (int j = 0; j < 10; j++) {
        array[j] = j * j;
    }
    
    // Controlled execution - run for a specific time then stop
    for (volatile int k = 0; k < 5000000; k++) {
        __asm("nop");
    }
    
    // Infinite loop (QEMU should timeout)
    while (1) {
        counter++;
        if (counter > 1000000) {
            counter = 0;
        }
        __asm("nop");
    }
    
    return 0;
}