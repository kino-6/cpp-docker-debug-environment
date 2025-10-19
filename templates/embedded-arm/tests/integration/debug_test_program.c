/**
 * @file debug_test_program.c
 * @brief Debug Test Program - Comprehensive GDB debugging test
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

// Global variables for debugging
static volatile unsigned int debug_counter = 0;
static volatile unsigned int led_state = 0;
static volatile unsigned int loop_iteration = 0;

// Debug breakpoint markers
static volatile unsigned int breakpoint_marker_1 = 0xDEADBEEF;
static volatile unsigned int breakpoint_marker_2 = 0xCAFEBABE;
static volatile unsigned int breakpoint_marker_3 = 0x12345678;

// Simple delay function with debug info
static void debug_delay(volatile unsigned int count)
{
    debug_counter = count;  // Breakpoint: inspect debug_counter
    
    while (count--) {
        __asm("nop");
        
        // Update counter every 10000 iterations for debugging
        if ((count % 10000) == 0) {
            debug_counter = count;  // Breakpoint: watch counter decrease
        }
    }
    
    debug_counter = 0;  // Breakpoint: confirm delay completion
}

// Initialize GPIO for LEDs with debug info
static void debug_led_init(void)
{
    breakpoint_marker_1 = 0x11111111;  // Breakpoint: LED init start
    
    // Enable GPIOD clock
    RCC_AHB1ENR |= (1 << 3);    // Breakpoint: inspect RCC register
    
    // Configure PD12-PD15 as output
    unsigned int moder_before = GPIOD_MODER;  // Breakpoint: inspect before
    GPIOD_MODER &= ~((3 << 24) | (3 << 26) | (3 << 28) | (3 << 30));
    GPIOD_MODER |= (1 << 24) | (1 << 26) | (1 << 28) | (1 << 30);
    unsigned int moder_after = GPIOD_MODER;   // Breakpoint: inspect after
    
    // Suppress unused variable warnings
    (void)moder_before;
    (void)moder_after;
    
    breakpoint_marker_1 = 0x22222222;  // Breakpoint: LED init complete
}

// Set LED state with debug info
static void debug_led_set(unsigned int leds)
{
    led_state = leds;  // Breakpoint: inspect LED state
    
    unsigned int odr_before = GPIOD_ODR;  // Breakpoint: inspect before
    GPIOD_ODR = (GPIOD_ODR & 0x0FFF) | (leds & 0xF000);
    unsigned int odr_after = GPIOD_ODR;   // Breakpoint: inspect after
    
    // Suppress unused variable warnings
    (void)odr_before;
    (void)odr_after;
}

// Debug pattern function
static void debug_pattern_step(int step)
{
    breakpoint_marker_2 = 0x33330000 | step;  // Breakpoint: pattern step
    
    switch (step) {
        case 0:
            debug_led_set(LED_GREEN);
            break;
        case 1:
            debug_led_set(LED_ORANGE);
            break;
        case 2:
            debug_led_set(LED_RED);
            break;
        case 3:
            debug_led_set(LED_BLUE);
            break;
        case 4:
            debug_led_set(LED_RED);
            break;
        case 5:
            debug_led_set(LED_ORANGE);
            break;
        default:
            debug_led_set(0);  // All LEDs off
            break;
    }
    
    breakpoint_marker_2 = 0x44440000 | step;  // Breakpoint: pattern complete
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
    breakpoint_marker_3 = 0x55555555;  // Breakpoint: main start
    
    // Initialize LEDs
    debug_led_init();
    
    // Initial pattern - all LEDs on briefly
    debug_led_set(LED_GREEN | LED_ORANGE | LED_RED | LED_BLUE);
    debug_delay(500000);
    
    // Turn off all LEDs
    debug_led_set(0);
    debug_delay(250000);
    
    breakpoint_marker_3 = 0x66666666;  // Breakpoint: pattern loop start
    
    // Run debug pattern with controlled iterations
    for (loop_iteration = 0; loop_iteration < 20; loop_iteration++) {
        // Breakpoint: inspect loop_iteration
        
        for (int step = 0; step < 6; step++) {
            debug_pattern_step(step);
            debug_delay(300000);  // Breakpoint: step through pattern
        }
        
        // Breakpoint: end of iteration
        if (loop_iteration >= 19) {
            break;  // Exit after 20 iterations for debugging
        }
    }
    
    breakpoint_marker_3 = 0x77777777;  // Breakpoint: program end
    
    // Final state - all LEDs off
    debug_led_set(0);
    
    // Controlled exit for debugging (not infinite loop)
    while (1) {
        debug_delay(1000000);
        
        // Breakpoint: final loop
        if (debug_counter == 0) {
            // This condition is always true after delay
            continue;
        }
    }
    
    return 0;
}