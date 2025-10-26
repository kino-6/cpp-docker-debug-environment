/**
 * @file led_controller.h
 * @brief LED control for ESP32
 */

#pragma once

#include "esp_err.h"

#ifdef __cplusplus
extern "C" {
#endif

// LED patterns
typedef enum {
    LED_PATTERN_OFF = 0,
    LED_PATTERN_ON,
    LED_PATTERN_FAST_BLINK,
    LED_PATTERN_SLOW_BLINK,
    LED_PATTERN_BREATHING,
    LED_PATTERN_CUSTOM
} led_pattern_t;

// LED configuration
#define LED_GPIO_PIN        2    // Built-in LED on most ESP32 boards
#define LED_BLINK_FAST_MS   200  // Fast blink interval
#define LED_BLINK_SLOW_MS   1000 // Slow blink interval

/**
 * @brief Initialize LED controller
 * @return ESP_OK on success, error code otherwise
 */
esp_err_t led_controller_init(void);

/**
 * @brief Set LED on/off
 * @param state true for on, false for off
 * @return ESP_OK on success, error code otherwise
 */
esp_err_t led_set_state(bool state);

/**
 * @brief Toggle LED state
 * @return ESP_OK on success, error code otherwise
 */
esp_err_t led_toggle(void);

/**
 * @brief Set LED pattern
 * @param pattern LED pattern to set
 * @return ESP_OK on success, error code otherwise
 */
esp_err_t led_set_pattern(led_pattern_t pattern);

/**
 * @brief Get current LED pattern
 * @return Current LED pattern
 */
led_pattern_t led_get_pattern(void);

/**
 * @brief Set custom LED pattern
 * @param on_time_ms Time LED is on (milliseconds)
 * @param off_time_ms Time LED is off (milliseconds)
 * @return ESP_OK on success, error code otherwise
 */
esp_err_t led_set_custom_pattern(uint32_t on_time_ms, uint32_t off_time_ms);

#ifdef __cplusplus
}
#endif