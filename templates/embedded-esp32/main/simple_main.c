/**
 * @file simple_main.c
 * @brief Simple ESP32 LED blink test
 */

#include <stdio.h>
#include "freertos/FreeRTOS.h"
#include "freertos/task.h"
#include "driver/gpio.h"

#define LED_GPIO 2

void app_main(void)
{
    printf("ESP32 Simple LED Blink Test Started!\n");
    
    // Configure LED GPIO
    gpio_config_t io_conf = {
        .intr_type = GPIO_INTR_DISABLE,
        .mode = GPIO_MODE_OUTPUT,
        .pin_bit_mask = (1ULL << LED_GPIO),
        .pull_down_en = 0,
        .pull_up_en = 0,
    };
    gpio_config(&io_conf);
    
    printf("LED GPIO %d configured\n", LED_GPIO);
    
    // Simple LED blink loop
    bool led_state = false;
    int count = 0;
    
    while (1) {
        gpio_set_level(LED_GPIO, led_state);
        led_state = !led_state;
        count++;
        
        printf("Blink %d: LED %s\n", count, led_state ? "ON" : "OFF");
        vTaskDelay(pdMS_TO_TICKS(1000));
    }
}