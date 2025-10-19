/**
 * @file official_semihost_sample.c
 * @brief ARM Official Semihosting Sample
 * Based on ARM official documentation and examples
 */

#include <stdio.h>
#include <stdlib.h>

// ARM official semihosting implementation
// Based on ARM DUI 0471M documentation

// Reset handler - ARM official pattern
__attribute__((naked, noreturn))
void Reset_Handler(void)
{
    __asm volatile (
        "ldr sp, =0x20020000\n"    // Set stack pointer
        "bl main\n"                // Call main
        "b .\n"                    // Infinite loop
    );
}

// Vector table - ARM Cortex-M standard
__attribute__((section(".isr_vector")))
const void* vector_table[] = {
    (void*)0x20020000,    // Initial stack pointer
    Reset_Handler,        // Reset handler
};

/**
 * @brief ARM Official Semihosting Sample
 * This follows ARM's official semihosting examples
 */
int main(void)
{
    // ARM official semihosting test sequence
    printf("ARM Official Semihosting Test\n");
    printf("============================\n");
    
    // Test 1: Basic output
    printf("Test 1: Basic printf output\n");
    
    // Test 2: Formatted output
    int value = 42;
    printf("Test 2: Formatted output - value = %d\n", value);
    
    // Test 3: Multiple data types
    float pi = 3.14159f;
    printf("Test 3: Float output - pi = %.3f\n", pi);
    
    // Test 4: String output
    const char* message = "Hello ARM Cortex-M4";
    printf("Test 4: String output - %s\n", message);
    
    printf("============================\n");
    printf("All tests completed successfully\n");
    printf("Exiting with code 0\n");
    
    // ARM official exit
    exit(0);
    
    return 0;
}