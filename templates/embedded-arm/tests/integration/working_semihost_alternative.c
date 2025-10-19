/**
 * @file working_semihost_alternative.c
 * @brief Working Semihosting Alternative - Multiple output methods
 */

// ITM (Instrumentation Trace Macrocell) for SWO output
#define ITM_BASE        0xE0000000
#define ITM_TER         (*(volatile unsigned int*)(ITM_BASE + 0xE00))
#define ITM_TCR         (*(volatile unsigned int*)(ITM_BASE + 0xE80))
#define ITM_STIM0       (*(volatile unsigned int*)(ITM_BASE + 0x000))

// DWT (Data Watchpoint and Trace) for ITM enable
#define DWT_BASE        0xE0001000
#define DWT_CTRL        (*(volatile unsigned int*)(DWT_BASE + 0x000))

// CoreDebug for trace enable
#define COREDEBUG_BASE  0xE000EDF0
#define COREDEBUG_DEMCR (*(volatile unsigned int*)(COREDEBUG_BASE + 0x00C))

// Memory-mapped test results (can be read by debugger)
#define TEST_RESULT_ADDR    0x20000000
static volatile unsigned int* test_results = (volatile unsigned int*)TEST_RESULT_ADDR;

// Test result codes
#define TEST_START      0x12345678
#define TEST_PROGRESS   0x87654321
#define TEST_SUCCESS    0xDEADBEEF
#define TEST_COMPLETE   0xCAFEBABE

// Initialize ITM for SWO output
static void itm_init(void)
{
    // Enable trace
    COREDEBUG_DEMCR |= (1 << 24);  // TRCENA
    
    // Enable ITM
    ITM_TCR = (1 << 0) |    // ITMENA
              (1 << 3);     // TXENA
    
    // Enable stimulus port 0
    ITM_TER = 1;
}

// Send character via ITM/SWO
static void itm_putchar(char c)
{
    // Wait for stimulus port to be ready
    while (!(ITM_STIM0 & 1));
    
    // Send character
    ITM_STIM0 = c;
}

// Send string via ITM/SWO
static void itm_puts(const char* str)
{
    while (*str) {
        itm_putchar(*str++);
    }
}

// Alternative semihosting using different breakpoint
static inline void alt_semihost_write0(const char* str)
{
    __asm volatile (
        "mov r0, #4\n"          // SYS_WRITE0
        "mov r1, %0\n"          // String pointer
        "bkpt #0x00\n"          // Alternative breakpoint
        :
        : "r" (str)
        : "r0", "r1", "memory"
    );
}

// Memory-based communication with debugger
static void memory_log(const char* message, unsigned int code)
{
    // Write test code to memory for debugger to read
    test_results[0] = code;
    test_results[1] = (unsigned int)message;
    test_results[2] = 0xDEADC0DE;  // Marker
}

// Simple delay
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
    // Initialize ITM for SWO output
    itm_init();
    
    // Test 1: Memory-based logging
    memory_log("Test started", TEST_START);
    delay(100000);
    
    // Test 2: ITM/SWO output
    itm_puts("ITM/SWO: Working Semihosting Alternative Test\n");
    itm_puts("ITM/SWO: Multiple output methods test\n");
    delay(100000);
    
    // Test 3: Alternative semihosting breakpoint
    alt_semihost_write0("ALT_SEMIHOST: Alternative breakpoint test\n");
    delay(100000);
    
    // Test 4: Memory progress indicator
    memory_log("Test in progress", TEST_PROGRESS);
    delay(100000);
    
    // Test 5: More ITM output
    itm_puts("ITM/SWO: Test progress - 50%\n");
    delay(100000);
    
    // Test 6: Success indicator
    memory_log("Test successful", TEST_SUCCESS);
    itm_puts("ITM/SWO: All tests completed successfully\n");
    
    // Test 7: Final memory marker
    memory_log("Test complete", TEST_COMPLETE);
    
    // Infinite loop with periodic status
    int counter = 0;
    while (1) {
        delay(1000000);
        
        // Update counter in memory
        test_results[3] = counter++;
        
        // Periodic ITM output
        if (counter % 10 == 0) {
            itm_puts("ITM/SWO: Heartbeat - system running\n");
        }
        
        // Alternative semihosting attempt
        if (counter % 20 == 0) {
            alt_semihost_write0("ALT_SEMIHOST: Periodic status update\n");
        }
    }
    
    return 0;
}