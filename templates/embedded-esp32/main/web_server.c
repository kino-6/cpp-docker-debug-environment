/**
 * @file web_server.c
 * @brief HTTP web server implementation for ESP32 IoT control
 */

#include "web_server.h"
#include "led_controller.h"
#include "sensor_reader.h"
#include "wifi_manager.h"
#include "esp_http_server.h"
#include "esp_log.h"
#include <string.h>

static const char *TAG = "WEB_SERVER";

static httpd_handle_t s_server = NULL;

// HTML page content
static const char* html_page = 
"<!DOCTYPE html>"
"<html>"
"<head>"
"    <title>ESP32 IoT Controller</title>"
"    <meta name='viewport' content='width=device-width, initial-scale=1'>"
"    <style>"
"        body { font-family: Arial, sans-serif; margin: 20px; background-color: #f0f0f0; }"
"        .container { max-width: 600px; margin: 0 auto; background: white; padding: 20px; border-radius: 10px; box-shadow: 0 2px 10px rgba(0,0,0,0.1); }"
"        h1 { color: #333; text-align: center; }"
"        .section { margin: 20px 0; padding: 15px; border: 1px solid #ddd; border-radius: 5px; }"
"        .button { background-color: #4CAF50; color: white; padding: 10px 20px; border: none; border-radius: 4px; cursor: pointer; margin: 5px; }"
"        .button:hover { background-color: #45a049; }"
"        .button.off { background-color: #f44336; }"
"        .button.off:hover { background-color: #da190b; }"
"        .sensor-data { background-color: #e7f3ff; padding: 10px; border-radius: 5px; }"
"        .status { font-weight: bold; color: #2196F3; }"
"    </style>"
"    <script>"
"        function controlLED(action) {"
"            fetch('/api/led/' + action)"
"                .then(response => response.json())"
"                .then(data => {"
"                    document.getElementById('ledStatus').innerText = data.status;"
"                    updateLEDButtons(data.status);"
"                })"
"                .catch(error => console.error('Error:', error));"
"        }"
"        function updateLEDButtons(status) {"
"            const onBtn = document.getElementById('ledOnBtn');"
"            const offBtn = document.getElementById('ledOffBtn');"
"            if (status === 'ON') {"
"                onBtn.style.backgroundColor = '#4CAF50';"
"                offBtn.style.backgroundColor = '#ccc';"
"            } else {"
"                onBtn.style.backgroundColor = '#ccc';"
"                offBtn.style.backgroundColor = '#f44336';"
"            }"
"        }"
"        function updateSensors() {"
"            fetch('/api/sensors')"
"                .then(response => response.json())"
"                .then(data => {"
"                    document.getElementById('temperature').innerText = data.temperature.toFixed(1) + '°C';"
"                    document.getElementById('humidity').innerText = data.humidity.toFixed(1) + '%';"
"                    document.getElementById('light').innerText = data.light.toFixed(0) + ' Lux';"
"                    document.getElementById('pressure').innerText = data.pressure.toFixed(1) + ' hPa';"
"                })"
"                .catch(error => console.error('Error:', error));"
"        }"
"        setInterval(updateSensors, 5000); // Update every 5 seconds"
"        window.onload = function() { updateSensors(); };"
"    </script>"
"</head>"
"<body>"
"    <div class='container'>"
"        <h1>🌐 ESP32 IoT Controller</h1>"
"        "
"        <div class='section'>"
"            <h2>💡 LED Control</h2>"
"            <button id='ledOnBtn' class='button' onclick='controlLED(\"on\")'>Turn ON</button>"
"            <button id='ledOffBtn' class='button off' onclick='controlLED(\"off\")'>Turn OFF</button>"
"            <button class='button' onclick='controlLED(\"toggle\")'>Toggle</button>"
"            <p>Status: <span id='ledStatus' class='status'>Unknown</span></p>"
"        </div>"
"        "
"        <div class='section'>"
"            <h2>📊 Sensor Data</h2>"
"            <div class='sensor-data'>"
"                <p>🌡️ Temperature: <span id='temperature'>--</span></p>"
"                <p>💧 Humidity: <span id='humidity'>--</span></p>"
"                <p>☀️ Light: <span id='light'>--</span></p>"
"                <p>🌪️ Pressure: <span id='pressure'>--</span></p>"
"            </div>"
"        </div>"
"        "
"        <div class='section'>"
"            <h2>ℹ️ System Info</h2>"
"            <p>Device: ESP32 IoT Controller</p>"
"            <p>Firmware: v1.0.0</p>"
"            <p>WiFi: Connected</p>"
"        </div>"
"    </div>"
"</body>"
"</html>";

