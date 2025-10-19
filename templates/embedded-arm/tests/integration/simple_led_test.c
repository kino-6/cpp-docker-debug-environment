/**
 * @file simple_led_test.c
 * @brief Simple LED Test - Visual confirmation of ARM execution
 */

// GPIO register definitions for STM32F4
#define GPIOD_BASE      0x40020C00
#define GPIOD_MODER     (*(volatile unsigned int*)(GPIOD_BASE + 0x00))
#define GPIOD_ODR       (*(volatile unsigned int*)(GPIOD_BASE + 0x14))

// RCC register definitions
#define RCC_BASE        0x40023800
#define RCC_AHB1ENR     (*(volatile unsigned int*)(RCC_BASE + 0x30))

// LED pins on STM32F4 Discovery (GPIOD)
#define LED_GREEN       (1 << 12)   // PD12
#define LED_ORANGE      (1 << 13)   // PD13
#define LED_RED         (1 << 14)   // PD14
#define LED_BLUE        (1 << 15)   // PD15

// Simple delay function
static void delay(volatile unsigned int count)
{
    while (count--) {
        __asm("nop");
    }
}

// Initialize GPIO for LEDs
static void led_init(void)
{
    // Enable GPIOD clock
    RCC_AHB1ENR |= (1 << 3);    // GPIOD clock enable
    
    // Configure PD12-PD15 as output
    GPIOD_MODER &= ~((3 << 24) | (3 << 26) | (3 << 28) | (3 << 30));  // Clear mode bits
    GPIOD_MODER |= (1 << 24) | (1 << 26) | (1 << 28) | (1 << 30);     // Output mode
}

// Set LED state
static void led_set(unsigned int leds)
{
    GPIOD_ODR = (GPIOD_ODR & 0x0FFF) | (leds & 0xF000);
}

// Knight Rider pattern
static void knight_rider_pattern(void)
{
    const unsigned int pattern[] = {
        LED_GREEN,
        LED_ORANGE,
        LED_RED,
        LED_BLUE,
        LED_RED,
        LED_ORANGE
    };
    
    for (int i = 0; i < 6; i++) {
        led_set(pattern[i]);
        delay(500000);  // Visible delay
    }
}

// Vector table
__attribute__((section(".isr_vector")))
const void* vector_table[] = {
    (void*)0x20020000,          // Initial stack pointer
    (void*)0x08000009,          // Reset handler (thumb mode)
};

// Reset handler
__attribute__((naked, noreturn))
void Reset_Handler(void)
{
    // Set stack pointer
    __asm volatile ("ldr sp, =0x20020000");
    
    // Call main
    __asm volatile ("bl main");
    
    // Infinite loop
    __asm volatile ("b .");
}

int main(void)
{
    // Initialize LEDs
    led_init();
    
    // Initial pattern - all LEDs on briefly
    led_set(LED_GREEN | LED_ORANGE | LED_RED | LED_BLUE);
    delay(1000000);
    
    // Turn off all LEDs
    led_set(0);
    delay(500000);
    
    // Run Knight Rider pattern continuously
    while (1) {
        knight_rider_pattern();
    }
    
    return 0;
}