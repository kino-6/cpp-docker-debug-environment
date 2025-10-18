/**
 * @file test_gpio_abstraction.cpp
 * @brief Unit tests for GPIO abstraction layer
 */

#include <gtest/gtest.h>
extern "C" {
    #include "mock_hal.h"
}

class GPIOAbstractionTest : public ::testing::Test {
protected:
    void SetUp() override {
        // Reset mock state before each test
        mock_reset_gpio_state();
    }

    void TearDown() override {
        // Clean up after each test
        mock_reset_gpio_state();
    }
};

TEST_F(GPIOAbstractionTest, InitializationTest) {
    // Initially, GPIO should not be initialized
    EXPECT_FALSE(mock_is_gpio_initialized());
    
    // Initialize GPIO
    gpio_init();
    
    // After initialization, GPIO should be initialized
    EXPECT_TRUE(mock_is_gpio_initialized());
}

TEST_F(GPIOAbstractionTest, PinSetTest) {
    // Initialize GPIO first
    gpio_init();
    
    // Test setting pin HIGH
    gpio_set_pin(12, true);  // Green LED pin
    EXPECT_TRUE(mock_get_gpio_pin_state(12));
    
    // Test setting pin LOW
    gpio_set_pin(12, false);
    EXPECT_FALSE(mock_get_gpio_pin_state(12));
}

TEST_F(GPIOAbstractionTest, PinToggleTest) {
    // Initialize GPIO first
    gpio_init();
    
    // Initially, pin should be LOW
    EXPECT_FALSE(mock_get_gpio_pin_state(14));  // Red LED pin
    EXPECT_EQ(0, mock_get_gpio_toggle_count(14));
    
    // Toggle pin once
    gpio_toggle_pin(14);
    EXPECT_TRUE(mock_get_gpio_pin_state(14));
    EXPECT_EQ(1, mock_get_gpio_toggle_count(14));
    
    // Toggle pin again
    gpio_toggle_pin(14);
    EXPECT_FALSE(mock_get_gpio_pin_state(14));
    EXPECT_EQ(2, mock_get_gpio_toggle_count(14));
}

TEST_F(GPIOAbstractionTest, PinReadTest) {
    // Initialize GPIO first
    gpio_init();
    
    // Set pin and read it back
    gpio_set_pin(15, true);  // Blue LED pin
    EXPECT_TRUE(gpio_read_pin(15));
    
    gpio_set_pin(15, false);
    EXPECT_FALSE(gpio_read_pin(15));
}

TEST_F(GPIOAbstractionTest, MultiplePinsTest) {
    // Initialize GPIO first
    gpio_init();
    
    // Test multiple pins simultaneously
    gpio_set_pin(12, true);   // Green LED
    gpio_set_pin(13, false);  // Orange LED
    gpio_set_pin(14, true);   // Red LED
    gpio_set_pin(15, false);  // Blue LED
    
    EXPECT_TRUE(mock_get_gpio_pin_state(12));
    EXPECT_FALSE(mock_get_gpio_pin_state(13));
    EXPECT_TRUE(mock_get_gpio_pin_state(14));
    EXPECT_FALSE(mock_get_gpio_pin_state(15));
}

TEST_F(GPIOAbstractionTest, ToggleCountAccuracyTest) {
    // Initialize GPIO first
    gpio_init();
    
    const uint32_t pin = 12;
    const int toggle_count = 10;
    
    // Toggle pin multiple times
    for (int i = 0; i < toggle_count; i++) {
        gpio_toggle_pin(pin);
    }
    
    // Verify toggle count
    EXPECT_EQ(toggle_count, mock_get_gpio_toggle_count(pin));
    
    // Final state should be HIGH (odd number of toggles)
    EXPECT_TRUE(mock_get_gpio_pin_state(pin));
}