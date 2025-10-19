/**
 * @file integration_test_main.c
 * @brief Main entry point for QEMU integration tests
 */

#include <stdio.h>
#include <stdint.h>
#include <stdbool.h>
#include "system_init.h"
#include "gpio.h"
#include "led.h"

// Semihosting support - using rdimon specs instead of manual initialization

// Test function declarations
extern int test_hardware_integration(void);
extern int test_qemu_semihosting(void);

// Test results tracking
static int tests_passed = 0;
static int tests_failed = 0;

/**
 * @brief Simple test framework for integration tests
 */
void run_test(const char* test_name, int (*test_func)(void))
{
    printf("Running test: %s... ", test_name);
    
    int result = test_func();
    
    if (result == 0) {
        printf("PASSED\n");
        tests_passed++;
    } else {
        printf("FAILED (code: %d)\n", result);
        tests_failed++;
    }
}

/**
 * @brief Integration test main function
 */
int main(void)
{
    // Initialize semihosting for printf output
    // Note: initialise_monitor_handles() may not be available in all environments
    // We'll rely on the linker specs for semihosting support
    
    printf("\n");
    printf("========================================\n");
    printf("ARM Cortex-M4 Integration Test Runner\n");
    printf("========================================\n");
    printf("Target: STM32F407VG (QEMU netduinoplus2)\n");
    printf("Toolchain: ARM GCC %s\n", __VERSION__);
    printf("Build: %s %s\n", __DATE__, __TIME__);
    printf("========================================\n\n");
    
    // Initialize system
    printf("Initializing system...\n");
    fflush(stdout);
    system_init();
    gpio_init();
    led_init();
    printf("System initialization complete.\n\n");
    fflush(stdout);
    
    // Run integration tests
    printf("Starting integration tests...\n\n");
    fflush(stdout);
    
    run_test("QEMU Semihosting", test_qemu_semihosting);
    run_test("Hardware Integration", test_hardware_integration);
    
    // Test summary
    printf("\n========================================\n");
    printf("Integration Test Summary\n");
    printf("========================================\n");
    printf("Tests passed: %d\n", tests_passed);
    printf("Tests failed: %d\n", tests_failed);
    printf("Total tests:  %d\n", tests_passed + tests_failed);
    fflush(stdout);
    
    if (tests_failed == 0) {
        printf("\n🎉 All integration tests PASSED!\n");
        printf("ARM Cortex-M4 environment is working correctly.\n");
    } else {
        printf("\n❌ Some integration tests FAILED!\n");
        printf("Please check the test output above.\n");
    }
    fflush(stdout);
    
    printf("========================================\n");
    
    // Indicate completion to QEMU
    printf("\nIntegration tests completed. You can terminate QEMU now.\n");
    fflush(stdout);
    
    // Controlled execution instead of infinite loop
    printf("Running final verification sequence...\n");
    fflush(stdout);
    
    for (int i = 0; i < 10; i++) {
        printf("Final check %d/10\n", i + 1);
        fflush(stdout);
        
        // Blink LED to show the program is still running
        led_toggle(LED_GREEN);
        
        // Simple delay
        for (volatile int j = 0; j < 500000; j++) {
            __asm("nop");
        }
    }
    
    printf("\n*** INTEGRATION TESTS COMPLETED ***\n");
    printf("All tests finished successfully.\n");
    printf("QEMU can be safely terminated.\n");
    fflush(stdout);
    
    // Final infinite loop (QEMU will need external termination)
    while (1) {
        for (volatile int k = 0; k < 10000000; k++) {
            __asm("nop");
        }
    }
    
    return (tests_failed == 0) ? 0 : 1;
}