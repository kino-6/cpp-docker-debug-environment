/**
 * @file mock_led.c
 * @brief Mock implementation of LED functions for unit testing
 */

#include <stdio.h>
#include <stdint.h>
#include <stdbool.h>
#include "led.h"

// Mock LED state
static bool mock_led_initialized = false;
static led_state_t mock_led_states[LED_COUNT] = {LED_OFF};
static uint32_t mock_led_toggle_count[LED_COUNT] = {0};

// LED driver functions
void led_init(void)
{
    printf("[MOCK] led_init() called\n");
    mock_led_initialized = true;
    
    // Reset all LED states
    for (int i = 0; i < LED_COUNT; i++) {
        mock_led_states[i] = LED_OFF;
        mock_led_toggle_count[i] = 0;
    }
}

void led_set(led_id_t led, led_state_t state)
{
    if (led < LED_COUNT) {
        printf("[MOCK] led_set(%d, %s)\n", led, (state == LED_ON) ? "ON" : "OFF");
        mock_led_states[led] = state;
    }
}

void led_toggle(led_id_t led)
{
    if (led < LED_COUNT) {
        mock_led_states[led] = (mock_led_states[led] == LED_ON) ? LED_OFF : LED_ON;
        mock_led_toggle_count[led]++;
        printf("[MOCK] led_toggle(%d) -> %s (count: %u)\n", 
               led, (mock_led_states[led] == LED_ON) ? "ON" : "OFF", 
               mock_led_toggle_count[led]);
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
    printf("[MOCK] led_set_all(%s)\n", (state == LED_ON) ? "ON" : "OFF");
    for (int i = 0; i < LED_COUNT; i++) {
        mock_led_states[i] = state;
    }
}

void led_toggle_all(void)
{
    printf("[MOCK] led_toggle_all()\n");
    for (int i = 0; i < LED_COUNT; i++) {
        led_toggle(i);
    }
}

void led_knight_rider(uint32_t delay_ms, uint8_t cycles)
{
    printf("[MOCK] led_knight_rider(delay=%u, cycles=%u)\n", delay_ms, cycles);
    
    // Simulate knight rider pattern
    for (uint8_t cycle = 0; cycle < cycles; cycle++) {
        // Forward
        for (int i = 0; i < LED_COUNT; i++) {
            led_set_all(LED_OFF);
            led_set(i, LED_ON);
        }
        // Backward
        for (int i = LED_COUNT - 2; i >= 1; i--) {
            led_set_all(LED_OFF);
            led_set(i, LED_ON);
        }
    }
    
    led_set_all(LED_OFF);
}

// Mock test helper functions (already defined in mock_gpio.c, but duplicated here for completeness)
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
        return mock_led_toggle_count[led];
    }
    return 0;
}

void mock_reset_led_state(void)
{
    mock_led_initialized = false;
    for (int i = 0; i < LED_COUNT; i++) {
        mock_led_states[i] = LED_OFF;
        mock_led_toggle_count[i] = 0;
    }
}