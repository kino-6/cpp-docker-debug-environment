/**
 * @file main.c
 * @brief ARM Cortex-M4 LED Blink Demo
 * @author Embedded Development Template
 * @version 1.0.0
 * 
 * Simple LED blink application for ARM Cortex-M4 (STM32F407VG)
 * Demonstrates basic GPIO control and system initialization
 */

#include <stdint.h>
#include <stdbool.h>
#include "system_init.h"
#include "gpio.h"
#include "led.h"

// System configuration
#define SYSTEM_CLOCK_HZ     168000000UL  // 168 MHz
#define LED_BLINK_DELAY_MS  500          // 500ms blink interval

/**
 * @brief Simple delay function (blocking)
 * @param ms Delay in milliseconds
 * @note This is a simple delay for demonstration purposes
 *       In production code, use timer-based delays or RTOS
 */
static void delay_ms(uint32_t ms)
{
    // Approximate delay calculation for 168MHz CPU
    // This is not accurate but sufficient for LED blink demo
    volatile uint32_t count = ms * (SYSTEM_CLOCK_HZ / 4000);
    while (count--) {
        __asm("nop");
    }
}

/**
 * @brief Application main function
 * @return Should never return in embedded applications
 */
int main(void)
{
    // Initialize system clock and peripherals
    system_init();
    
    // Initialize GPIO for LED control
    gpio_init();
    
    // Initialize LED driver
    led_init();
    
    // Turn on LED to indicate system is running
    led_set(LED_GREEN, LED_ON);
    delay_ms(100);
    led_set(LED_GREEN, LED_OFF);
    
    // Main application loop
#ifdef UNIT_TEST
    // For unit testing, run limited iterations instead of infinite loop
    volatile uint32_t debug_counter = 0;
    for (int test_iterations = 0; test_iterations < 16; test_iterations++) {
        // Blink green LED
        led_toggle(LED_GREEN);
        delay_ms(LED_BLINK_DELAY_MS);
        
        debug_counter++; // ← Set breakpoint here for debugging
        
        // Blink red LED with different pattern
        if (debug_counter % 4 == 0) {
            led_toggle(LED_RED);
        }
        
        // Blink blue LED with another pattern
        if (debug_counter % 8 == 0) {
            led_toggle(LED_BLUE);
        }
    }
#else
    // Normal embedded operation - infinite loop
    while (1) {
        // Blink green LED
        led_toggle(LED_GREEN);
        delay_ms(LED_BLINK_DELAY_MS);
        
        // Optional: Add breakpoint here for debugging
        // You can set a breakpoint on the next line to observe LED state
        volatile uint32_t debug_counter = 0;
        debug_counter++; // ← Set breakpoint here for debugging
        
        // Blink red LED with different pattern
        if (debug_counter % 4 == 0) {
            led_toggle(LED_RED);
        }
        
        // Blink blue LED with another pattern
        if (debug_counter % 8 == 0) {
            led_toggle(LED_BLUE);
        }
    }
#endif
    
    // Should never reach here
    return 0;
}