/**
 * @file main.c
 * @brief ESP32 IoT Development - Main Application
 * 
 * This is the main entry point for the ESP32 IoT development environment.
 * It demonstrates WiFi connectivity, web server, LED control, and sensor reading.
 */

#include <stdio.h>
#include <string.h>
#include "freertos/FreeRTOS.h"
#include "freertos/task.h"
#include "freertos/event_groups.h"
#include "esp_system.h"
#include "esp_wifi.h"
#include "esp_event.h"
#include "esp_log.h"
#include "nvs_flash.h"
#include "esp_netif.h"
#include "esp_timer.h"

#include "wifi_manager.h"
#include "web_server.h"
#include "led_controller.h"
#include "sensor_reader.h"

static const char *TAG = "ESP32_MAIN";

// System status
typedef struct {
    bool wifi_connected;
    bool web_server_running;
    uint32_t uptime_seconds;
    float temperature;
    uint32_t free_heap;
} system_status_t;

static system_status_t system_status = {0};

/**
 * @brief System status update task
 */
static void system_status_task(void *pvParameters)
{
    ESP_LOGI(TAG, "System status task started");
    
    while (1) {
        // Update system status
        system_status.uptime_seconds++;
        system_status.free_heap = esp_get_free_heap_size();
        system_status.temperature = sensor_read_temperature();
        
        // Log system status every 30 seconds
        if (system_status.uptime_seconds % 30 == 0) {
            ESP_LOGI(TAG, "=== System Status ===");
            ESP_LOGI(TAG, "Uptime: %lu seconds", system_status.uptime_seconds);
            ESP_LOGI(TAG, "WiFi: %s", system_status.wifi_connected ? "Connected" : "Disconnected");
            ESP_LOGI(TAG, "Web Server: %s", system_status.web_server_running ? "Running" : "Stopped");
            ESP_LOGI(TAG, "Temperature: %.2f°C", system_status.temperature);
            ESP_LOGI(TAG, "Free Heap: %lu bytes", system_status.free_heap);
            ESP_LOGI(TAG, "==================");
        }
        
        // Update LED based on system status
        if (system_status.wifi_connected && system_status.web_server_running) {
            led_set_pattern(LED_PATTERN_BREATHING);  // Breathing green - all good
        } else if (system_status.wifi_connected) {
            led_set_pattern(LED_PATTERN_SLOW_BLINK); // Slow blink - WiFi only
        } else {
            led_set_pattern(LED_PATTERN_FAST_BLINK); // Fast blink - no WiFi
        }
        
        vTaskDelay(pdMS_TO_TICKS(1000)); // 1 second interval
    }
}

/**
 * @brief LED demo task
 */
static void led_demo_task(void *pvParameters)
{
    ESP_LOGI(TAG, "LED demo task started");
    
    // Initial LED test sequence
    ESP_LOGI(TAG, "Running LED test sequence...");
    
    // Test all LED patterns
    led_set_pattern(LED_PATTERN_OFF);
    vTaskDelay(pdMS_TO_TICKS(500));
    
    led_set_pattern(LED_PATTERN_ON);
    vTaskDelay(pdMS_TO_TICKS(1000));
    
    led_set_pattern(LED_PATTERN_FAST_BLINK);
    vTaskDelay(pdMS_TO_TICKS(2000));
    
    led_set_pattern(LED_PATTERN_SLOW_BLINK);
    vTaskDelay(pdMS_TO_TICKS(2000));
    
    led_set_pattern(LED_PATTERN_BREATHING);
    vTaskDelay(pdMS_TO_TICKS(3000));
    
    ESP_LOGI(TAG, "LED test sequence completed");
    
    // Delete this task after demo
    vTaskDelete(NULL);
}

/**
 * @brief WiFi event handler
 */
static void wifi_event_handler(void* arg, esp_event_base_t event_base,
                              int32_t event_id, void* event_data)
{
    if (event_base == WIFI_EVENT && event_id == WIFI_EVENT_STA_START) {
        ESP_LOGI(TAG, "WiFi station started");
        esp_wifi_connect();
    } else if (event_base == WIFI_EVENT && event_id == WIFI_EVENT_STA_DISCONNECTED) {
        ESP_LOGI(TAG, "WiFi disconnected, attempting reconnection...");
        system_status.wifi_connected = false;
        esp_wifi_connect();
    } else if (event_base == IP_EVENT && event_id == IP_EVENT_STA_GOT_IP) {
        ip_event_got_ip_t* event = (ip_event_got_ip_t*) event_data;
        ESP_LOGI(TAG, "WiFi connected! IP: " IPSTR, IP2STR(&event->ip_info.ip));
        system_status.wifi_connected = true;
        
        // Start web server after WiFi connection
        if (web_server_start() == ESP_OK) {
            system_status.web_server_running = true;
            ESP_LOGI(TAG, "Web server started successfully");
        } else {
            ESP_LOGE(TAG, "Failed to start web server");
        }
    }
}

