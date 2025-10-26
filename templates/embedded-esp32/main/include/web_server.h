/**
 * @file web_server.h
 * @brief HTTP web server for ESP32 IoT control
 */

#pragma once

#include "esp_err.h"

#ifdef __cplusplus
extern "C" {
#endif

// Web server configuration
#define WEB_SERVER_PORT         80
#define WEB_SERVER_MAX_URI_LEN  512
#define WEB_SERVER_MAX_RESP_LEN 1024

/**
 * @brief Start web server
 * @return ESP_OK on success, error code otherwise
 */
esp_err_t web_server_start(void);

/**
 * @brief Stop web server
 * @return ESP_OK on success, error code otherwise
 */
esp_err_t web_server_stop(void);

/**
 * @brief Check if web server is running
 * @return true if running, false otherwise
 */
bool web_server_is_running(void);

#ifdef __cplusplus
}
#endif