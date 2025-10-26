/**
 * @file simple_main.c
 * @brief Simple ESP32 test program
 */

#include <stdio.h>
#include "freertos/FreeRTOS.h"
#include "freertos/task.h"
#include "esp_log.h"
#include "driver/gpio.h"

static const char *TAG = "ESP32_SIMPLE";

#define LED_GPIO 2

void app_main(void)
{
    ESP_LOGI(TAG, "ESP32 Simple Test Started!");
    
    // Configure LED GPIO
    gpio_config_t io_conf = {
        .intr_type = GPIO_INTR_DISABLE,
        .mode = GPIO_MODE_OUTPUT,
        .pin_bit_mask = (1ULL << LED_GPIO),
        .pull_down_en = 0,
        .pull_up_en = 0,
    };
    gpio_config(&io_conf);
    
    ESP_LOGI(TAG, "LED GPIO configured");
    
    // Simple LED blink loop
    bool led_state = false;
    while (1) {
        gpio_set_level(LED_GPIO, led_state);
        led_state = !led_state;
        
        ESP_LOGI(TAG, "LED %s", led_state ? "ON" : "OFF");
        vTaskDelay(pdMS_TO_TICKS(1000));
    }
}