/**
 * @file gpio.c
 * @brief GPIO control functions for STM32F407VG
 * @author Embedded Development Template
 */

#include "gpio.h"
#include <stdint.h>

// GPIO register base addresses
#define GPIOA_BASE          0x40020000UL
#define GPIOD_BASE          0x40020C00UL

// GPIO register offsets
#define GPIO_MODER_OFFSET   0x00
#define GPIO_OTYPER_OFFSET  0x04
#define GPIO_OSPEEDR_OFFSET 0x08
#define GPIO_PUPDR_OFFSET   0x0C
#define GPIO_ODR_OFFSET     0x14
#define GPIO_BSRR_OFFSET    0x18

// GPIO register access macros
#define GPIO_MODER(base)    (*(volatile uint32_t*)((base) + GPIO_MODER_OFFSET))
#define GPIO_OTYPER(base)   (*(volatile uint32_t*)((base) + GPIO_OTYPER_OFFSET))
#define GPIO_OSPEEDR(base)  (*(volatile uint32_t*)((base) + GPIO_OSPEEDR_OFFSET))
#define GPIO_PUPDR(base)    (*(volatile uint32_t*)((base) + GPIO_PUPDR_OFFSET))
#define GPIO_ODR(base)      (*(volatile uint32_t*)((base) + GPIO_ODR_OFFSET))
#define GPIO_BSRR(base)     (*(volatile uint32_t*)((base) + GPIO_BSRR_OFFSET))

// GPIO mode definitions
#define GPIO_MODE_INPUT     0x00
#define GPIO_MODE_OUTPUT    0x01
#define GPIO_MODE_AF        0x02
#define GPIO_MODE_ANALOG    0x03

// GPIO output type definitions
#define GPIO_OTYPE_PP       0x00  // Push-pull
#define GPIO_OTYPE_OD       0x01  // Open-drain

// GPIO speed definitions
#define GPIO_SPEED_LOW      0x00
#define GPIO_SPEED_MEDIUM   0x01
#define GPIO_SPEED_HIGH     0x02
#define GPIO_SPEED_VERY_HIGH 0x03

// GPIO pull-up/pull-down definitions
#define GPIO_PUPD_NONE      0x00
#define GPIO_PUPD_UP        0x01
#define GPIO_PUPD_DOWN      0x02

/**
 * @brief Configure a GPIO pin
 * @param gpio_base GPIO port base address
 * @param pin Pin number (0-15)
 * @param mode GPIO mode
 * @param otype Output type
 * @param speed GPIO speed
 * @param pupd Pull-up/pull-down configuration
 */
static void gpio_configure_pin(uint32_t gpio_base, uint8_t pin, uint8_t mode, 
                              uint8_t otype, uint8_t speed, uint8_t pupd)
{
    // Configure mode
    GPIO_MODER(gpio_base) = (GPIO_MODER(gpio_base) & ~(3UL << (pin * 2))) | 
                           (mode << (pin * 2));
    
    // Configure output type
    GPIO_OTYPER(gpio_base) = (GPIO_OTYPER(gpio_base) & ~(1UL << pin)) | 
                            (otype << pin);
    
    // Configure speed
    GPIO_OSPEEDR(gpio_base) = (GPIO_OSPEEDR(gpio_base) & ~(3UL << (pin * 2))) | 
                             (speed << (pin * 2));
    
    // Configure pull-up/pull-down
    GPIO_PUPDR(gpio_base) = (GPIO_PUPDR(gpio_base) & ~(3UL << (pin * 2))) | 
                           (pupd << (pin * 2));
}

/**
 * @brief Initialize GPIO for LED control
 */
void gpio_init(void)
{
    // Configure GPIOD pins 12, 13, 14, 15 as outputs for LEDs
    // STM32F4-Discovery board LED mapping:
    // PD12 - Green LED
    // PD13 - Orange LED  
    // PD14 - Red LED
    // PD15 - Blue LED
    
    gpio_configure_pin(GPIOD_BASE, 12, GPIO_MODE_OUTPUT, GPIO_OTYPE_PP, 
                      GPIO_SPEED_MEDIUM, GPIO_PUPD_NONE);
    gpio_configure_pin(GPIOD_BASE, 13, GPIO_MODE_OUTPUT, GPIO_OTYPE_PP, 
                      GPIO_SPEED_MEDIUM, GPIO_PUPD_NONE);
    gpio_configure_pin(GPIOD_BASE, 14, GPIO_MODE_OUTPUT, GPIO_OTYPE_PP, 
                      GPIO_SPEED_MEDIUM, GPIO_PUPD_NONE);
    gpio_configure_pin(GPIOD_BASE, 15, GPIO_MODE_OUTPUT, GPIO_OTYPE_PP, 
                      GPIO_SPEED_MEDIUM, GPIO_PUPD_NONE);
}

/**
 * @brief Set GPIO pin high
 * @param gpio_base GPIO port base address
 * @param pin Pin number (0-15)
 */
void gpio_set_pin(uint32_t gpio_base, uint8_t pin)
{
    GPIO_BSRR(gpio_base) = (1UL << pin);
}

/**
 * @brief Set GPIO pin low
 * @param gpio_base GPIO port base address
 * @param pin Pin number (0-15)
 */
void gpio_clear_pin(uint32_t gpio_base, uint8_t pin)
{
    GPIO_BSRR(gpio_base) = (1UL << (pin + 16));
}

/**
 * @brief Toggle GPIO pin
 * @param gpio_base GPIO port base address
 * @param pin Pin number (0-15)
 */
void gpio_toggle_pin(uint32_t gpio_base, uint8_t pin)
{
    if (GPIO_ODR(gpio_base) & (1UL << pin)) {
        gpio_clear_pin(gpio_base, pin);
    } else {
        gpio_set_pin(gpio_base, pin);
    }
}

/**
 * @brief Read GPIO pin state
 * @param gpio_base GPIO port base address
 * @param pin Pin number (0-15)
 * @return Pin state (0 or 1)
 */
uint8_t gpio_read_pin(uint32_t gpio_base, uint8_t pin)
{
    return (GPIO_ODR(gpio_base) & (1UL << pin)) ? 1 : 0;
}