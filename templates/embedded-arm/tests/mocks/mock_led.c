/**
 * @file mock_led.c
 * @brief Mock implementation of LED driver for unit testing
 */

#include <stdio.h>
#include <stdint.h>
#include <stdbool.h>
#include "led.h"
#include "mock_hal.h"

// Mock LED state tracking
static bool mock_led_initialized = false;
static led_state_t mock_led_states[LED_COUNT] = {LED_OFF};
static uint32_t mock_led_toggle_counts[LED_COUNT] = {0};

// LED pin mapping (STM32F4-Discovery)
static const uint32_t led_pins[LED_COUNT] = {
    12,  // LED_GREEN  (PD12)
    13,  // LED_ORANGE (PD13)
    14,  // LED_RED    (PD14)
    15   // LED_BLUE   (PD15)
};

// Mock LED driver functions
void led_init(void)
{
    printf("[MOCK] led_init() called\n");
    mock_led_initialized = true;
    
    // Initialize all LEDs to OFF state
    for (int i = 0; i < LED_COUNT; i++) {
        mock_led_states[i] = LED_OFF;
        mock_led_toggle_counts[i] = 0;
    }
    
    // Initialize GPIO for LEDs (mock)
    gpio_init();
}

void led_set(led_id_t led, led_state_t state)
{
    if (led < LED_COUNT) {
        printf("[MOCK] led_set(%d, %s)\n", led, state == LED_ON ? "ON" : "OFF");
        mock_led_states[led] = state;
        
        // Update GPIO pin state (mock)
        #define GPIOD_BASE 0x40020C00
        if (state == LED_ON) {
            gpio_set_pin(GPIOD_BASE, led_pins[led]);
        } else {
            gpio_clear_pin(GPIOD_BASE, led_pins[led]);
        }
    }
}

void led_toggle(led_id_t led)
{
    if (led < LED_COUNT) {
        mock_led_states[led] = (mock_led_states[led] == LED_ON) ? LED_OFF : LED_ON;
        mock_led_toggle_counts[led]++;
        
        printf("[MOCK] led_toggle(%d) -> %s (count: %u)\n", 
               led, mock_led_states[led] == LED_ON ? "ON" : "OFF", 
               mock_led_toggle_counts[led]);
        
        // Update GPIO pin state (mock)
        #define GPIOD_BASE 0x40020C00
        gpio_toggle_pin(GPIOD_BASE, led_pins[led]);
    }
}

led_state_t led_get(led_id_t led)
{
    if (led < LED_COUNT) {
        return mock_led_states[led];
    }
    return LED_OFF;
}

void led_set_all(led_state_t state)
{
    printf("[MOCK] led_set_all(%s)\n", state == LED_ON ? "ON" : "OFF");
    for (int i = 0; i < LED_COUNT; i++) {
        led_set((led_id_t)i, state);
    }
}

void led_toggle_all(void)
{
    printf("[MOCK] led_toggle_all()\n");
    for (int i = 0; i < LED_COUNT; i++) {
        led_toggle((led_id_t)i);
    }
}

void led_knight_rider(uint32_t delay_ms_param, uint8_t cycles)
{
    printf("[MOCK] led_knight_rider(delay=%u, cycles=%u)\n", delay_ms_param, cycles);
    
    for (uint8_t cycle = 0; cycle < cycles; cycle++) {
        // Forward sweep
        for (int i = 0; i < LED_COUNT; i++) {
            led_set_all(LED_OFF);
            led_set((led_id_t)i, LED_ON);
            delay_ms(delay_ms_param);
        }
        
        // Backward sweep
        for (int i = LED_COUNT - 2; i >= 1; i--) {
            led_set_all(LED_OFF);
            led_set((led_id_t)i, LED_ON);
            delay_ms(delay_ms_param);
        }
    }
    
    led_set_all(LED_OFF);
}

// Mock test helper functions
bool mock_is_led_initialized(void)
{
    return mock_led_initialized;
}

led_state_t mock_get_led_state(led_id_t led)
{
    if (led < LED_COUNT) {
        return mock_led_states[led];
    }
    return LED_OFF;
}

uint32_t mock_get_led_toggle_count(led_id_t led)
{
    if (led < LED_COUNT) {
        return mock_led_toggle_counts[led];
    }
    return 0;
}

void mock_reset_led_state(void)
{
    mock_led_initialized = false;
    for (int i = 0; i < LED_COUNT; i++) {
        mock_led_states[i] = LED_OFF;
        mock_led_toggle_counts[i] = 0;
    }
}