/**
 * @file test_led_logic.cpp
 * @brief Unit tests for LED control logic
 */

#include <gtest/gtest.h>
extern "C" {
    #include "mock_hal.h"
    #include "led.h"
}

class LEDLogicTest : public ::testing::Test {
protected:
    void SetUp() override {
        // Reset mock state before each test
        mock_reset_gpio_state();
        mock_reset_system_state();
        mock_reset_led_state();
    }

    void TearDown() override {
        // Clean up after each test
        mock_reset_gpio_state();
        mock_reset_system_state();
        mock_reset_led_state();
    }
};

TEST_F(LEDLogicTest, LEDInitializationTest) {
    // Initialize system and GPIO first
    system_init();
    gpio_init();
    
    // Initialize LED driver
    led_init();
    
    // Verify that GPIO was initialized
    EXPECT_TRUE(mock_is_gpio_initialized());
    
    // All LEDs should be OFF initially
    EXPECT_FALSE(mock_get_gpio_pin_state(LED_GREEN));
    EXPECT_FALSE(mock_get_gpio_pin_state(LED_ORANGE));
    EXPECT_FALSE(mock_get_gpio_pin_state(LED_RED));
    EXPECT_FALSE(mock_get_gpio_pin_state(LED_BLUE));
}

TEST_F(LEDLogicTest, LEDSetOnTest) {
    // Initialize system
    system_init();
    gpio_init();
    led_init();
    
    // Turn on each LED
    led_set(LED_GREEN, LED_ON);
    EXPECT_TRUE(mock_get_gpio_pin_state(LED_GREEN));
    
    led_set(LED_RED, LED_ON);
    EXPECT_TRUE(mock_get_gpio_pin_state(LED_RED));
    
    led_set(LED_BLUE, LED_ON);
    EXPECT_TRUE(mock_get_gpio_pin_state(LED_BLUE));
}

TEST_F(LEDLogicTest, LEDSetOffTest) {
    // Initialize system
    system_init();
    gpio_init();
    led_init();
    
    // Turn on LED first
    led_set(LED_GREEN, LED_ON);
    EXPECT_TRUE(mock_get_gpio_pin_state(LED_GREEN));
    
    // Turn off LED
    led_set(LED_GREEN, LED_OFF);
    EXPECT_FALSE(mock_get_gpio_pin_state(LED_GREEN));
}

TEST_F(LEDLogicTest, LEDToggleTest) {
    // Initialize system
    system_init();
    gpio_init();
    led_init();
    
    // Initially LED should be OFF
    EXPECT_FALSE(mock_get_gpio_pin_state(LED_RED));
    EXPECT_EQ(0, mock_get_gpio_toggle_count(LED_RED));
    
    // Toggle LED
    led_toggle(LED_RED);
    EXPECT_TRUE(mock_get_gpio_pin_state(LED_RED));
    EXPECT_EQ(1, mock_get_gpio_toggle_count(LED_RED));
    
    // Toggle again
    led_toggle(LED_RED);
    EXPECT_FALSE(mock_get_gpio_pin_state(LED_RED));
    EXPECT_EQ(2, mock_get_gpio_toggle_count(LED_RED));
}

TEST_F(LEDLogicTest, MultipleLEDControlTest) {
    // Initialize system
    system_init();
    gpio_init();
    led_init();
    
    // Control multiple LEDs
    led_set(LED_GREEN, LED_ON);
    led_set(LED_RED, LED_OFF);
    led_toggle(LED_BLUE);  // Should turn ON from initial OFF state
    
    EXPECT_TRUE(mock_get_gpio_pin_state(LED_GREEN));
    EXPECT_FALSE(mock_get_gpio_pin_state(LED_RED));
    EXPECT_TRUE(mock_get_gpio_pin_state(LED_BLUE));
}

TEST_F(LEDLogicTest, LEDBlinkPatternTest) {
    // Initialize system
    system_init();
    gpio_init();
    led_init();
    
    // Simulate blink pattern (like in main loop)
    const int blink_cycles = 8;
    
    for (int cycle = 1; cycle <= blink_cycles; cycle++) {
        // Green LED blinks every cycle
        led_toggle(LED_GREEN);
        
        // Red LED blinks every 4th cycle
        if (cycle % 4 == 0) {
            led_toggle(LED_RED);
        }
        
        // Blue LED blinks every 8th cycle
        if (cycle % 8 == 0) {
            led_toggle(LED_BLUE);
        }
    }
    
    // After 8 cycles:
    // Green LED: 8 toggles (should be OFF if started from OFF)
    // Red LED: 2 toggles (should be OFF if started from OFF)
    // Blue LED: 1 toggle (should be ON if started from OFF)
    
    EXPECT_EQ(8, mock_get_gpio_toggle_count(LED_GREEN));
    EXPECT_EQ(2, mock_get_gpio_toggle_count(LED_RED));
    EXPECT_EQ(1, mock_get_gpio_toggle_count(LED_BLUE));
    
    EXPECT_FALSE(mock_get_gpio_pin_state(LED_GREEN));  // Even number of toggles
    EXPECT_FALSE(mock_get_gpio_pin_state(LED_RED));    // Even number of toggles
    EXPECT_TRUE(mock_get_gpio_pin_state(LED_BLUE));    // Odd number of toggles
}