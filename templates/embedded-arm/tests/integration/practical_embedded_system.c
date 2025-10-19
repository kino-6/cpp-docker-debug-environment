/**
 * @file practical_embedded_system.c
 * @brief Practical Embedded System - Real-world embedded development example
 */

#include <stdint.h>
#include <stdbool.h>

// STM32F4 System Control Block (SCB) registers
#define SCB_BASE            0xE000ED00
#define SCB_VTOR            (*(volatile uint32_t*)(SCB_BASE + 0x08))

// SysTick Timer registers
#define SYSTICK_BASE        0xE000E010
#define SYSTICK_CTRL        (*(volatile uint32_t*)(SYSTICK_BASE + 0x00))
#define SYSTICK_LOAD        (*(volatile uint32_t*)(SYSTICK_BASE + 0x04))
#define SYSTICK_VAL         (*(volatile uint32_t*)(SYSTICK_BASE + 0x08))

// GPIO register definitions for STM32F4
#define GPIOD_BASE          0x40020C00
#define GPIOD_MODER         (*(volatile uint32_t*)(GPIOD_BASE + 0x00))
#define GPIOD_ODR           (*(volatile uint32_t*)(GPIOD_BASE + 0x14))
#define GPIOD_IDR           (*(volatile uint32_t*)(GPIOD_BASE + 0x10))

#define GPIOA_BASE          0x40020000
#define GPIOA_MODER         (*(volatile uint32_t*)(GPIOA_BASE + 0x00))
#define GPIOA_IDR           (*(volatile uint32_t*)(GPIOA_BASE + 0x10))

// UART register definitions
#define USART2_BASE         0x40004400
#define USART_SR            (*(volatile uint32_t*)(USART2_BASE + 0x00))
#define USART_DR            (*(volatile uint32_t*)(USART2_BASE + 0x04))
#define USART_BRR           (*(volatile uint32_t*)(USART2_BASE + 0x08))
#define USART_CR1           (*(volatile uint32_t*)(USART2_BASE + 0x0C))

// RCC register definitions
#define RCC_BASE            0x40023800
#define RCC_AHB1ENR         (*(volatile uint32_t*)(RCC_BASE + 0x30))
#define RCC_APB1ENR         (*(volatile uint32_t*)(RCC_BASE + 0x40))

// LED definitions
#define LED_GREEN           (1 << 12)   // PD12
#define LED_ORANGE          (1 << 13)   // PD13
#define LED_RED             (1 << 14)   // PD14
#define LED_BLUE            (1 << 15)   // PD15

// System constants
#define SYSTEM_CLOCK_HZ     16000000
#define SYSTICK_FREQ_HZ     1000        // 1ms tick
#define UART_BAUD_RATE      115200

// System state machine
typedef enum {
    STATE_INIT,
    STATE_IDLE,
    STATE_LED_PATTERN_1,
    STATE_LED_PATTERN_2,
    STATE_UART_COMM,
    STATE_ERROR
} system_state_t;

// Global system variables
static volatile uint32_t system_tick_ms = 0;
static volatile system_state_t current_state = STATE_INIT;
static volatile uint32_t state_timer = 0;
static volatile uint32_t led_pattern_counter = 0;
static volatile bool uart_data_ready = false;
static volatile uint8_t uart_rx_buffer[64];
static volatile uint8_t uart_rx_index = 0;

// Performance counters
static volatile uint32_t interrupt_count = 0;
static volatile uint32_t state_transitions = 0;
static volatile uint32_t uart_messages_sent = 0;

// Function prototypes
void system_init(void);
void systick_init(void);
void gpio_init(void);
void uart_init(void);
void led_set(uint32_t leds);
void uart_send_string(const char* str);
void uart_send_status(void);
void process_state_machine(void);
void led_pattern_1(void);
void led_pattern_2(void);

// SysTick interrupt handler
void SysTick_Handler(void) __attribute__((interrupt));
void SysTick_Handler(void)
{
    system_tick_ms++;
    interrupt_count++;
    
    // State timer management
    if (state_timer > 0) {
        state_timer--;
    }
    
    // Periodic status update every 5 seconds
    if ((system_tick_ms % 5000) == 0) {
        uart_send_status();
    }
}

