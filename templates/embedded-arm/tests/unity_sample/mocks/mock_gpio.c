#include "mock_gpio.h"
#include "unity.h"
#include <string.h>

// Mock expectation structure
typedef struct {
    bool expected;
    uint32_t gpio_base;
    uint32_t pin_mask;
    uint32_t mode;
} mock_expectation_t;

// Mock state
typedef struct {
    mock_expectation_t init_expectation;
    mock_expectation_t set_mode_expectation;
    mock_expectation_t set_pin_expectation;
    mock_expectation_t clear_pin_expectation;
    
    bool init_called;
    bool set_mode_called;
    bool set_pin_called;
    bool clear_pin_called;
} mock_gpio_state_t;

static mock_gpio_state_t mock_state = {0};

// Mock GPIO functions
void mock_gpio_init(uint32_t gpio_base) {
    mock_state.init_called = true;
    
    if (mock_state.init_expectation.expected) {
        TEST_ASSERT_EQUAL_UINT32_MESSAGE(
            mock_state.init_expectation.gpio_base, 
            gpio_base,
            "GPIO init called with unexpected base address"
        );
    }
}

void mock_gpio_set_mode(uint32_t gpio_base, uint32_t pin_mask, uint32_t mode) {
    mock_state.set_mode_called = true;
    
    if (mock_state.set_mode_expectation.expected) {
        TEST_ASSERT_EQUAL_UINT32_MESSAGE(
            mock_state.set_mode_expectation.gpio_base,
            gpio_base,
            "GPIO set_mode called with unexpected base address"
        );
        TEST_ASSERT_EQUAL_UINT32_MESSAGE(
            mock_state.set_mode_expectation.pin_mask,
            pin_mask,
            "GPIO set_mode called with unexpected pin mask"
        );
        TEST_ASSERT_EQUAL_UINT32_MESSAGE(
            mock_state.set_mode_expectation.mode,
            mode,
            "GPIO set_mode called with unexpected mode"
        );
    }
}

void mock_gpio_set_pin(uint32_t gpio_base, uint32_t pin_mask) {
    mock_state.set_pin_called = true;
    
    if (mock_state.set_pin_expectation.expected) {
        TEST_ASSERT_EQUAL_UINT32_MESSAGE(
            mock_state.set_pin_expectation.gpio_base,
            gpio_base,
            "GPIO set_pin called with unexpected base address"
        );
        TEST_ASSERT_EQUAL_UINT32_MESSAGE(
            mock_state.set_pin_expectation.pin_mask,
            pin_mask,
            "GPIO set_pin called with unexpected pin mask"
        );
    }
}

void mock_gpio_clear_pin(uint32_t gpio_base, uint32_t pin_mask) {
    mock_state.clear_pin_called = true;
    
    if (mock_state.clear_pin_expectation.expected) {
        TEST_ASSERT_EQUAL_UINT32_MESSAGE(
            mock_state.clear_pin_expectation.gpio_base,
            gpio_base,
            "GPIO clear_pin called with unexpected base address"
        );
        TEST_ASSERT_EQUAL_UINT32_MESSAGE(
            mock_state.clear_pin_expectation.pin_mask,
            pin_mask,
            "GPIO clear_pin called with unexpected pin mask"
        );
    }
}

uint32_t mock_gpio_read_pin(uint32_t gpio_base, uint32_t pin_mask) {
    // Simple mock implementation - returns 0 for now
    (void)gpio_base;
    (void)pin_mask;
    return 0;
}

// Mock expectation functions
void mock_gpio_expect_init(uint32_t expected_gpio_base) {
    mock_state.init_expectation.expected = true;
    mock_state.init_expectation.gpio_base = expected_gpio_base;
}

void mock_gpio_expect_set_mode(uint32_t expected_gpio_base, uint32_t expected_pin_mask, uint32_t expected_mode) {
    mock_state.set_mode_expectation.expected = true;
    mock_state.set_mode_expectation.gpio_base = expected_gpio_base;
    mock_state.set_mode_expectation.pin_mask = expected_pin_mask;
    mock_state.set_mode_expectation.mode = expected_mode;
}

void mock_gpio_expect_set_pin(uint32_t expected_gpio_base, uint32_t expected_pin_mask) {
    mock_state.set_pin_expectation.expected = true;
    mock_state.set_pin_expectation.gpio_base = expected_gpio_base;
    mock_state.set_pin_expectation.pin_mask = expected_pin_mask;
}

void mock_gpio_expect_clear_pin(uint32_t expected_gpio_base, uint32_t expected_pin_mask) {
    mock_state.clear_pin_expectation.expected = true;
    mock_state.clear_pin_expectation.gpio_base = expected_gpio_base;
    mock_state.clear_pin_expectation.pin_mask = expected_pin_mask;
}

// Mock control functions
void mock_gpio_reset(void) {
    memset(&mock_state, 0, sizeof(mock_state));
}

void mock_gpio_verify(void) {
    // Verify that expected calls were made
    if (mock_state.init_expectation.expected) {
        TEST_ASSERT_TRUE_MESSAGE(mock_state.init_called, "Expected GPIO init was not called");
    }
    
    if (mock_state.set_mode_expectation.expected) {
        TEST_ASSERT_TRUE_MESSAGE(mock_state.set_mode_called, "Expected GPIO set_mode was not called");
    }
    
    if (mock_state.set_pin_expectation.expected) {
        TEST_ASSERT_TRUE_MESSAGE(mock_state.set_pin_called, "Expected GPIO set_pin was not called");
    }
    
    if (mock_state.clear_pin_expectation.expected) {
        TEST_ASSERT_TRUE_MESSAGE(mock_state.clear_pin_called, "Expected GPIO clear_pin was not called");
    }
}