/**
 * @file test_system_logic.cpp
 * @brief Unit tests for system initialization logic
 */

#include <gtest/gtest.h>
extern "C" {
    #include "mock_hal.h"
}

class SystemLogicTest : public ::testing::Test {
protected:
    void SetUp() override {
        // Reset mock state before each test
        mock_reset_system_state();
        mock_reset_gpio_state();
        mock_reset_system_tick();
    }

    void TearDown() override {
        // Clean up after each test
        mock_reset_system_state();
        mock_reset_gpio_state();
        mock_reset_system_tick();
    }
};

TEST_F(SystemLogicTest, SystemInitializationTest) {
    // Initially, system should not be initialized
    EXPECT_FALSE(mock_is_system_initialized());
    EXPECT_EQ(0, mock_get_system_clock());
    
    // Initialize system
    system_init();
    
    // After initialization, system should be initialized
    EXPECT_TRUE(mock_is_system_initialized());
    EXPECT_EQ(168000000, mock_get_system_clock());  // 168MHz
}

TEST_F(SystemLogicTest, SystemTickTest) {
    // Initially, system tick should be 0
    EXPECT_EQ(0, get_system_tick());
    
    // Advance system tick
    mock_advance_system_tick(100);
    EXPECT_EQ(100, get_system_tick());
    
    // Advance more
    mock_advance_system_tick(50);
    EXPECT_EQ(150, get_system_tick());
}

TEST_F(SystemLogicTest, DelayFunctionTest) {
    // Test delay function (mock version doesn't actually delay)
    uint32_t start_tick = get_system_tick();
    
    delay_ms(500);  // Mock delay
    
    // In mock implementation, tick doesn't advance automatically
    EXPECT_EQ(start_tick, get_system_tick());
    
    // But we can simulate tick advancement
    mock_advance_system_tick(500);
    EXPECT_EQ(start_tick + 500, get_system_tick());
}

TEST_F(SystemLogicTest, InitializationSequenceTest) {
    // Test proper initialization sequence
    
    // Step 1: System initialization
    system_init();
    EXPECT_TRUE(mock_is_system_initialized());
    
    // Step 2: GPIO initialization
    gpio_init();
    EXPECT_TRUE(mock_is_gpio_initialized());
    
    // Both should be initialized now
    EXPECT_TRUE(mock_is_system_initialized());
    EXPECT_TRUE(mock_is_gpio_initialized());
}

TEST_F(SystemLogicTest, SystemClockConfigurationTest) {
    // Test system clock configuration
    system_init();
    
    uint32_t clock_freq = mock_get_system_clock();
    EXPECT_EQ(168000000, clock_freq);  // Expected 168MHz
    
    // Verify clock is within reasonable range for STM32F4
    EXPECT_GE(clock_freq, 1000000);    // At least 1MHz
    EXPECT_LE(clock_freq, 200000000);  // At most 200MHz
}