// System initialization
void system_init(void)
{
    // Enable clocks
    RCC_AHB1ENR |= (1 << 0) | (1 << 3);    // GPIOA and GPIOD
    RCC_APB1ENR |= (1 << 17);              // USART2
    
    // Initialize subsystems
    systick_init();
    gpio_init();
    uart_init();
    
    current_state = STATE_IDLE;
    state_timer = 1000;  // 1 second initial delay
}

// SysTick timer initialization
void systick_init(void)
{
    // Configure SysTick for 1ms interrupts
    SYSTICK_LOAD = (SYSTEM_CLOCK_HZ / SYSTICK_FREQ_HZ) - 1;
    SYSTICK_VAL = 0;
    SYSTICK_CTRL = (1 << 2) | (1 << 1) | (1 << 0);  // Clock source, interrupt enable, enable
}

// GPIO initialization
void gpio_init(void)
{
    // Configure LEDs (PD12-PD15) as outputs
    GPIOD_MODER &= ~((3 << 24) | (3 << 26) | (3 << 28) | (3 << 30));
    GPIOD_MODER |= (1 << 24) | (1 << 26) | (1 << 28) | (1 << 30);
    
    // Configure PA0 as input (user button simulation)
    GPIOA_MODER &= ~(3 << 0);
    
    // Initial LED state - all off
    led_set(0);
}

// UART initialization
void uart_init(void)
{
    // Configure PA2 (TX) and PA3 (RX) as alternate function
    GPIOA_MODER &= ~((3 << 4) | (3 << 6));
    GPIOA_MODER |= (2 << 4) | (2 << 6);
    
    // Configure USART2
    USART_BRR = SYSTEM_CLOCK_HZ / UART_BAUD_RATE;
    USART_CR1 = (1 << 13) | (1 << 3) | (1 << 2);  // UE, TE, RE
}

// LED control function
void led_set(uint32_t leds)
{
    GPIOD_ODR = (GPIOD_ODR & 0x0FFF) | (leds & 0xF000);
}

// UART send string function
void uart_send_string(const char* str)
{
    while (*str) {
        while (!(USART_SR & (1 << 7)));  // Wait for TXE
        USART_DR = *str++;
    }
    uart_messages_sent++;
}

// Send system status via UART
void uart_send_status(void)
{
    static char status_buffer[128];
    
    // Simple sprintf implementation for status
    uart_send_string("=== System Status ===\r\n");
    uart_send_string("Uptime: ");
    
    // Convert system_tick_ms to seconds (simple implementation)
    uint32_t seconds = system_tick_ms / 1000;
    if (seconds < 10) uart_send_string("0");
    uart_send_string("s\r\n");
    
    uart_send_string("State: ");
    switch (current_state) {
        case STATE_INIT: uart_send_string("INIT"); break;
        case STATE_IDLE: uart_send_string("IDLE"); break;
        case STATE_LED_PATTERN_1: uart_send_string("LED_PATTERN_1"); break;
        case STATE_LED_PATTERN_2: uart_send_string("LED_PATTERN_2"); break;
        case STATE_UART_COMM: uart_send_string("UART_COMM"); break;
        case STATE_ERROR: uart_send_string("ERROR"); break;
        default: uart_send_string("UNKNOWN"); break;
    }
    uart_send_string("\r\n");
    
    uart_send_string("Interrupts: ");
    // Simple number to string conversion
    if (interrupt_count > 1000) uart_send_string("1000+");
    else uart_send_string("< 1000");
    uart_send_string("\r\n");
    
    uart_send_string("Transitions: ");
    if (state_transitions > 100) uart_send_string("100+");
    else uart_send_string("< 100");
    uart_send_string("\r\n");
    
    uart_send_string("=====================\r\n\r\n");
}

// LED Pattern 1: Sequential
void led_pattern_1(void)
{
    uint32_t pattern_step = (led_pattern_counter / 200) % 4;  // Change every 200ms
    
    switch (pattern_step) {
        case 0: led_set(LED_GREEN); break;
        case 1: led_set(LED_ORANGE); break;
        case 2: led_set(LED_RED); break;
        case 3: led_set(LED_BLUE); break;
    }
}

