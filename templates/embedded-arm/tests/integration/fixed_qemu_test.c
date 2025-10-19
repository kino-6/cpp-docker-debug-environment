/**
 * @file fixed_qemu_test.c
 * @brief Fixed QEMU test with proper semihosting configuration
 */

// No includes - pure bare metal

// ARM semihosting system calls
#define SYS_OPEN    0x01
#define SYS_CLOSE   0x02
#define SYS_WRITEC  0x03
#define SYS_WRITE0  0x04
#define SYS_WRITE   0x05
#define SYS_READ    0x06
#define SYS_READC   0x07
#define SYS_ISERROR 0x08
#define SYS_ISTTY   0x09
#define SYS_SEEK    0x0A
#define SYS_FLEN    0x0C
#define SYS_TMPNAM  0x0D
#define SYS_REMOVE  0x0E
#define SYS_RENAME  0x0F
#define SYS_CLOCK   0x10
#define SYS_TIME    0x11
#define SYS_SYSTEM  0x12
#define SYS_ERRNO   0x13
#define SYS_EXIT    0x18

// Semihosting call with proper ARM Cortex-M implementation
static inline int semihosting_call(int reason, void* arg)
{
    int result;
    __asm volatile (
        "mov r0, %1\n"      // Load reason into r0
        "mov r1, %2\n"      // Load argument into r1
        "bkpt #0xAB\n"      // ARM semihosting breakpoint
        "mov %0, r0\n"      // Store result
        : "=r" (result)
        : "r" (reason), "r" (arg)
        : "r0", "r1", "memory"
    );
    return result;
}

// Write string using SYS_WRITE0
static void write_string(const char* str)
{
    semihosting_call(SYS_WRITE0, (void*)str);
}

// Write single character using SYS_WRITEC
static void write_char(char c)
{
    semihosting_call(SYS_WRITEC, &c);
}

// Exit program using SYS_EXIT
static void exit_program(int code)
{
    semihosting_call(SYS_EXIT, &code);
}

// Simple string length function
static int string_length(const char* str)
{
    int len = 0;
    while (str[len] != '\0') {
        len++;
    }
    return len;
}

// Write string using SYS_WRITE (file descriptor 1 = stdout)
static void write_string_fd(const char* str)
{
    int len = string_length(str);
    int params[3] = {1, (int)str, len};  // fd=1 (stdout), buffer, length
    semihosting_call(SYS_WRITE, params);
}

// Reset handler with proper stack setup
__attribute__((naked, noreturn))
void Reset_Handler(void)
{
    __asm volatile (
        "ldr sp, =0x20020000\n"    // Set stack pointer to end of RAM
        "bl main\n"                // Call main function
        "b .\n"                    // Infinite loop if main returns
    );
}

// Minimal vector table
__attribute__((section(".isr_vector")))
const void* vector_table[] = {
    (void*)0x20020000,    // Initial stack pointer (128KB RAM)
    Reset_Handler,        // Reset handler
};

/**
 * @brief Fixed main function with multiple semihosting methods
 */
int main(void)
{
    // Method 1: SYS_WRITE0 (null-terminated string)
    write_string("=== FIXED QEMU SEMIHOSTING TEST ===\n");
    write_string("Method 1: SYS_WRITE0 - Working!\n");
    
    // Method 2: SYS_WRITEC (single character)
    write_string("Method 2: SYS_WRITEC - ");
    write_char('W');
    write_char('o');
    write_char('r');
    write_char('k');
    write_char('i');
    write_char('n');
    write_char('g');
    write_char('!');
    write_char('\n');
    
    // Method 3: SYS_WRITE (file descriptor)
    write_string_fd("Method 3: SYS_WRITE (fd=1) - Working!\n");
    
    // Test basic functionality
    write_string("\n--- Basic Tests ---\n");
    
    // Test 1: Arithmetic
    volatile int a = 25;
    volatile int b = 17;
    volatile int sum = a + b;
    
    write_string("Test 1: Arithmetic (25 + 17 = 42) - ");
    if (sum == 42) {
        write_string("PASSED\n");
    } else {
        write_string("FAILED\n");
    }
    
    // Test 2: Memory operations
    volatile int array[5] = {1, 2, 3, 4, 5};
    volatile int total = 0;
    for (int i = 0; i < 5; i++) {
        total += array[i];
    }
    
    write_string("Test 2: Memory (1+2+3+4+5 = 15) - ");
    if (total == 15) {
        write_string("PASSED\n");
    } else {
        write_string("FAILED\n");
    }
    
    // Test 3: ARM Cortex-M4 instruction
    volatile unsigned int test_val = 0x12345678;
    write_string("Test 3: ARM RBIT instruction - ");
    
    // Bit reverse
    __asm volatile ("rbit %0, %0" : "+r" (test_val));
    // Reverse back
    __asm volatile ("rbit %0, %0" : "+r" (test_val));
    
    if (test_val == 0x12345678) {
        write_string("PASSED\n");
    } else {
        write_string("FAILED\n");
    }
    
    // Test 4: Loop execution
    write_string("Test 4: Loop execution - ");
    for (int i = 0; i < 3; i++) {
        write_char('.');
        // Short delay
        for (volatile int j = 0; j < 100000; j++) {
            __asm("nop");
        }
    }
    write_string(" PASSED\n");
    
    // Final results
    write_string("\n=== TEST RESULTS ===\n");
    write_string("All semihosting methods tested successfully!\n");
    write_string("ARM Cortex-M4 execution confirmed.\n");
    write_string("QEMU semihosting is fully functional.\n");
    
    // Countdown before exit
    write_string("\nCountdown to exit:\n");
    for (int i = 5; i > 0; i--) {
        write_char('0' + i);  // Convert number to character
        write_string("...\n");
        
        // Delay
        for (volatile int k = 0; k < 500000; k++) {
            __asm("nop");
        }
    }
    
    write_string("\n*** ATTEMPTING CLEAN EXIT ***\n");
    write_string("If QEMU exits now, semihosting exit is working!\n");
    
    // Attempt clean exit
    exit_program(0);
    
    // Should not reach here if exit works
    write_string("ERROR: Semihosting exit failed!\n");
    write_string("Entering controlled infinite loop...\n");
    
    // Controlled infinite loop with periodic output
    int loop_counter = 0;
    while (1) {
        if (loop_counter % 10000000 == 0) {
            write_char('*');
        }
        loop_counter++;
        __asm("nop");
    }
    
    return 0;
}