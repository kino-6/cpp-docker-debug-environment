/**
 * @file config_loader.h
 * @brief Configuration loader for ESP32 WiFi settings
 */

#pragma once

// Default configuration (fallback values)
#ifndef WIFI_SSID
#define WIFI_SSID "ESP32-Setup"
#endif

#ifndef WIFI_PASSWORD
#define WIFI_PASSWORD "setup123"
#endif

#ifndef WEB_USERNAME
#define WEB_USERNAME "admin"
#endif

#ifndef WEB_PASSWORD
#define WEB_PASSWORD "admin123"
#endif

#ifndef WEB_PORT
#define WEB_PORT 80
#endif

#ifndef DEVICE_HOSTNAME
#define DEVICE_HOSTNAME "esp32-led-controller"
#endif

#ifndef LED_PIN
#define LED_PIN 2
#endif

// Try to include local configuration if it exists
#ifdef USE_LOCAL_CONFIG
  // Local configuration will be loaded via build flags
  // See platformio.ini for configuration
#endif