#include "unity.h"
#include "mock_gpio.h"
#include <stdint.h>
#include <stdbool.h>

// Simple LED logic for testing (embedded in test file for simplicity)
typedef struct {
    bool is_initialized;
    bool is_on;
    uint32_t gpio_base;
    uint32_t pin_mask;
} led_state_t;

static led_state_t led_state = {0};

// LED functions to test
void led_init(uint32_t gpio_base, uint32_t pin_mask) {
    // Initialize GPIO (mocked)
    mock_gpio_init(gpio_base);
    
    // Set pin as output (mocked)
    mock_gpio_set_mode(gpio_base, pin_mask, GPIO_MODE_OUTPUT);
    
    // Initialize LED state
    led_state.is_initialized = true;
    led_state.is_on = false;
    led_state.gpio_base = gpio_base;
    led_state.pin_mask = pin_mask;
}

void led_set_on(void) {
    if (!led_state.is_initialized) return;
    
    // Set GPIO pin high (mocked)
    mock_gpio_set_pin(led_state.gpio_base, led_state.pin_mask);
    led_state.is_on = true;
}

void led_set_off(void) {
    if (!led_state.is_initialized) return;
    
    // Set GPIO pin low (mocked)
    mock_gpio_clear_pin(led_state.gpio_base, led_state.pin_mask);
    led_state.is_on = false;
}

void led_toggle(void) {
    if (!led_state.is_initialized) return;
    
    if (led_state.is_on) {
        led_set_off();
    } else {
        led_set_on();
    }
}

bool led_is_on(void) {
    return led_state.is_on;
}

// Unity test setup and teardown
void setUp(void) {
    // Reset LED state before each test
    led_state.is_initialized = false;
    led_state.is_on = false;
    led_state.gpio_base = 0;
    led_state.pin_mask = 0;
    
    // Reset mock expectations
    mock_gpio_reset();
}

void tearDown(void) {
    // Clean up after each test
    mock_gpio_verify();
}

// Test cases
void test_led_init(void) {
    uint32_t test_gpio_base = 0x40020C00;  // GPIOD base
    uint32_t test_pin_mask = 0x0000F000;   // Pins 12-15
    
    // Set expectations for mock calls
    mock_gpio_expect_init(test_gpio_base);
    mock_gpio_expect_set_mode(test_gpio_base, test_pin_mask, GPIO_MODE_OUTPUT);
    
    // Call function under test
    led_init(test_gpio_base, test_pin_mask);
    
    // Verify state
    TEST_ASSERT_TRUE(led_state.is_initialized);
    TEST_ASSERT_FALSE(led_state.is_on);
    TEST_ASSERT_EQUAL_UINT32(test_gpio_base, led_state.gpio_base);
    TEST_ASSERT_EQUAL_UINT32(test_pin_mask, led_state.pin_mask);
}

void test_led_set_on(void) {
    uint32_t test_gpio_base = 0x40020C00;
    uint32_t test_pin_mask = 0x0000F000;
    
    // Initialize LED first
    mock_gpio_expect_init(test_gpio_base);
    mock_gpio_expect_set_mode(test_gpio_base, test_pin_mask, GPIO_MODE_OUTPUT);
    led_init(test_gpio_base, test_pin_mask);
    
    // Set expectation for LED on
    mock_gpio_expect_set_pin(test_gpio_base, test_pin_mask);
    
    // Call function under test
    led_set_on();
    
    // Verify state
    TEST_ASSERT_TRUE(led_is_on());
}

void test_led_set_off(void) {
    uint32_t test_gpio_base = 0x40020C00;
    uint32_t test_pin_mask = 0x0000F000;
    
    // Initialize LED and turn it on first
    mock_gpio_expect_init(test_gpio_base);
    mock_gpio_expect_set_mode(test_gpio_base, test_pin_mask, GPIO_MODE_OUTPUT);
    led_init(test_gpio_base, test_pin_mask);
    
    mock_gpio_expect_set_pin(test_gpio_base, test_pin_mask);
    led_set_on();
    
    // Set expectation for LED off
    mock_gpio_expect_clear_pin(test_gpio_base, test_pin_mask);
    
    // Call function under test
    led_set_off();
    
    // Verify state
    TEST_ASSERT_FALSE(led_is_on());
}

void test_led_toggle(void) {
    uint32_t test_gpio_base = 0x40020C00;
    uint32_t test_pin_mask = 0x0000F000;
    
    // Initialize LED
    mock_gpio_expect_init(test_gpio_base);
    mock_gpio_expect_set_mode(test_gpio_base, test_pin_mask, GPIO_MODE_OUTPUT);
    led_init(test_gpio_base, test_pin_mask);
    
    // Test toggle from off to on
    mock_gpio_expect_set_pin(test_gpio_base, test_pin_mask);
    led_toggle();
    TEST_ASSERT_TRUE(led_is_on());
    
    // Test toggle from on to off
    mock_gpio_expect_clear_pin(test_gpio_base, test_pin_mask);
    led_toggle();
    TEST_ASSERT_FALSE(led_is_on());
}