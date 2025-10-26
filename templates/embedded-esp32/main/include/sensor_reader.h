/**
 * @file sensor_reader.h
 * @brief Sensor reading functionality for ESP32
 */

#pragma once

#include "esp_err.h"

#ifdef __cplusplus
extern "C" {
#endif

// Sensor types
typedef enum {
    SENSOR_TYPE_TEMPERATURE = 0,
    SENSOR_TYPE_HUMIDITY,
    SENSOR_TYPE_LIGHT,
    SENSOR_TYPE_PRESSURE
} sensor_type_t;

// Sensor data structure
typedef struct {
    float temperature;    // °C
    float humidity;       // %
    float light_level;    // Lux (simulated)
    float pressure;       // hPa (simulated)
    uint32_t timestamp;   // Unix timestamp
} sensor_data_t;

/**
 * @brief Initialize sensor reader
 * @return ESP_OK on success, error code otherwise
 */
esp_err_t sensor_reader_init(void);

/**
 * @brief Read temperature sensor
 * @return Temperature in Celsius
 */
float sensor_read_temperature(void);

/**
 * @brief Read humidity sensor
 * @return Humidity in percentage
 */
float sensor_read_humidity(void);

/**
 * @brief Read light sensor
 * @return Light level in Lux
 */
float sensor_read_light(void);

/**
 * @brief Read pressure sensor
 * @return Pressure in hPa
 */
float sensor_read_pressure(void);

/**
 * @brief Read all sensors
 * @param data Pointer to sensor data structure
 * @return ESP_OK on success, error code otherwise
 */
esp_err_t sensor_read_all(sensor_data_t *data);

/**
 * @brief Get sensor reading as JSON string
 * @param json_buffer Buffer to store JSON string
 * @param buffer_size Size of the buffer
 * @return ESP_OK on success, error code otherwise
 */
esp_err_t sensor_get_json(char *json_buffer, size_t buffer_size);

#ifdef __cplusplus
}
#endif