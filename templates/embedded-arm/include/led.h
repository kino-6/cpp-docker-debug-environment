/**
 * @file led.h
 * @brief LED driver header for STM32F4-Discovery board
 * @author Embedded Development Template
 */

#ifndef LED_H
#define LED_H

#include <stdint.h>

#ifdef __cplusplus
extern "C" {
#endif

/**
 * @brief LED identifiers
 */
typedef enum {
    LED_GREEN = 0,
    LED_ORANGE,
    LED_RED,
    LED_BLUE,
    LED_COUNT
} led_id_t;

/**
 * @brief LED states
 */
typedef enum {
    LED_OFF = 0,
    LED_ON = 1
} led_state_t;

/**
 * @brief Initialize LED driver
 */
void led_init(void);

/**
 * @brief Set LED state
 * @param led LED identifier
 * @param state LED state (LED_ON or LED_OFF)
 */
void led_set(led_id_t led, led_state_t state);

/**
 * @brief Toggle LED state
 * @param led LED identifier
 */
void led_toggle(led_id_t led);

/**
 * @brief Get LED state
 * @param led LED identifier
 * @return LED state (LED_ON or LED_OFF)
 */
led_state_t led_get(led_id_t led);

/**
 * @brief Set all LEDs to specified state
 * @param state LED state (LED_ON or LED_OFF)
 */
void led_set_all(led_state_t state);

/**
 * @brief Toggle all LEDs
 */
void led_toggle_all(void);

/**
 * @brief LED test pattern - Knight Rider effect
 * @param delay_ms Delay between steps in milliseconds
 * @param cycles Number of cycles to run
 */
void led_knight_rider(uint32_t delay_ms, uint8_t cycles);

#ifdef __cplusplus
}
#endif

#endif /* LED_H */