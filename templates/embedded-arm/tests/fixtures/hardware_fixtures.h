/**
 * @file hardware_fixtures.h
 * @brief Hardware-specific test fixtures for embedded testing
 */

#ifndef HARDWARE_FIXTURES_H
#define HARDWARE_FIXTURES_H

#include "../utils/embedded_test_framework.h"
#include <thread>
#include <chrono>

namespace EmbeddedTest {

/**
 * @brief GPIO-specific test fixture
 */
class GPIOTestFixture : public EmbeddedTestFixture {
protected:
    GPIOStateVerifier gpio_verifier;
    
    void SetUp() override;
    void TearDown() override;
    
    void configure_default_gpio();
    void verify_gpio_cleanup();
    
public:
    void simulate_button_press(uint32_t pin);
    void simulate_button_release(uint32_t pin);
};

/**
 * @brief LED-specific test fixture
 */
class LEDTestFixture : public GPIOTestFixture {
protected:
    LEDPatternVerifier led_verifier;
    
    void SetUp() override;
    void TearDown() override;
    
    void verify_all_leds_off();
    
public:
    void set_led_state(uint32_t led_mask);
    void verify_led_pattern(const std::vector<uint32_t>& expected_pattern);
    void simulate_knight_rider_pattern();
};

/**
 * @brief Timer-specific test fixture
 */
class TimerTestFixture : public EmbeddedTestFixture {
protected:
    uint32_t timer_tick_count = 0;
    bool timer_interrupt_received = false;
    
    void SetUp() override;
    void TearDown() override;
    
    void verify_timer_stopped();
    
public:
    void simulate_timer_ticks(uint32_t count);
    void verify_timer_accuracy(uint32_t expected_ticks, double tolerance_percent = 5.0);
    uint32_t get_timer_tick_count() const;
    bool was_timer_interrupt_received() const;
};

/**
 * @brief UART-specific test fixture
 */
class UARTTestFixture : public EmbeddedTestFixture {
protected:
    std::string uart_tx_buffer;
    std::string uart_rx_buffer;
    
    void SetUp() override;
    void TearDown() override;
    
    void verify_uart_buffers_handled();
    
public:
    void simulate_uart_transmit(const std::string& data);
    void simulate_uart_receive(const std::string& data);
    void verify_uart_transmission(const std::string& expected_data);
    void verify_uart_reception(const std::string& expected_data);
    
    const std::string& get_uart_tx_buffer() const;
    const std::string& get_uart_rx_buffer() const;
};

/**
 * @brief System integration test fixture
 */
class SystemIntegrationTestFixture : public GPIOTestFixture {
protected:
    SystemStateVerifier system_verifier;
    uint32_t timer_tick_count = 0;
    
    void SetUp() override;
    void TearDown() override;
    
    void setup_integrated_callbacks();
    void verify_system_shutdown();
    
public:
    void simulate_system_startup();
    void simulate_system_operation(uint32_t duration_ms);
    void verify_system_state_sequence(const std::vector<SystemState>& expected_sequence);
    
    // Inherit timer simulation from TimerTestFixture functionality
    void simulate_timer_ticks(uint32_t count) {
        for (uint32_t i = 0; i < count; ++i) {
            hardware_sim.simulate_timer_interrupt();
            std::this_thread::sleep_for(std::chrono::milliseconds(1));
        }
    }
};

} // namespace EmbeddedTest

#endif // HARDWARE_FIXTURES_H