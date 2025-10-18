/**
 * @file system_init.c
 * @brief System initialization for STM32F407VG
 * @author Embedded Development Template
 */

#include "system_init.h"
#include <stdint.h>

// STM32F407VG Register definitions (simplified)
#define RCC_BASE            0x40023800UL
#define RCC_CR              (*(volatile uint32_t*)(RCC_BASE + 0x00))
#define RCC_PLLCFGR         (*(volatile uint32_t*)(RCC_BASE + 0x04))
#define RCC_CFGR            (*(volatile uint32_t*)(RCC_BASE + 0x08))
#define RCC_AHB1ENR         (*(volatile uint32_t*)(RCC_BASE + 0x30))

// Flash interface register
#define FLASH_BASE          0x40023C00UL
#define FLASH_ACR           (*(volatile uint32_t*)(FLASH_BASE + 0x00))

// System Control Block
#define SCB_BASE            0xE000ED00UL
#define SCB_VTOR            (*(volatile uint32_t*)(SCB_BASE + 0x08))

// RCC bit definitions
#define RCC_CR_HSEON        (1UL << 16)
#define RCC_CR_HSERDY       (1UL << 17)
#define RCC_CR_PLLON        (1UL << 24)
#define RCC_CR_PLLRDY       (1UL << 25)

#define RCC_CFGR_SW_PLL     (2UL << 0)
#define RCC_CFGR_SWS_PLL    (2UL << 2)

// Flash latency for 168MHz
#define FLASH_ACR_LATENCY_5WS   (5UL << 0)
#define FLASH_ACR_PRFTEN        (1UL << 8)
#define FLASH_ACR_ICEN          (1UL << 9)
#define FLASH_ACR_DCEN          (1UL << 10)

/**
 * @brief Configure system clock to 168MHz using HSE and PLL
 * @note This is a simplified clock configuration for STM32F407VG
 */
static void configure_system_clock(void)
{
    // Enable HSE (High Speed External oscillator)
    RCC_CR |= RCC_CR_HSEON;
    
    // Wait for HSE to be ready
    while (!(RCC_CR & RCC_CR_HSERDY)) {
        // Timeout handling could be added here
    }
    
    // Configure Flash latency for 168MHz operation
    FLASH_ACR = FLASH_ACR_LATENCY_5WS | FLASH_ACR_PRFTEN | FLASH_ACR_ICEN | FLASH_ACR_DCEN;
    
    // Configure PLL: HSE(8MHz) -> 168MHz
    // PLL_VCO = (HSE_VALUE / PLL_M) * PLL_N = (8 / 8) * 336 = 336MHz
    // SYSCLK = PLL_VCO / PLL_P = 336 / 2 = 168MHz
    RCC_PLLCFGR = (8UL << 0)      |  // PLL_M = 8
                  (336UL << 6)    |  // PLL_N = 336
                  (0UL << 16)     |  // PLL_P = 2 (00: /2)
                  (7UL << 24)     |  // PLL_Q = 7
                  (1UL << 22);       // PLL source = HSE
    
    // Enable PLL
    RCC_CR |= RCC_CR_PLLON;
    
    // Wait for PLL to be ready
    while (!(RCC_CR & RCC_CR_PLLRDY)) {
        // Timeout handling could be added here
    }
    
    // Select PLL as system clock source
    RCC_CFGR = (RCC_CFGR & ~(3UL << 0)) | RCC_CFGR_SW_PLL;
    
    // Wait for PLL to be used as system clock source
    while ((RCC_CFGR & (3UL << 2)) != RCC_CFGR_SWS_PLL) {
        // Timeout handling could be added here
    }
}

/**
 * @brief Enable peripheral clocks
 */
static void configure_peripheral_clocks(void)
{
    // Enable GPIOD clock (for LEDs on STM32F4-Discovery)
    RCC_AHB1ENR |= (1UL << 3);  // GPIODEN
    
    // Enable GPIOA clock (for additional GPIO if needed)
    RCC_AHB1ENR |= (1UL << 0);  // GPIOAEN
}

/**
 * @brief Initialize system
 */
void system_init(void)
{
    // Configure system clock to 168MHz
    configure_system_clock();
    
    // Enable peripheral clocks
    configure_peripheral_clocks();
    
    // Configure vector table location (if needed)
    // SCB_VTOR = FLASH_BASE; // Vector table in Flash
}