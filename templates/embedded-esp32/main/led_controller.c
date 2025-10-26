/**
 * @file led_controller.c
 * @brief LED control implementation for ESP32
 */

#include "led_controller.h"
#include "driver/gpio.h"
#include "esp_timer.h"
#include "esp_log.h"
#include "freertos/FreeRTOS.h"
#include "freertos/task.h"

static const char *TAG = "LED_CONTROLLER";

// LED state
static bool s_led_state = false;
static led_pattern_t s_current_pattern = LED_PATTERN_OFF;
static esp_timer_handle_t s_led_timer = NULL;
static uint32_t s_custom_on_time = 500;
static uint32_t s_custom_off_time = 500;

// Breathing effect variables
static bool s_breathing_direction = true; // true = increasing, false = decreasing
static uint8_t s_breathing_level = 0;

/**
 * @brief LED timer callback
 */
static void led_timer_callback(void* arg)
{
    switch (s_current_pattern) {
        case LED_PATTERN_FAST_BLINK:
        case LED_PATTERN_SLOW_BLINK:
        case LED_PATTERN_CUSTOM:
            led_toggle();
            break;
            
        case LED_PATTERN_BREATHING:
            // Simple breathing effect simulation
            if (s_breathing_direction) {
                s_breathing_level += 10;
                if (s_breathing_level >= 100) {
                    s_breathing_direction = false;
                }
            } else {
                s_breathing_level -= 10;
                if (s_breathing_level <= 0) {
                    s_breathing_direction = true;
                }
            }
            
            // Simple on/off approximation of breathing
            led_set_state(s_breathing_level > 50);
            break;
            
        default:
            break;
    }
}

/**
 * @brief Start LED timer with specified interval
 */
static esp_err_t led_start_timer(uint32_t interval_ms)
{
    if (s_led_timer != NULL) {
        esp_timer_stop(s_led_timer);
    }
    
    esp_timer_create_args_t timer_args = {
        .callback = led_timer_callback,
        .arg = NULL,
        .name = "led_timer"
    };
    
    esp_err_t ret = esp_timer_create(&timer_args, &s_led_timer);
    if (ret != ESP_OK) {
        ESP_LOGE(TAG, "Failed to create LED timer: %s", esp_err_to_name(ret));
        return ret;
    }
    
    ret = esp_timer_start_periodic(s_led_timer, interval_ms * 1000); // Convert to microseconds
    if (ret != ESP_OK) {
        ESP_LOGE(TAG, "Failed to start LED timer: %s", esp_err_to_name(ret));
        return ret;
    }
    
    return ESP_OK;
}

/**
 * @brief Stop LED timer
 */
static void led_stop_timer(void)
{
    if (s_led_timer != NULL) {
        esp_timer_stop(s_led_timer);
        esp_timer_delete(s_led_timer);
        s_led_timer = NULL;
    }
}

esp_err_t led_controller_init(void)
{
    ESP_LOGI(TAG, "Initializing LED controller...");
    
    // Configure GPIO
    gpio_config_t io_conf = {
        .intr_type = GPIO_INTR_DISABLE,
        .mode = GPIO_MODE_OUTPUT,
        .pin_bit_mask = (1ULL << LED_GPIO_PIN),
        .pull_down_en = 0,
        .pull_up_en = 0,
    };
    
    esp_err_t ret = gpio_config(&io_conf);
    if (ret != ESP_OK) {
        ESP_LOGE(TAG, "Failed to configure LED GPIO: %s", esp_err_to_name(ret));
        return ret;
    }
    
    // Set initial state (off)
    gpio_set_level(LED_GPIO_PIN, 0);
    s_led_state = false;
    
    ESP_LOGI(TAG, "LED controller initialized (GPIO %d)", LED_GPIO_PIN);
    return ESP_OK;
}

esp_err_t led_set_state(bool state)
{
    esp_err_t ret = gpio_set_level(LED_GPIO_PIN, state ? 1 : 0);
    if (ret == ESP_OK) {
        s_led_state = state;
    }
    return ret;
}

esp_err_t led_toggle(void)
{
    return led_set_state(!s_led_state);
}

esp_err_t led_set_pattern(led_pattern_t pattern)
{
    ESP_LOGI(TAG, "Setting LED pattern: %d", pattern);
    
    // Stop current timer
    led_stop_timer();
    
    s_current_pattern = pattern;
    
    switch (pattern) {
        case LED_PATTERN_OFF:
            led_set_state(false);
            break;
            
        case LED_PATTERN_ON:
            led_set_state(true);
            break;
            
        case LED_PATTERN_FAST_BLINK:
            led_start_timer(LED_BLINK_FAST_MS);
            break;
            
        case LED_PATTERN_SLOW_BLINK:
            led_start_timer(LED_BLINK_SLOW_MS);
            break;
            
        case LED_PATTERN_BREATHING:
            s_breathing_level = 0;
            s_breathing_direction = true;
            led_start_timer(100); // 100ms for breathing effect
            break;
            
        case LED_PATTERN_CUSTOM:
            // Use average of on/off time for timer interval
            led_start_timer((s_custom_on_time + s_custom_off_time) / 2);
            break;
            
        default:
            ESP_LOGE(TAG, "Unknown LED pattern: %d", pattern);
            return ESP_ERR_INVALID_ARG;
    }
    
    return ESP_OK;
}

led_pattern_t led_get_pattern(void)
{
    return s_current_pattern;
}

esp_err_t led_set_custom_pattern(uint32_t on_time_ms, uint32_t off_time_ms)
{
    if (on_time_ms == 0 || off_time_ms == 0) {
        return ESP_ERR_INVALID_ARG;
    }
    
    s_custom_on_time = on_time_ms;
    s_custom_off_time = off_time_ms;
    
    ESP_LOGI(TAG, "Custom LED pattern set: ON=%lums, OFF=%lums", on_time_ms, off_time_ms);
    
    // If currently using custom pattern, restart with new timing
    if (s_current_pattern == LED_PATTERN_CUSTOM) {
        led_set_pattern(LED_PATTERN_CUSTOM);
    }
    
    return ESP_OK;
}