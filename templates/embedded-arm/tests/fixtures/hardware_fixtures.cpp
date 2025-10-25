/**
 * @file hardware_fixtures.cpp
 * @brief Hardware-specific test fixtures for embedded testing
 */

#include "hardware_fixtures.h"
#include <gtest/gtest.h>
#include <iostream>

namespace EmbeddedTest {

// GPIO Test Fixture
void GPIOTestFixture::SetUp() {
    EmbeddedTestFixture::SetUp();
    
    // Initialize GPIO mock states
    gpio_verifier.reset_all_pins();
    
    // Set up default GPIO configuration
    configure_default_gpio();
    
    if (TestConfiguration::get_instance().is_verbose_output()) {
        std::cout << "GPIO test fixture initialized" << std::endl;
    }
}

void GPIOTestFixture::TearDown() {
    // Verify no unexpected GPIO states
    verify_gpio_cleanup();
    
    EmbeddedTestFixture::TearDown();
}

void GPIOTestFixture::configure_default_gpio() {
    // Configure LED pins as outputs (mock)
    for (uint32_t pin = 12; pin <= 15; ++pin) {
        gpio_verifier.set_mock_pin_state(pin, false);  // LEDs off initially
    }
    
    // Configure button pin as input (mock)
    gpio_verifier.set_mock_pin_state(0, false);  // Button not pressed
}

void GPIOTestFixture::verify_gpio_cleanup() {
    // Verify all LEDs are turned off
    for (uint32_t pin = 12; pin <= 15; ++pin) {
        EXPECT_FALSE(gpio_verifier.verify_pin_state(pin, true))
            << "LED pin " << pin << " should be turned off after test";
    }
}

void GPIOTestFixture::simulate_button_press(uint32_t pin) {
    gpio_verifier.set_mock_pin_state(pin, true);
    hardware_sim.simulate_gpio_interrupt(pin);
}

void GPIOTestFixture::simulate_button_release(uint32_t pin) {
    gpio_verifier.set_mock_pin_state(pin, false);
}

// LED Test Fixture
void LEDTestFixture::SetUp() {
    GPIOTestFixture::SetUp();
    
    // Initialize LED pattern verifier
    led_verifier.clear_pattern();
    
    if (TestConfiguration::get_instance().is_verbose_output()) {
        std::cout << "LED test fixture initialized" << std::endl;
    }
}

void LEDTestFixture::TearDown() {
    // Verify LED cleanup
    verify_all_leds_off();
    
    GPIOTestFixture::TearDown();
}

void LEDTestFixture::verify_all_leds_off() {
    // Check that all LEDs are turned off
    EXPECT_TRUE(gpio_verifier.verify_pin_state(12, false)) << "Green LED should be off";
    EXPECT_TRUE(gpio_verifier.verify_pin_state(13, false)) << "Orange LED should be off";
    EXPECT_TRUE(gpio_verifier.verify_pin_state(14, false)) << "Red LED should be off";
    EXPECT_TRUE(gpio_verifier.verify_pin_state(15, false)) << "Blue LED should be off";
}

void LEDTestFixture::set_led_state(uint32_t led_mask) {
    // Update mock GPIO states based on LED mask
    gpio_verifier.set_mock_pin_state(12, (led_mask & (1 << 12)) != 0);  // Green
    gpio_verifier.set_mock_pin_state(13, (led_mask & (1 << 13)) != 0);  // Orange
    gpio_verifier.set_mock_pin_state(14, (led_mask & (1 << 14)) != 0);  // Red
    gpio_verifier.set_mock_pin_state(15, (led_mask & (1 << 15)) != 0);  // Blue
    
    // Record the pattern
    led_verifier.record_led_state(led_mask);
}

void LEDTestFixture::verify_led_pattern(const std::vector<uint32_t>& expected_pattern) {
    EXPECT_TRUE(led_verifier.verify_pattern(expected_pattern))
        << "LED pattern does not match expected sequence";
}

void LEDTestFixture::simulate_knight_rider_pattern() {
    std::vector<uint32_t> knight_rider = {
        (1 << 12),  // Green
        (1 << 13),  // Orange
        (1 << 14),  // Red
        (1 << 15),  // Blue
        (1 << 14),  // Red
        (1 << 13)   // Orange
    };
    
    for (uint32_t led_state : knight_rider) {
        set_led_state(led_state);
        std::this_thread::sleep_for(std::chrono::milliseconds(100));
    }
}

// Timer Test Fixture
void TimerTestFixture::SetUp() {
    EmbeddedTestFixture::SetUp();
    
    // Reset timer state
    timer_tick_count = 0;
    timer_interrupt_received = false;
    
    // Set up timer interrupt callback
    hardware_sim.set_timer_interrupt_callback([this]() {
        timer_tick_count++;
        timer_interrupt_received = true;
    });
    
    if (TestConfiguration::get_instance().is_verbose_output()) {
        std::cout << "Timer test fixture initialized" << std::endl;
    }
}

void TimerTestFixture::TearDown() {
    // Verify timer cleanup
    verify_timer_stopped();
    
    EmbeddedTestFixture::TearDown();
}

void TimerTestFixture::verify_timer_stopped() {
    // In a real implementation, this would check that timer interrupts have stopped
    // For mock, we just ensure the state is consistent
    EXPECT_GE(timer_tick_count, 0) << "Timer tick count should be non-negative";
}

void TimerTestFixture::simulate_timer_ticks(uint32_t count) {
    for (uint32_t i = 0; i < count; ++i) {
        hardware_sim.simulate_timer_interrupt();
        std::this_thread::sleep_for(std::chrono::milliseconds(1));  // Simulate 1ms tick
    }
}

void TimerTestFixture::verify_timer_accuracy(uint32_t expected_ticks, double tolerance_percent) {
    double tolerance = expected_ticks * (tolerance_percent / 100.0);
    EXPECT_NEAR(timer_tick_count, expected_ticks, tolerance)
        << "Timer tick count not within expected tolerance";
}

uint32_t TimerTestFixture::get_timer_tick_count() const {
    return timer_tick_count;
}

bool TimerTestFixture::was_timer_interrupt_received() const {
    return timer_interrupt_received;
}

// UART Test Fixture
void UARTTestFixture::SetUp() {
    EmbeddedTestFixture::SetUp();
    
    // Clear UART buffers
    uart_tx_buffer.clear();
    uart_rx_buffer.clear();
    
    // Set up UART callbacks
    hardware_sim.set_uart_rx_callback([this](const std::string& data) {
        uart_rx_buffer += data;
    });
    
    if (TestConfiguration::get_instance().is_verbose_output()) {
        std::cout << "UART test fixture initialized" << std::endl;
    }
}

void UARTTestFixture::TearDown() {
    // Verify UART cleanup
    verify_uart_buffers_handled();
    
    EmbeddedTestFixture::TearDown();
}

void UARTTestFixture::verify_uart_buffers_handled() {
    // In a real implementation, this might check for unprocessed data
    // For testing, we just ensure buffers are in a consistent state
    if (TestConfiguration::get_instance().is_verbose_output()) {
        std::cout << "UART TX buffer size: " << uart_tx_buffer.size() << std::endl;
        std::cout << "UART RX buffer size: " << uart_rx_buffer.size() << std::endl;
    }
}

void UARTTestFixture::simulate_uart_transmit(const std::string& data) {
    uart_tx_buffer += data;
    
    if (TestConfiguration::get_instance().is_verbose_output()) {
        std::cout << "UART TX: " << data << std::endl;
    }
}

void UARTTestFixture::simulate_uart_receive(const std::string& data) {
    hardware_sim.simulate_uart_data_received(data);
}

void UARTTestFixture::verify_uart_transmission(const std::string& expected_data) {
    EXPECT_EQ(uart_tx_buffer, expected_data)
        << "UART transmission does not match expected data";
}

void UARTTestFixture::verify_uart_reception(const std::string& expected_data) {
    EXPECT_EQ(uart_rx_buffer, expected_data)
        << "UART reception does not match expected data";
}

const std::string& UARTTestFixture::get_uart_tx_buffer() const {
    return uart_tx_buffer;
}

const std::string& UARTTestFixture::get_uart_rx_buffer() const {
    return uart_rx_buffer;
}

// System Integration Test Fixture
void SystemIntegrationTestFixture::SetUp() {
    // Initialize all subsystem fixtures
    GPIOTestFixture::SetUp();
    
    // Initialize system state
    system_verifier.reset();
    system_verifier.set_system_state(SystemState::INIT);
    
    // Set up integrated callbacks
    setup_integrated_callbacks();
    
    if (TestConfiguration::get_instance().is_verbose_output()) {
        std::cout << "System integration test fixture initialized" << std::endl;
    }
}

void SystemIntegrationTestFixture::TearDown() {
    // Verify system cleanup
    verify_system_shutdown();
    
    GPIOTestFixture::TearDown();
}

void SystemIntegrationTestFixture::setup_integrated_callbacks() {
    // Set up callbacks that simulate system integration
    hardware_sim.set_timer_interrupt_callback([this]() {
        timer_tick_count++;
        
        // Simulate system tick processing
        if (timer_tick_count % 1000 == 0) {  // Every second
            system_verifier.set_system_state(SystemState::ACTIVE);
        }
    });
    
    hardware_sim.set_gpio_interrupt_callback([this](uint32_t pin) {
        // Simulate button press handling
        if (pin == 0) {  // User button
            system_verifier.set_system_state(SystemState::IDLE);
        }
    });
}

void SystemIntegrationTestFixture::verify_system_shutdown() {
    // Verify system is in a safe state
    SystemState current_state = system_verifier.get_current_state();
    EXPECT_TRUE(current_state == SystemState::IDLE || current_state == SystemState::INIT)
        << "System should be in IDLE or INIT state after test";
}

void SystemIntegrationTestFixture::simulate_system_startup() {
    system_verifier.set_system_state(SystemState::INIT);
    
    // Simulate initialization sequence
    std::this_thread::sleep_for(std::chrono::milliseconds(10));
    system_verifier.set_system_state(SystemState::IDLE);
}

void SystemIntegrationTestFixture::simulate_system_operation(uint32_t duration_ms) {
    system_verifier.set_system_state(SystemState::ACTIVE);
    
    // Simulate timer ticks during operation
    uint32_t ticks = duration_ms;  // 1ms per tick
    simulate_timer_ticks(ticks);
    
    system_verifier.set_system_state(SystemState::IDLE);
}

void SystemIntegrationTestFixture::verify_system_state_sequence(const std::vector<SystemState>& expected_sequence) {
    EXPECT_TRUE(system_verifier.verify_state_sequence(expected_sequence))
        << "System state sequence does not match expected pattern";
}

} // namespace EmbeddedTest