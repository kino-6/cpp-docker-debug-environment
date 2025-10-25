/**
 * @file mock_gpio.c
 * @brief Mock implementation of GPIO functions for unit testing
 */

#include <stdio.h>
#include <stdint.h>
#include <stdbool.h>

// Mock GPIO state
#define MAX_GPIO_PINS 16
static bool mock_gpio_initialized = false;
static bool mock_gpio_pin_states[MAX_GPIO_PINS] = {false};
static uint32_t mock_gpio_toggle_count[MAX_GPIO_PINS] = {0};

// Mock GPIO functions
void gpio_init(void)
{
    printf("[MOCK] gpio_init() called\n");
    mock_gpio_initialized = true;
    
    // Reset all pin states
    for (int i = 0; i < MAX_GPIO_PINS; i++) {
        mock_gpio_pin_states[i] = false;
        mock_gpio_toggle_count[i] = 0;
    }
}

void gpio_set_pin(uint32_t gpio_base, uint8_t pin)
{
    if (pin < MAX_GPIO_PINS) {
        printf("[MOCK] gpio_set_pin(0x%08X, %u) -> HIGH\n", gpio_base, pin);
        mock_gpio_pin_states[pin] = true;
    }
}

void gpio_clear_pin(uint32_t gpio_base, uint8_t pin)
{
    if (pin < MAX_GPIO_PINS) {
        printf("[MOCK] gpio_clear_pin(0x%08X, %u) -> LOW\n", gpio_base, pin);
        mock_gpio_pin_states[pin] = false;
    }
}

void gpio_toggle_pin(uint32_t gpio_base, uint8_t pin)
{
    if (pin < MAX_GPIO_PINS) {
        mock_gpio_pin_states[pin] = !mock_gpio_pin_states[pin];
        mock_gpio_toggle_count[pin]++;
        printf("[MOCK] gpio_toggle_pin(0x%08X, %u) -> %s (count: %u)\n", 
               gpio_base, pin, mock_gpio_pin_states[pin] ? "HIGH" : "LOW", 
               mock_gpio_toggle_count[pin]);
    }
}

uint8_t gpio_read_pin(uint32_t gpio_base, uint8_t pin)
{
    if (pin < MAX_GPIO_PINS) {
        return mock_gpio_pin_states[pin] ? 1 : 0;
    }
    return 0;
}

// Mock test helper functions
bool mock_is_gpio_initialized(void)
{
    return mock_gpio_initialized;
}

bool mock_get_gpio_pin_state(uint32_t pin)
{
    if (pin < MAX_GPIO_PINS) {
        return mock_gpio_pin_states[pin];
    }
    return false;
}

uint32_t mock_get_gpio_toggle_count(uint32_t pin)
{
    if (pin < MAX_GPIO_PINS) {
        return mock_gpio_toggle_count[pin];
    }
    return 0;
}

void mock_reset_gpio_state(void)
{
    mock_gpio_initialized = false;
    for (int i = 0; i < MAX_GPIO_PINS; i++) {
        mock_gpio_pin_states[i] = false;
        mock_gpio_toggle_count[i] = 0;
    }
}

// Include LED header for types
#include "led.h"

// Mock LED state
static bool mock_led_initialized = false;
static led_state_t mock_led_states[LED_COUNT] = {LED_OFF};
static uint32_t mock_led_toggle_count[LED_COUNT] = {0};

// Mock LED test helper functions
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