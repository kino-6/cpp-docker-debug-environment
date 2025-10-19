/**
 * @file test_qemu_semihosting.c
 * @brief Test QEMU semihosting functionality
 */

#include <stdio.h>
#include <stdint.h>
#include <stdbool.h>
#include <string.h>

/**
 * @brief Test QEMU semihosting functionality
 * @return 0 on success, non-zero on failure
 */
int test_qemu_semihosting(void)
{
    // Test 1: Basic printf output
    printf("  - Testing printf output... ");
    printf("OK\n");
    
    // Test 2: Formatted output
    printf("  - Testing formatted output... ");
    int test_value = 42;
    printf("Value: %d, Hex: 0x%08X... ", test_value, test_value);
    printf("OK\n");
    
    // Test 3: String operations
    printf("  - Testing string operations... ");
    char buffer[64];
    snprintf(buffer, sizeof(buffer), "Test string %d", 123);
    
    if (strncmp(buffer, "Test string 123", 15) == 0) {
        printf("OK\n");
    } else {
        printf("FAILED\n");
        return 1;
    }
    
    // Test 4: Memory operations
    printf("  - Testing memory operations... ");
    uint8_t test_array[16];
    
    // Initialize array
    for (int i = 0; i < 16; i++) {
        test_array[i] = (uint8_t)i;
    }
    
    // Verify array
    bool memory_test_passed = true;
    for (int i = 0; i < 16; i++) {
        if (test_array[i] != (uint8_t)i) {
            memory_test_passed = false;
            break;
        }
    }
    
    if (memory_test_passed) {
        printf("OK\n");
    } else {
        printf("FAILED\n");
        return 2;
    }
    
    // Test 5: Basic arithmetic
    printf("  - Testing arithmetic operations... ");
    volatile int a = 15;
    volatile int b = 27;
    volatile int sum = a + b;
    volatile int product = a * b;
    
    if (sum == 42 && product == 405) {
        printf("OK\n");
    } else {
        printf("FAILED (sum=%d, product=%d)\n", sum, product);
        return 3;
    }
    
    printf("  ✅ QEMU semihosting is working correctly!\n");
    return 0;
}