#ifndef MOCK_GPIO_H
#define MOCK_GPIO_H

#include <stdint.h>
#include <stdbool.h>

// GPIO mode definitions (matching real hardware)
#define GPIO_MODE_INPUT     0x00
#define GPIO_MODE_OUTPUT    0x01
#define GPIO_MODE_ALTERNATE 0x02
#define GPIO_MODE_ANALOG    0x03

// Mock GPIO function declarations
void mock_gpio_init(uint32_t gpio_base);
void mock_gpio_set_mode(uint32_t gpio_base, uint32_t pin_mask, uint32_t mode);
void mock_gpio_set_pin(uint32_t gpio_base, uint32_t pin_mask);
void mock_gpio_clear_pin(uint32_t gpio_base, uint32_t pin_mask);
uint32_t mock_gpio_read_pin(uint32_t gpio_base, uint32_t pin_mask);

// Mock expectation functions
void mock_gpio_expect_init(uint32_t expected_gpio_base);
void mock_gpio_expect_set_mode(uint32_t expected_gpio_base, uint32_t expected_pin_mask, uint32_t expected_mode);
void mock_gpio_expect_set_pin(uint32_t expected_gpio_base, uint32_t expected_pin_mask);
void mock_gpio_expect_clear_pin(uint32_t expected_gpio_base, uint32_t expected_pin_mask);

// Mock control functions
void mock_gpio_reset(void);
void mock_gpio_verify(void);

#endif // MOCK_GPIO_H