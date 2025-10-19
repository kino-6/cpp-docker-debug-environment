/**
 * @file mock_hal.h
 * @brief Mock HAL interface for unit testing
 */

#ifndef MOCK_HAL_H
#define MOCK_HAL_H

#include <stdint.h>
#include <stdbool.h>
#include "led.h"

#ifdef __cplusplus
extern "C" {
#endif

// Mock HAL functions
void system_init(void);
void gpio_init(void);
void gpio_set_pin(uint32_t gpio_base, uint8_t pin);
void gpio_clear_pin(uint32_t gpio_base, uint8_t pin);
void gpio_toggle_pin(uint32_t gpio_base, uint8_t pin);
uint8_t gpio_read_pin(uint32_t gpio_base, uint8_t pin);
void delay_ms(uint32_t ms);
uint32_t get_system_tick(void);

// Mock test helper functions
bool mock_is_system_initialized(void);
uint32_t mock_get_system_clock(void);
void mock_reset_system_state(void);

bool mock_is_gpio_initialized(void);
bool mock_get_gpio_pin_state(uint32_t pin);
uint32_t mock_get_gpio_toggle_count(uint32_t pin);
void mock_reset_gpio_state(void);

void mock_advance_system_tick(uint32_t ticks);
void mock_reset_system_tick(void);

// Mock LED test helper functions
bool mock_is_led_initialized(void);
led_state_t mock_get_led_state(led_id_t led);
uint32_t mock_get_led_toggle_count(led_id_t led);
void mock_reset_led_state(void);

#ifdef __cplusplus
}
#endif

#endif // MOCK_HAL_H