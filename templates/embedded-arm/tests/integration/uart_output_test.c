/**
 * @file uart_output_test.c
 * @brief UART Output Test - Alternative to Semihosting
 */

// UART register definitions for STM32F4
#define USART2_BASE     0x40004400
#define USART_SR        (*(volatile unsigned int*)(USART2_BASE + 0x00))
#define USART_DR        (*(volatile unsigned int*)(USART2_BASE + 0x04))
#define USART_BRR       (*(volatile unsigned int*)(USART2_BASE + 0x08))
#define USART_CR1       (*(volatile unsigned int*)(USART2_BASE + 0x0C))

// RCC register definitions
#define RCC_BASE        0x40023800
#define RCC_AHB1ENR     (*(volatile unsigned int*)(RCC_BASE + 0x30))
#define RCC_APB1ENR     (*(volatile unsigned int*)(RCC_BASE + 0x40))

// GPIO register definitions
#define GPIOA_BASE      0x40020000
#define GPIOA_MODER     (*(volatile unsigned int*)(GPIOA_BASE + 0x00))
#define GPIOA_AFRL      (*(volatile unsigned int*)(GPIOA_BASE + 0x20))

// UART status bits
#define USART_SR_TXE    (1 << 7)    // Transmit data register empty
#define USART_SR_TC     (1 << 6)    // Transmission complete

// Simple UART initialization
static void uart_init(void)
{
    // Enable GPIOA and USART2 clocks
    RCC_AHB1ENR |= (1 << 0);    // GPIOA clock
    RCC_APB1ENR |= (1 << 17);   // USART2 clock
    
    // Configure PA2 (TX) and PA3 (RX) as alternate function
    GPIOA_MODER &= ~((3 << 4) | (3 << 6));     // Clear mode bits
    GPIOA_MODER |= (2 << 4) | (2 << 6);        // Alternate function mode
    
    // Set alternate function to AF7 (USART2)
    GPIOA_AFRL &= ~((15 << 8) | (15 << 12));   // Clear AF bits
    GPIOA_AFRL |= (7 << 8) | (7 << 12);        // AF7 for USART2
    
    // Configure USART2
    // Assuming 16MHz clock, 115200 baud rate
    USART_BRR = 139;            // 16000000 / 115200 ≈ 139
    USART_CR1 = (1 << 13) |     // UE: USART enable
                (1 << 3) |      // TE: Transmitter enable
                (1 << 2);       // RE: Receiver enable
}

// Send character via UART
static void uart_putchar(char c)
{
    // Wait for transmit data register to be empty
    while (!(USART_SR & USART_SR_TXE));
    
    // Send character
    USART_DR = c;
    
    // Wait for transmission to complete
    while (!(USART_SR & USART_SR_TC));
}

// Send string via UART
static void uart_puts(const char* str)
{
    while (*str) {
        uart_putchar(*str++);
    }
}

// Simple delay function
static void delay(volatile unsigned int count)
{
    while (count--) {
        __asm("nop");
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
    // Initialize UART
    uart_init();
    
    // Small delay to ensure UART is ready
    delay(100000);
    
    // Send test messages
    uart_puts("UART OUTPUT TEST START\r\n");
    uart_puts("========================\r\n");
    uart_puts("Test 1: Basic UART output - PASSED\r\n");
    uart_puts("Test 2: Multiple messages - PASSED\r\n");
    uart_puts("Test 3: Character transmission - PASSED\r\n");
    uart_puts("========================\r\n");
    uart_puts("UART OUTPUT TEST COMPLETE\r\n");
    
    // Infinite loop (since we can't exit cleanly without semihosting)
    while (1) {
        delay(1000000);
        uart_puts("Heartbeat: UART still working\r\n");
    }
    
    return 0;
}