/**
 * @brief Root page handler
 */
static esp_err_t root_handler(httpd_req_t *req)
{
    ESP_LOGI(TAG, "Serving root page");
    
    httpd_resp_set_type(req, "text/html");
    httpd_resp_send(req, html_page, HTTPD_RESP_USE_STRLEN);
    
    return ESP_OK;
}

/**
 * @brief LED control API handler
 */
static esp_err_t led_api_handler(httpd_req_t *req)
{
    char response[256];
    const char* action = req->uri + strlen("/api/led/"); // Extract action from URI
    
    ESP_LOGI(TAG, "LED API called with action: %s", action);
    
    esp_err_t ret = ESP_OK;
    const char* status = "UNKNOWN";
    
    if (strcmp(action, "on") == 0) {
        ret = led_set_state(true);
        status = "ON";
    } else if (strcmp(action, "off") == 0) {
        ret = led_set_state(false);
        status = "OFF";
    } else if (strcmp(action, "toggle") == 0) {
        ret = led_toggle();
        status = (led_get_pattern() != LED_PATTERN_OFF) ? "ON" : "OFF";
    } else {
        httpd_resp_set_status(req, "400 Bad Request");
        httpd_resp_send(req, "Invalid action", HTTPD_RESP_USE_STRLEN);
        return ESP_FAIL;
    }
    
    if (ret != ESP_OK) {
        httpd_resp_set_status(req, "500 Internal Server Error");
        httpd_resp_send(req, "LED control failed", HTTPD_RESP_USE_STRLEN);
        return ESP_FAIL;
    }
    
    // Send JSON response
    snprintf(response, sizeof(response), 
             "{\"action\":\"%s\",\"status\":\"%s\",\"success\":true}", 
             action, status);
    
    httpd_resp_set_type(req, "application/json");
    httpd_resp_send(req, response, HTTPD_RESP_USE_STRLEN);
    
    return ESP_OK;
}

/**
 * @brief Sensors API handler
 */
static esp_err_t sensors_api_handler(httpd_req_t *req)
{
    ESP_LOGI(TAG, "Sensors API called");
    
    char json_response[512];
    esp_err_t ret = sensor_get_json(json_response, sizeof(json_response));
    
    if (ret != ESP_OK) {
        httpd_resp_set_status(req, "500 Internal Server Error");
        httpd_resp_send(req, "Sensor reading failed", HTTPD_RESP_USE_STRLEN);
        return ESP_FAIL;
    }
    
    httpd_resp_set_type(req, "application/json");
    httpd_resp_send(req, json_response, HTTPD_RESP_USE_STRLEN);
    
    return ESP_OK;
}

/**
 * @brief System status API handler
 */
static esp_err_t status_api_handler(httpd_req_t *req)
{
    ESP_LOGI(TAG, "Status API called");
    
    char ip_str[16];
    wifi_manager_get_ip(ip_str);
    
    char response[512];
    snprintf(response, sizeof(response),
             "{"
             "\"device\":\"ESP32 IoT Controller\","
             "\"version\":\"1.0.0\","
             "\"wifi_status\":\"%s\","
             "\"ip_address\":\"%s\","
             "\"free_heap\":%lu,"
             "\"uptime\":%llu"
             "}",
             (wifi_manager_get_status() == WIFI_STATUS_CONNECTED) ? "connected" : "disconnected",
             ip_str,
             esp_get_free_heap_size(),
             esp_timer_get_time() / 1000000
    );
    
    httpd_resp_set_type(req, "application/json");
    httpd_resp_send(req, response, HTTPD_RESP_USE_STRLEN);
    
    return ESP_OK;
}

