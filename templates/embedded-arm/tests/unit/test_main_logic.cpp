/**
 * @file test_main_logic.cpp
 * @brief Unit tests for main application logic
 */

#include <gtest/gtest.h>
extern "C" {
    #include "mock_hal.h"
    #include "led.h"
}

class MainLogicTest : public ::testing::Test {
protected:
    void SetUp() override {
        // Reset mock state before each test
        mock_reset_system_state();
        mock_reset_gpio_state();
        mock_reset_system_tick();
        mock_reset_led_state();
    }

    void TearDown() override {
        // Clean up after each test
        mock_reset_system_state();
        mock_reset_gpio_state();
        mock_reset_system_tick();
        mock_reset_led_state();
    }
    
    // Helper function to simulate main initialization sequence
    void simulate_main_init() {
        system_init();
        gpio_init();
        led_init();
        
        // Turn on green LED briefly (like in main)
        led_set(LED_GREEN, LED_ON);
        led_set(LED_GREEN, LED_OFF);
    }
};

TEST_F(MainLogicTest, MainInitializationSequenceTest) {
    // Simulate the initialization sequence from main()
    simulate_main_init();
    
    // Verify all components are initialized
    EXPECT_TRUE(mock_is_system_initialized());
    EXPECT_TRUE(mock_is_gpio_initialized());
    
    // Green LED should be OFF after initialization sequence
    EXPECT_FALSE(mock_get_gpio_pin_state(LED_GREEN));
}

TEST_F(MainLogicTest, MainLoopBlinkPatternTest) {
    // Initialize system
    simulate_main_init();
    
    // Simulate main loop iterations
    uint32_t debug_counter = 0;
    const int iterations = 16;  // Simulate 16 loop iterations
    
    for (int i = 0; i < iterations; i++) {
        // Main loop logic
        led_toggle(LED_GREEN);  // Blink green LED every iteration
        debug_counter++;
        
        // Red LED blinks every 4th iteration
        if (debug_counter % 4 == 0) {
            led_toggle(LED_RED);
        }
        
        // Blue LED blinks every 8th iteration
        if (debug_counter % 8 == 0) {
            led_toggle(LED_BLUE);
        }
    }
    
    // Verify final states after 16 iterations
    EXPECT_EQ(16, mock_get_gpio_toggle_count(LED_GREEN));  // Every iteration
    EXPECT_EQ(4, mock_get_gpio_toggle_count(LED_RED));     // Every 4th iteration
    EXPECT_EQ(2, mock_get_gpio_toggle_count(LED_BLUE));    // Every 8th iteration
    
    // Final LED states (even number of toggles = OFF, odd = ON)
    EXPECT_FALSE(mock_get_gpio_pin_state(LED_GREEN));  // 16 toggles (even)
    EXPECT_FALSE(mock_get_gpio_pin_state(LED_RED));    // 4 toggles (even)
    EXPECT_FALSE(mock_get_gpio_pin_state(LED_BLUE));   // 2 toggles (even)
}

TEST_F(MainLogicTest, StartupIndicationTest) {
    // Test the startup indication sequence
    system_init();
    gpio_init();
    led_init();
    
    // Simulate startup indication (green LED on briefly)
    led_set(LED_GREEN, LED_ON);
    EXPECT_TRUE(mock_get_gpio_pin_state(LED_GREEN));
    
    // Simulate delay (in real code: delay_ms(100))
    mock_advance_system_tick(100);
    
    led_set(LED_GREEN, LED_OFF);
    EXPECT_FALSE(mock_get_gpio_pin_state(LED_GREEN));
    
    // This indicates successful system startup
}

TEST_F(MainLogicTest, DebugCounterLogicTest) {
    // Test debug counter logic
    simulate_main_init();
    
    uint32_t debug_counter = 0;
    
    // Test specific counter values
    for (int i = 1; i <= 12; i++) {
        debug_counter++;
        
        // Check red LED logic (every 4th)
        bool should_toggle_red = (debug_counter % 4 == 0);
        
        // Check blue LED logic (every 8th)
        bool should_toggle_blue = (debug_counter % 8 == 0);
        
        if (should_toggle_red) {
            led_toggle(LED_RED);
        }
        
        if (should_toggle_blue) {
            led_toggle(LED_BLUE);
        }
    }
    
    // After 12 iterations:
    // Red LED should have toggled at: 4, 8, 12 (3 times)
    // Blue LED should have toggled at: 8 (1 time)
    
    EXPECT_EQ(3, mock_get_gpio_toggle_count(LED_RED));
    EXPECT_EQ(1, mock_get_gpio_toggle_count(LED_BLUE));
    
    // Final states
    EXPECT_TRUE(mock_get_gpio_pin_state(LED_RED));   // 3 toggles (odd)
    EXPECT_TRUE(mock_get_gpio_pin_state(LED_BLUE));  // 1 toggle (odd)
}

TEST_F(MainLogicTest, SystemResourceUsageTest) {
    // Test that system resources are properly managed
    simulate_main_init();
    
    // Verify system clock is configured
    EXPECT_EQ(168000000, mock_get_system_clock());
    
    // Verify initial system tick
    uint32_t initial_tick = get_system_tick();
    
    // Simulate some system activity
    mock_advance_system_tick(1000);  // 1 second
    
    EXPECT_EQ(initial_tick + 1000, get_system_tick());
}