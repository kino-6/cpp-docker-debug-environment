/**
 * @file wifi_manager.h
 * @brief WiFi connection management for ESP32
 */

#pragma once

#include "esp_err.h"
#include "esp_wifi.h"

#ifdef __cplusplus
extern "C" {
#endif

// Default WiFi configuration
#define WIFI_SSID_DEFAULT       "ESP32-IoT"
#define WIFI_PASSWORD_DEFAULT   "esp32password"
#define WIFI_MAXIMUM_RETRY      5

// WiFi status
typedef enum {
    WIFI_STATUS_DISCONNECTED = 0,
    WIFI_STATUS_CONNECTING,
    WIFI_STATUS_CONNECTED,
    WIFI_STATUS_ERROR
} wifi_status_t;

/**
 * @brief Initialize WiFi manager
 * @return ESP_OK on success, error code otherwise
 */
esp_err_t wifi_manager_init(void);

/**
 * @brief Connect to WiFi network
 * @return ESP_OK on success, error code otherwise
 */
esp_err_t wifi_manager_connect(void);

/**
 * @brief Disconnect from WiFi network
 * @return ESP_OK on success, error code otherwise
 */
esp_err_t wifi_manager_disconnect(void);

/**
 * @brief Get current WiFi status
 * @return Current WiFi status
 */
wifi_status_t wifi_manager_get_status(void);

/**
 * @brief Get WiFi IP address
 * @param ip_str Buffer to store IP address string (minimum 16 bytes)
 * @return ESP_OK on success, error code otherwise
 */
esp_err_t wifi_manager_get_ip(char *ip_str);

/**
 * @brief Set WiFi credentials
 * @param ssid WiFi SSID
 * @param password WiFi password
 * @return ESP_OK on success, error code otherwise
 */
esp_err_t wifi_manager_set_credentials(const char *ssid, const char *password);

#ifdef __cplusplus
}
#endif