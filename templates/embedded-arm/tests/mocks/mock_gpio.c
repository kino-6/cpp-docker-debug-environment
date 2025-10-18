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

void gpio_set_pin(uint32_t pin, bool state)
{
    if (pin < MAX_GPIO_PINS) {
        printf("[MOCK] gpio_set_pin(%u, %s)\n", pin, state ? "HIGH" : "LOW");
        mock_gpio_pin_states[pin] = state;
    }
}

void gpio_toggle_pin(uint32_t pin)
{
    if (pin < MAX_GPIO_PINS) {
        mock_gpio_pin_states[pin] = !mock_gpio_pin_states[pin];
        mock_gpio_toggle_count[pin]++;
        printf("[MOCK] gpio_toggle_pin(%u) -> %s (count: %u)\n", 
               pin, mock_gpio_pin_states[pin] ? "HIGH" : "LOW", 
               mock_gpio_toggle_count[pin]);
    }
}

bool gpio_read_pin(uint32_t pin)
{
    if (pin < MAX_GPIO_PINS) {
        return mock_gpio_pin_states[pin];
    }
    return false;
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