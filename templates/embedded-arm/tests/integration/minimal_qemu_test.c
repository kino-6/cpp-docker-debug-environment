/**
 * @file minimal_qemu_test.c
 * @brief Minimal QEMU test without complex startup code
 */

#include <stdio.h>
#include <stdint.h>

// Minimal startup - just set stack pointer and jump to main
__attribute__((naked, noreturn))
void Reset_Handler(void)
{
    // Set stack pointer to end of RAM
    __asm volatile (
        "ldr sp, =0x20020000\n"  // End of 128KB RAM
        "bl main\n"              // Jump to main
        "b .\n"                  // Infinite loop if main returns
    );
}

// Minimal vector table
__attribute__((section(".isr_vector")))
const uint32_t vector_table[] = {
    0x20020000,                 // Initial stack pointer (end of RAM)
    (uint32_t)Reset_Handler,    // Reset handler
};

/**
 * @brief Minimal main function for QEMU testing
 */
int main(void)
{
    // Test basic functionality without complex initialization
    printf("Minimal QEMU Test Starting...\n");
    printf("ARM Cortex-M4 is working!\n");
    
    // Test basic arithmetic
    volatile int result = 21 * 2;
    printf("Arithmetic test: 21 * 2 = %d\n", result);
    
    if (result == 42) {
        printf("✅ SUCCESS: ARM Cortex-M4 execution confirmed!\n");
    } else {
        printf("❌ FAILED: Arithmetic error\n");
    }
    
    // Test memory access
    volatile uint32_t test_data[4] = {0x11111111, 0x22222222, 0x33333333, 0x44444444};
    uint32_t sum = 0;
    
    for (int i = 0; i < 4; i++) {
        sum += test_data[i];
    }
    
    printf("Memory test: sum = 0x%08lX\n", (unsigned long)sum);
    
    // Test ARM instruction
    volatile uint32_t test_val = 0x12345678;
    __asm volatile ("rbit %0, %0" : "+r" (test_val));
    printf("RBIT instruction test: 0x12345678 -> 0x%08lX\n", (unsigned long)test_val);
    
    printf("🎉 Minimal QEMU test completed!\n");
    printf("QEMU can be terminated now.\n");
    
    // Simple blink pattern
    for (int i = 0; i < 10; i++) {
        printf("Heartbeat %d/10\n", i + 1);
        
        // Simple delay
        for (volatile int j = 0; j < 500000; j++) {
            __asm("nop");
        }
    }
    
    printf("Test sequence finished.\n");
    
    // Infinite loop
    while (1) {
        for (volatile int k = 0; k < 1000000; k++) {
            __asm("nop");
        }
    }
    
    return 0;
}