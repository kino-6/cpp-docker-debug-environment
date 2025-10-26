/**
 * @file sensor_reader.c
 * @brief Sensor reading implementation for ESP32
 */

#include "sensor_reader.h"
#include "esp_log.h"
#include "esp_timer.h"
#include "driver/adc.h"
#include "esp_adc_cal.h"
#include <math.h>
#include <stdio.h>

static const char *TAG = "SENSOR_READER";

// Simulated sensor base values
static float s_base_temperature = 25.0f;  // 25°C
static float s_base_humidity = 60.0f;     // 60%
static float s_base_light = 500.0f;       // 500 Lux
static float s_base_pressure = 1013.25f;  // 1013.25 hPa (sea level)

// ADC configuration for real sensor reading
static esp_adc_cal_characteristics_t *s_adc_chars = NULL;
static const adc_channel_t s_adc_channel = ADC_CHANNEL_6; // GPIO34
static const adc_bits_width_t s_adc_width = ADC_WIDTH_BIT_12;
static const adc_atten_t s_adc_atten = ADC_ATTEN_DB_0;

/**
 * @brief Generate simulated sensor noise
 */
static float generate_noise(float amplitude)
{
    // Simple pseudo-random noise generator
    static uint32_t seed = 12345;
    seed = (seed * 1103515245 + 12345) & 0x7fffffff;
    float noise = ((float)(seed % 1000) / 1000.0f - 0.5f) * 2.0f; // -1.0 to 1.0
    return noise * amplitude;
}

/**
 * @brief Get time-based variation
 */
static float get_time_variation(float period_seconds, float amplitude)
{
    uint64_t time_us = esp_timer_get_time();
    float time_s = (float)time_us / 1000000.0f;
    return sinf(2.0f * M_PI * time_s / period_seconds) * amplitude;
}

esp_err_t sensor_reader_init(void)
{
    ESP_LOGI(TAG, "Initializing sensor reader...");
    
    // Configure ADC for potential real sensor reading
    esp_err_t ret = adc1_config_width(s_adc_width);
    if (ret != ESP_OK) {
        ESP_LOGE(TAG, "Failed to configure ADC width: %s", esp_err_to_name(ret));
        return ret;
    }
    
    ret = adc1_config_channel_atten(s_adc_channel, s_adc_atten);
    if (ret != ESP_OK) {
        ESP_LOGE(TAG, "Failed to configure ADC channel: %s", esp_err_to_name(ret));
        return ret;
    }
    
    // Characterize ADC
    s_adc_chars = calloc(1, sizeof(esp_adc_cal_characteristics_t));
    esp_adc_cal_value_t val_type = esp_adc_cal_characterize(ADC_UNIT_1, s_adc_atten, s_adc_width, 1100, s_adc_chars);
    
    if (val_type == ESP_ADC_CAL_VAL_EFUSE_VREF) {
        ESP_LOGI(TAG, "ADC characterized using eFuse Vref");
    } else if (val_type == ESP_ADC_CAL_VAL_EFUSE_TP) {
        ESP_LOGI(TAG, "ADC characterized using Two Point Value");
    } else {
        ESP_LOGI(TAG, "ADC characterized using Default Vref");
    }
    
    ESP_LOGI(TAG, "Sensor reader initialized");
    ESP_LOGI(TAG, "Note: Using simulated sensors for demonstration");
    return ESP_OK;
}

float sensor_read_temperature(void)
{
    // Simulate temperature with time variation and noise
    float time_variation = get_time_variation(300.0f, 3.0f); // 5-minute cycle, ±3°C
    float noise = generate_noise(0.5f); // ±0.5°C noise
    
    // Optional: Read real ADC value for variation
    uint32_t adc_reading = adc1_get_raw(s_adc_channel);
    uint32_t voltage = esp_adc_cal_raw_to_voltage(adc_reading, s_adc_chars);
    float adc_variation = (voltage - 1650.0f) / 100.0f; // Convert voltage to temperature variation
    
    float temperature = s_base_temperature + time_variation + noise + (adc_variation * 0.1f);
    
    // Clamp to reasonable range
    if (temperature < -40.0f) temperature = -40.0f;
    if (temperature > 85.0f) temperature = 85.0f;
    
    return temperature;
}

float sensor_read_humidity(void)
{
    // Simulate humidity with time variation and noise
    float time_variation = get_time_variation(600.0f, 15.0f); // 10-minute cycle, ±15%
    float noise = generate_noise(2.0f); // ±2% noise
    
    float humidity = s_base_humidity + time_variation + noise;
    
    // Clamp to valid range
    if (humidity < 0.0f) humidity = 0.0f;
    if (humidity > 100.0f) humidity = 100.0f;
    
    return humidity;
}

float sensor_read_light(void)
{
    // Simulate light level with time variation and noise
    float time_variation = get_time_variation(120.0f, 200.0f); // 2-minute cycle, ±200 Lux
    float noise = generate_noise(50.0f); // ±50 Lux noise
    
    float light = s_base_light + time_variation + noise;
    
    // Clamp to reasonable range
    if (light < 0.0f) light = 0.0f;
    if (light > 10000.0f) light = 10000.0f;
    
    return light;
}

float sensor_read_pressure(void)
{
    // Simulate pressure with time variation and noise
    float time_variation = get_time_variation(1800.0f, 5.0f); // 30-minute cycle, ±5 hPa
    float noise = generate_noise(0.5f); // ±0.5 hPa noise
    
    float pressure = s_base_pressure + time_variation + noise;
    
    // Clamp to reasonable range
    if (pressure < 800.0f) pressure = 800.0f;
    if (pressure > 1200.0f) pressure = 1200.0f;
    
    return pressure;
}

esp_err_t sensor_read_all(sensor_data_t *data)
{
    if (data == NULL) {
        return ESP_ERR_INVALID_ARG;
    }
    
    data->temperature = sensor_read_temperature();
    data->humidity = sensor_read_humidity();
    data->light_level = sensor_read_light();
    data->pressure = sensor_read_pressure();
    data->timestamp = (uint32_t)(esp_timer_get_time() / 1000000); // Convert to seconds
    
    return ESP_OK;
}

esp_err_t sensor_get_json(char *json_buffer, size_t buffer_size)
{
    if (json_buffer == NULL || buffer_size == 0) {
        return ESP_ERR_INVALID_ARG;
    }
    
    sensor_data_t data;
    esp_err_t ret = sensor_read_all(&data);
    if (ret != ESP_OK) {
        return ret;
    }
    
    int written = snprintf(json_buffer, buffer_size,
        "{"
        "\"temperature\":%.2f,"
        "\"humidity\":%.2f,"
        "\"light\":%.1f,"
        "\"pressure\":%.2f,"
        "\"timestamp\":%lu"
        "}",
        data.temperature,
        data.humidity,
        data.light_level,
        data.pressure,
        data.timestamp
    );
    
    if (written >= buffer_size) {
        ESP_LOGE(TAG, "JSON buffer too small");
        return ESP_ERR_NO_MEM;
    }
    
    return ESP_OK;
}