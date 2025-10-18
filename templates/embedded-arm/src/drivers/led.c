/**
 * @file led.c
 * @brief LED driver for STM32F4-Discovery board
 * @author Embedded Development Template
 */

#include "led.h"
#include "gpio.h"

// GPIO port base for LEDs
#define LED_GPIO_BASE       0x40020C00UL  // GPIOD

// LED pin definitions (STM32F4-Discovery)
#define LED_GREEN_PIN       12
#define LED_ORANGE_PIN      13
#define LED_RED_PIN         14
#define LED_BLUE_PIN        15

/**
 * @brief Get pin number for LED
 * @param led LED identifier
 * @return Pin number or 0xFF if invalid
 */
static uint8_t led_get_pin(led_id_t led)
{
    switch (led) {
        case LED_GREEN:  return LED_GREEN_PIN;
        case LED_ORANGE: return LED_ORANGE_PIN;
        case LED_RED:    return LED_RED_PIN;
        case LED_BLUE:   return LED_BLUE_PIN;
        default:         return 0xFF;  // Invalid LED
    }
}

/**
 * @brief Initialize LED driver
 */
void led_init(void)
{
    // GPIO initialization is handled by gpio_init()
    // Turn off all LEDs initially
    led_set(LED_GREEN, LED_OFF);
    led_set(LED_ORANGE, LED_OFF);
    led_set(LED_RED, LED_OFF);
    led_set(LED_BLUE, LED_OFF);
}

/**
 * @brief Set LED state
 * @param led LED identifier
 * @param state LED state (LED_ON or LED_OFF)
 */
void led_set(led_id_t led, led_state_t state)
{
    uint8_t pin = led_get_pin(led);
    if (pin == 0xFF) {
        return;  // Invalid LED
    }
    
    if (state == LED_ON) {
        gpio_set_pin(LED_GPIO_BASE, pin);
    } else {
        gpio_clear_pin(LED_GPIO_BASE, pin);
    }
}

/**
 * @brief Toggle LED state
 * @param led LED identifier
 */
void led_toggle(led_id_t led)
{
    uint8_t pin = led_get_pin(led);
    if (pin == 0xFF) {
        return;  // Invalid LED
    }
    
    gpio_toggle_pin(LED_GPIO_BASE, pin);
}

/**
 * @brief Get LED state
 * @param led LED identifier
 * @return LED state (LED_ON or LED_OFF)
 */
led_state_t led_get(led_id_t led)
{
    uint8_t pin = led_get_pin(led);
    if (pin == 0xFF) {
        return LED_OFF;  // Invalid LED
    }
    
    return gpio_read_pin(LED_GPIO_BASE, pin) ? LED_ON : LED_OFF;
}

/**
 * @brief Set all LEDs to specified state
 * @param state LED state (LED_ON or LED_OFF)
 */
void led_set_all(led_state_t state)
{
    led_set(LED_GREEN, state);
    led_set(LED_ORANGE, state);
    led_set(LED_RED, state);
    led_set(LED_BLUE, state);
}

/**
 * @brief Toggle all LEDs
 */
void led_toggle_all(void)
{
    led_toggle(LED_GREEN);
    led_toggle(LED_ORANGE);
    led_toggle(LED_RED);
    led_toggle(LED_BLUE);
}

/**
 * @brief LED test pattern - Knight Rider effect
 * @param delay_ms Delay between steps in milliseconds
 * @param cycles Number of cycles to run
 */
void led_knight_rider(uint32_t delay_ms, uint8_t cycles)
{
    // This function would need a delay implementation
    // For now, it's a placeholder for future enhancement
    (void)delay_ms;
    (void)cycles;
    
    // Simple pattern for demonstration
    for (uint8_t i = 0; i < cycles; i++) {
        led_set_all(LED_OFF);
        led_set(LED_GREEN, LED_ON);
        // delay_ms would be called here
        
        led_set_all(LED_OFF);
        led_set(LED_ORANGE, LED_ON);
        // delay_ms would be called here
        
        led_set_all(LED_OFF);
        led_set(LED_RED, LED_ON);
        // delay_ms would be called here
        
        led_set_all(LED_OFF);
        led_set(LED_BLUE, LED_ON);
        // delay_ms would be called here
    }
    
    led_set_all(LED_OFF);
}