/**
 * @brief Initialize system components
 */
static esp_err_t system_init(void)
{
    esp_err_t ret = ESP_OK;
    
    ESP_LOGI(TAG, "Initializing ESP32 IoT system...");
    
    // Initialize NVS
    ret = nvs_flash_init();
    if (ret == ESP_ERR_NVS_NO_FREE_PAGES || ret == ESP_ERR_NVS_NEW_VERSION_FOUND) {
        ESP_ERROR_CHECK(nvs_flash_erase());
        ret = nvs_flash_init();
    }
    ESP_ERROR_CHECK(ret);
    ESP_LOGI(TAG, "✓ NVS initialized");
    
    // Initialize network interface
    ESP_ERROR_CHECK(esp_netif_init());
    ESP_ERROR_CHECK(esp_event_loop_create_default());
    esp_netif_create_default_wifi_sta();
    ESP_LOGI(TAG, "✓ Network interface initialized");
    
    // Initialize WiFi
    ret = wifi_manager_init();
    if (ret != ESP_OK) {
        ESP_LOGE(TAG, "✗ WiFi initialization failed");
        return ret;
    }
    ESP_LOGI(TAG, "✓ WiFi manager initialized");
    
    // Register WiFi event handler
    ESP_ERROR_CHECK(esp_event_handler_register(WIFI_EVENT, ESP_EVENT_ANY_ID, &wifi_event_handler, NULL));
    ESP_ERROR_CHECK(esp_event_handler_register(IP_EVENT, IP_EVENT_STA_GOT_IP, &wifi_event_handler, NULL));
    ESP_LOGI(TAG, "✓ WiFi event handlers registered");
    
    // Initialize LED controller
    ret = led_controller_init();
    if (ret != ESP_OK) {
        ESP_LOGE(TAG, "✗ LED controller initialization failed");
        return ret;
    }
    ESP_LOGI(TAG, "✓ LED controller initialized");
    
    // Initialize sensor reader
    ret = sensor_reader_init();
    if (ret != ESP_OK) {
        ESP_LOGE(TAG, "✗ Sensor reader initialization failed");
        return ret;
    }
    ESP_LOGI(TAG, "✓ Sensor reader initialized");
    
    ESP_LOGI(TAG, "System initialization completed successfully!");
    return ESP_OK;
}

/**
 * @brief Main application entry point
 */
void app_main(void)
{
    ESP_LOGI(TAG, "=================================");
    ESP_LOGI(TAG, "ESP32 IoT Development Environment");
    ESP_LOGI(TAG, "Version: 1.0.0");
    ESP_LOGI(TAG, "=================================");
    
    // Print system information
    esp_chip_info_t chip_info;
    esp_chip_info(&chip_info);
    ESP_LOGI(TAG, "ESP32 Chip Info:");
    ESP_LOGI(TAG, "  Model: %s", CONFIG_IDF_TARGET);
    ESP_LOGI(TAG, "  Cores: %d", chip_info.cores);
    ESP_LOGI(TAG, "  Revision: %d", chip_info.revision);
    ESP_LOGI(TAG, "  Flash: %dMB %s", 
             spi_flash_get_chip_size() / (1024 * 1024),
             (chip_info.features & CHIP_FEATURE_EMB_FLASH) ? "embedded" : "external");
    ESP_LOGI(TAG, "  Free heap: %lu bytes", esp_get_free_heap_size());
    
    // Initialize system
    esp_err_t ret = system_init();
    if (ret != ESP_OK) {
        ESP_LOGE(TAG, "System initialization failed: %s", esp_err_to_name(ret));
        return;
    }
    
    // Start WiFi connection
    ESP_LOGI(TAG, "Starting WiFi connection...");
    ret = wifi_manager_connect();
    if (ret != ESP_OK) {
        ESP_LOGE(TAG, "WiFi connection failed: %s", esp_err_to_name(ret));
    }
    
    // Create system tasks
    xTaskCreate(system_status_task, "system_status", 4096, NULL, 5, NULL);
    xTaskCreate(led_demo_task, "led_demo", 2048, NULL, 3, NULL);
    
    ESP_LOGI(TAG, "=================================");
    ESP_LOGI(TAG, "ESP32 IoT system started!");
    ESP_LOGI(TAG, "Waiting for WiFi connection...");
    ESP_LOGI(TAG, "=================================");
    
    // Main loop
    while (1) {
        // Print periodic status
        static uint32_t last_status_time = 0;
        uint32_t current_time = esp_timer_get_time() / 1000000; // Convert to seconds
        
        if (current_time - last_status_time >= 60) { // Every 60 seconds
            ESP_LOGI(TAG, "System running... Uptime: %lu seconds", current_time);
            last_status_time = current_time;
        }
        
        vTaskDelay(pdMS_TO_TICKS(10000)); // 10 second delay
    }
}