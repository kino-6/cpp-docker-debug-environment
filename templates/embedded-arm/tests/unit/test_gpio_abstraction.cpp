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
    gpio_set_pin(0x40020C00, 12);  // Green LED pin with GPIO base
    EXPECT_TRUE(mock_get_gpio_pin_state(12));
    
    // Test setting pin LOW
    gpio_clear_pin(0x40020C00, 12);
    EXPECT_FALSE(mock_get_gpio_pin_state(12));
}

TEST_F(GPIOAbstractionTest, PinToggleTest) {
    // Initialize GPIO first
    gpio_init();
    
    // Initially, pin should be LOW
    EXPECT_FALSE(mock_get_gpio_pin_state(14));  // Red LED pin
    EXPECT_EQ(0, mock_get_gpio_toggle_count(14));
    
    // Toggle pin once
    gpio_toggle_pin(0x40020C00, 14);
    EXPECT_TRUE(mock_get_gpio_pin_state(14));
    EXPECT_EQ(1, mock_get_gpio_toggle_count(14));
    
    // Toggle pin again
    gpio_toggle_pin(0x40020C00, 14);
    EXPECT_FALSE(mock_get_gpio_pin_state(14));
    EXPECT_EQ(2, mock_get_gpio_toggle_count(14));
}

TEST_F(GPIOAbstractionTest, PinReadTest) {
    // Initialize GPIO first
    gpio_init();
    
    // Set pin and read it back
    gpio_set_pin(0x40020C00, 15);  // Blue LED pin
    EXPECT_EQ(1, gpio_read_pin(0x40020C00, 15));
    
    gpio_clear_pin(0x40020C00, 15);
    EXPECT_EQ(0, gpio_read_pin(0x40020C00, 15));
}

TEST_F(GPIOAbstractionTest, MultiplePinsTest) {
    // Initialize GPIO first
    gpio_init();
    
    // Test multiple pins simultaneously
    gpio_set_pin(0x40020C00, 12);   // Green LED
    gpio_clear_pin(0x40020C00, 13);  // Orange LED
    gpio_set_pin(0x40020C00, 14);   // Red LED
    gpio_clear_pin(0x40020C00, 15);  // Blue LED
    
    EXPECT_TRUE(mock_get_gpio_pin_state(12));
    EXPECT_FALSE(mock_get_gpio_pin_state(13));
    EXPECT_TRUE(mock_get_gpio_pin_state(14));
    EXPECT_FALSE(mock_get_gpio_pin_state(15));
}

TEST_F(GPIOAbstractionTest, ToggleCountAccuracyTest) {
    // Initialize GPIO first
    gpio_init();
    
    const uint32_t gpio_base = 0x40020C00;
    const uint8_t pin = 12;
    const int toggle_count = 10;
    
    // Toggle pin multiple times
    for (int i = 0; i < toggle_count; i++) {
        gpio_toggle_pin(gpio_base, pin);
    }
    
    // Verify toggle count
    EXPECT_EQ(toggle_count, mock_get_gpio_toggle_count(pin));
    
    // Final state should be HIGH (odd number of toggles)
    EXPECT_TRUE(mock_get_gpio_pin_state(pin));
}