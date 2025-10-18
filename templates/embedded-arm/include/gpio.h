/**
 * @file gpio.h
 * @brief GPIO control header for STM32F407VG
 * @author Embedded Development Template
 */

#ifndef GPIO_H
#define GPIO_H

#include <stdint.h>

#ifdef __cplusplus
extern "C" {
#endif

/**
 * @brief Initialize GPIO for LED control
 */
void gpio_init(void);

/**
 * @brief Set GPIO pin high
 * @param gpio_base GPIO port base address
 * @param pin Pin number (0-15)
 */
void gpio_set_pin(uint32_t gpio_base, uint8_t pin);

/**
 * @brief Set GPIO pin low
 * @param gpio_base GPIO port base address
 * @param pin Pin number (0-15)
 */
void gpio_clear_pin(uint32_t gpio_base, uint8_t pin);

/**
 * @brief Toggle GPIO pin
 * @param gpio_base GPIO port base address
 * @param pin Pin number (0-15)
 */
void gpio_toggle_pin(uint32_t gpio_base, uint8_t pin);

/**
 * @brief Read GPIO pin state
 * @param gpio_base GPIO port base address
 * @param pin Pin number (0-15)
 * @return Pin state (0 or 1)
 */
uint8_t gpio_read_pin(uint32_t gpio_base, uint8_t pin);

#ifdef __cplusplus
}
#endif

#endif /* GPIO_H */