esp_err_t web_server_start(void)
{
    if (s_server != NULL) {
        ESP_LOGI(TAG, "Web server already running");
        return ESP_OK;
    }
    
    ESP_LOGI(TAG, "Starting web server...");
    
    httpd_config_t config = HTTPD_DEFAULT_CONFIG();
    config.server_port = WEB_SERVER_PORT;
    config.max_uri_handlers = 8;
    config.max_resp_headers = 8;
    config.stack_size = 8192;
    
    esp_err_t ret = httpd_start(&s_server, &config);
    if (ret != ESP_OK) {
        ESP_LOGE(TAG, "Failed to start web server: %s", esp_err_to_name(ret));
        return ret;
    }
    
    // Register URI handlers
    httpd_uri_t root_uri = {
        .uri = "/",
        .method = HTTP_GET,
        .handler = root_handler,
        .user_ctx = NULL
    };
    httpd_register_uri_handler(s_server, &root_uri);
    
    httpd_uri_t led_on_uri = {
        .uri = "/api/led/on",
        .method = HTTP_GET,
        .handler = led_api_handler,
        .user_ctx = NULL
    };
    httpd_register_uri_handler(s_server, &led_on_uri);
    
    httpd_uri_t led_off_uri = {
        .uri = "/api/led/off",
        .method = HTTP_GET,
        .handler = led_api_handler,
        .user_ctx = NULL
    };
    httpd_register_uri_handler(s_server, &led_off_uri);
    
    httpd_uri_t led_toggle_uri = {
        .uri = "/api/led/toggle",
        .method = HTTP_GET,
        .handler = led_api_handler,
        .user_ctx = NULL
    };
    httpd_register_uri_handler(s_server, &led_toggle_uri);
    
    httpd_uri_t sensors_uri = {
        .uri = "/api/sensors",
        .method = HTTP_GET,
        .handler = sensors_api_handler,
        .user_ctx = NULL
    };
    httpd_register_uri_handler(s_server, &sensors_uri);
    
    httpd_uri_t status_uri = {
        .uri = "/api/status",
        .method = HTTP_GET,
        .handler = status_api_handler,
        .user_ctx = NULL
    };
    httpd_register_uri_handler(s_server, &status_uri);
    
    ESP_LOGI(TAG, "Web server started on port %d", WEB_SERVER_PORT);
    ESP_LOGI(TAG, "Available endpoints:");
    ESP_LOGI(TAG, "  GET /              - Main control page");
    ESP_LOGI(TAG, "  GET /api/led/on    - Turn LED on");
    ESP_LOGI(TAG, "  GET /api/led/off   - Turn LED off");
    ESP_LOGI(TAG, "  GET /api/led/toggle - Toggle LED");
    ESP_LOGI(TAG, "  GET /api/sensors   - Get sensor data");
    ESP_LOGI(TAG, "  GET /api/status    - Get system status");
    
    return ESP_OK;
}

esp_err_t web_server_stop(void)
{
    if (s_server == NULL) {
        ESP_LOGI(TAG, "Web server not running");
        return ESP_OK;
    }
    
    ESP_LOGI(TAG, "Stopping web server...");
    
    esp_err_t ret = httpd_stop(s_server);
    if (ret != ESP_OK) {
        ESP_LOGE(TAG, "Failed to stop web server: %s", esp_err_to_name(ret));
        return ret;
    }
    
    s_server = NULL;
    ESP_LOGI(TAG, "Web server stopped");
    
    return ESP_OK;
}

bool web_server_is_running(void)
{
    return (s_server != NULL);
}