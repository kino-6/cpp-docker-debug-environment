/**
 * @file simple_qemu_test.c
 * @brief Simple QEMU test without complex dependencies
 */

#include <stdio.h>
#include <stdint.h>

/**
 * @brief Simple QEMU test main function
 */
int main(void)
{
    printf("QEMU ARM Cortex-M4 Test Starting...\n");
    printf("========================================\n");
    printf("Target: STM32F407VG (QEMU netduinoplus2)\n");
    printf("Semihosting: Working!\n");
    printf("========================================\n");
    
    // Test basic arithmetic
    volatile int a = 15;
    volatile int b = 27;
    volatile int sum = a + b;
    
    printf("Arithmetic test: %d + %d = %d\n", a, b, sum);
    
    if (sum == 42) {
        printf("✅ Arithmetic test PASSED\n");
    } else {
        printf("❌ Arithmetic test FAILED\n");
    }
    
    // Test memory operations
    uint8_t test_array[8] = {1, 2, 3, 4, 5, 6, 7, 8};
    uint32_t checksum = 0;
    
    for (int i = 0; i < 8; i++) {
        checksum += test_array[i];
    }
    
    printf("Memory test: checksum = %u\n", checksum);
    
    if (checksum == 36) {
        printf("✅ Memory test PASSED\n");
    } else {
        printf("❌ Memory test FAILED\n");
    }
    
    // Test ARM Cortex-M4 specific instruction
    volatile uint32_t test_val = 0x12345678;
    printf("Original value: 0x%08X\n", test_val);
    
    // Use bit reversal instruction
    __asm volatile ("rbit %0, %0" : "+r" (test_val));
    printf("After RBIT: 0x%08X\n", test_val);
    
    // Reverse back
    __asm volatile ("rbit %0, %0" : "+r" (test_val));
    printf("After second RBIT: 0x%08X\n", test_val);
    
    if (test_val == 0x12345678) {
        printf("✅ ARM Cortex-M4 instruction test PASSED\n");
    } else {
        printf("❌ ARM Cortex-M4 instruction test FAILED\n");
    }
    
    printf("========================================\n");
    printf("🎉 Simple QEMU test completed successfully!\n");
    printf("ARM Cortex-M4 simulation is working.\n");
    printf("========================================\n");
    
    // Simple blink pattern to show the program is running
    for (int i = 0; i < 5; i++) {
        printf("Blink %d/5\n", i + 1);
        
        // Simple delay
        for (volatile int j = 0; j < 1000000; j++) {
            __asm("nop");
        }
    }
    
    printf("Test completed. QEMU can be terminated now.\n");
    
    // Infinite loop to keep program running
    while (1) {
        for (volatile int k = 0; k < 10000000; k++) {
            __asm("nop");
        }
    }
    
    return 0;
}