// LED Pattern 2: Binary counter
void led_pattern_2(void)
{
    uint32_t pattern_step = (led_pattern_counter / 500) % 16;  // Change every 500ms
    
    uint32_t led_state = 0;
    if (pattern_step & 1) led_state |= LED_GREEN;
    if (pattern_step & 2) led_state |= LED_ORANGE;
    if (pattern_step & 4) led_state |= LED_RED;
    if (pattern_step & 8) led_state |= LED_BLUE;
    
    led_set(led_state);
}

// Main state machine processing
void process_state_machine(void)
{
    static uint32_t last_tick = 0;
    
    // Update pattern counter
    if (system_tick_ms != last_tick) {
        led_pattern_counter++;
        last_tick = system_tick_ms;
    }
    
    switch (current_state) {
        case STATE_INIT:
            // Initialization complete, move to idle
            if (state_timer == 0) {
                current_state = STATE_IDLE;
                state_timer = 2000;  // 2 seconds in idle
                state_transitions++;
                uart_send_string("System initialized - entering IDLE state\r\n");
            }
            break;
            
        case STATE_IDLE:
            led_set(LED_GREEN);  // Green LED indicates idle
            
            if (state_timer == 0) {
                current_state = STATE_LED_PATTERN_1;
                state_timer = 3000;  // 3 seconds of pattern 1
                state_transitions++;
                uart_send_string("Entering LED Pattern 1 state\r\n");
            }
            break;
            
        case STATE_LED_PATTERN_1:
            led_pattern_1();
            
            if (state_timer == 0) {
                current_state = STATE_LED_PATTERN_2;
                state_timer = 4000;  // 4 seconds of pattern 2
                state_transitions++;
                uart_send_string("Entering LED Pattern 2 state\r\n");
            }
            break;
            
        case STATE_LED_PATTERN_2:
            led_pattern_2();
            
            if (state_timer == 0) {
                current_state = STATE_UART_COMM;
                state_timer = 2000;  // 2 seconds of UART communication
                state_transitions++;
                uart_send_string("Entering UART Communication state\r\n");
            }
            break;
            
        case STATE_UART_COMM:
            // Blink blue LED during UART communication
            if ((system_tick_ms % 100) < 50) {
                led_set(LED_BLUE);
            } else {
                led_set(0);
            }
            
            // Send periodic messages
            if ((system_tick_ms % 500) == 0) {
                uart_send_string("UART Communication active\r\n");
            }
            
            if (state_timer == 0) {
                current_state = STATE_IDLE;
                state_timer = 2000;  // Return to idle
                state_transitions++;
                uart_send_string("Returning to IDLE state\r\n");
            }
            break;
            
        case STATE_ERROR:
            // Error state - fast red blink
            if ((system_tick_ms % 100) < 50) {
                led_set(LED_RED);
            } else {
                led_set(0);
            }
            
            // Stay in error state
            break;
            
        default:
            current_state = STATE_ERROR;
            state_transitions++;
            uart_send_string("ERROR: Unknown state detected\r\n");
            break;
    }
}

// Vector table
__attribute__((section(".isr_vector")))
const void* vector_table[] = {
    (void*)0x20020000,          // Initial stack pointer
    (void*)0x08000009,          // Reset handler (thumb mode)
    0,                          // NMI handler
    0,                          // Hard fault handler
    0, 0, 0, 0, 0, 0, 0,       // Reserved
    0,                          // SVCall handler
    0, 0,                       // Reserved
    0,                          // PendSV handler
    SysTick_Handler,            // SysTick handler
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
    // Initialize system
    system_init();
    
    // Send startup message
    uart_send_string("\r\n=== Practical Embedded System Started ===\r\n");
    uart_send_string("Features: SysTick, GPIO, UART, State Machine\r\n");
    uart_send_string("System Clock: 16MHz, SysTick: 1ms\r\n");
    uart_send_string("==========================================\r\n\r\n");
    
    // Main application loop
    while (1) {
        process_state_machine();
        
        // Yield CPU briefly (power saving simulation)
        __asm volatile ("wfi");  // Wait for interrupt
    }
    
    return 0;
}