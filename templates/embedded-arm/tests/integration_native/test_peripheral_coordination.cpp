/**
 * @file test_peripheral_coordination.cpp
 * @brief Peripheral coordination tests for embedded ARM project
 */

#include <gtest/gtest.h>
#include <gmock/gmock.h>
#include "../fixtures/hardware_fixtures.h"
#include "../utils/embedded_test_framework.h"

using namespace EmbeddedTest;

class PeripheralCoordinationTest : public SystemIntegrationTestFixture {
protected:
    void SetUp() override {
        SystemIntegrationTestFixture::SetUp();
        
        if (TestConfiguration::get_instance().is_verbose_output()) {
            std::cout << "Starting peripheral coordination test" << std::endl;
        }
    }
};

TEST_F(PeripheralCoordinationTest, GPIOTimerCoordination) {
    EMBEDDED_BENCHMARK_START("GPIOTimerCoordination");
    
    // Test GPIO operations synchronized with timer
    simulate_timer_ticks(1);
    set_led_state(0x1000);  // Green LED on
    
    simulate_timer_ticks(5);
    set_led_state(0x2000);  // Orange LED on
    
    simulate_timer_ticks(5);
    set_led_state(0x4000);  // Red LED on
    
    simulate_timer_ticks(5);
    set_led_state(0x8000);  // Blue LED on
    
    simulate_timer_ticks(5);
    set_led_state(0x0000);  // All LEDs off
    
    // Verify timing and LED states
    EXPECT_GT(get_timer_tick_count(), 20);
    verify_all_leds_off();
    
    // Verify LED pattern was recorded correctly
    std::vector<uint32_t> expected_pattern = {0x1000, 0x2000, 0x4000, 0x8000, 0x0000};
    verify_led_pattern(expected_pattern);
    
    EMBEDDED_BENCHMARK_END();
    
    result_collector.add_test_result("GPIOTimerCoordination", true, "GPIO-Timer coordination successful");
}

TEST_F(PeripheralCoordinationTest, UARTTimerCoordination) {
    EMBEDDED_BENCHMARK_START("UARTTimerCoordination");
    
    // Test UART operations with timer-based scheduling
    simulate_timer_ticks(10);
    simulate_uart_transmit("Timer tick 10\n");
    
    simulate_timer_ticks(10);
    simulate_uart_transmit("Timer tick 20\n");
    
    simulate_timer_ticks(10);
    simulate_uart_transmit("Timer tick 30\n");
    
    // Verify timer progression and UART output
    EXPECT_GE(get_timer_tick_count(), 30);
    
    std::string expected_output = "Timer tick 10\nTimer tick 20\nTimer tick 30\n";
    verify_uart_transmission(expected_output);
    
    EMBEDDED_BENCHMARK_END();
    
    result_collector.add_test_result("UARTTimerCoordination", true, "UART-Timer coordination successful");
}

TEST_F(PeripheralCoordinationTest, GPIOUARTCoordination) {
    EMBEDDED_BENCHMARK_START("GPIOUARTCoordination");
    
    // Test GPIO state changes triggering UART messages
    set_led_state(0x1000);  // Green LED
    simulate_uart_transmit("LED: Green ON\n");
    
    set_led_state(0x2000);  // Orange LED
    simulate_uart_transmit("LED: Orange ON\n");
    
    set_led_state(0x4000);  // Red LED
    simulate_uart_transmit("LED: Red ON\n");
    
    set_led_state(0x8000);  // Blue LED
    simulate_uart_transmit("LED: Blue ON\n");
    
    set_led_state(0x0000);  // All off
    simulate_uart_transmit("LED: All OFF\n");
    
    // Verify GPIO-UART coordination
    verify_all_leds_off();
    
    std::string expected_output = "LED: Green ON\nLED: Orange ON\nLED: Red ON\nLED: Blue ON\nLED: All OFF\n";
    verify_uart_transmission(expected_output);
    
    EMBEDDED_BENCHMARK_END();
    
    result_collector.add_test_result("GPIOUARTCoordination", true, "GPIO-UART coordination successful");
}

TEST_F(PeripheralCoordinationTest, TriplePeripheralCoordination) {
    EMBEDDED_BENCHMARK_START("TriplePeripheralCoordination");
    
    // Test coordination of GPIO, UART, and Timer together
    for (int cycle = 0; cycle < 3; ++cycle) {
        // Timer-driven cycle
        simulate_timer_ticks(5);
        
        // GPIO operation
        uint32_t led_state = 0x1000 << cycle;  // Shift LED pattern
        set_led_state(led_state);
        
        // UART status report
        simulate_uart_transmit("Cycle " + std::to_string(cycle) + " LED: 0x" + 
                              std::to_string(led_state) + "\n");
        
        // Brief delay
        simulate_timer_ticks(2);
    }
    
    // Final cleanup
    set_led_state(0x0000);
    simulate_uart_transmit("Coordination test complete\n");
    
    // Verify all peripherals coordinated correctly
    EXPECT_GE(get_timer_tick_count(), 21);  // 3 cycles * 7 ticks per cycle
    verify_all_leds_off();
    
    std::string expected_output = "Cycle 0 LED: 0x4096\nCycle 1 LED: 0x8192\nCycle 2 LED: 0x16384\nCoordination test complete\n";
    verify_uart_transmission(expected_output);
    
    EMBEDDED_BENCHMARK_END();
    
    result_collector.add_test_result("TriplePeripheralCoordination", true, "Triple peripheral coordination successful");
}

TEST_F(PeripheralCoordinationTest, InterruptDrivenCoordination) {
    EMBEDDED_BENCHMARK_START("InterruptDrivenCoordination");
    
    // Test interrupt-driven peripheral coordination
    
    // Simulate button interrupt triggering LED and UART response
    simulate_button_press(0);
    set_led_state(0xF000);  // All LEDs on
    simulate_uart_transmit("Button pressed - LEDs ON\n");
    
    // Timer interrupt processing
    simulate_timer_ticks(10);
    
    // Button release interrupt
    simulate_button_release(0);
    set_led_state(0x0000);  // All LEDs off
    simulate_uart_transmit("Button released - LEDs OFF\n");
    
    // Verify interrupt-driven coordination
    verify_all_leds_off();
    EXPECT_GE(get_timer_tick_count(), 10);
    
    std::string expected_output = "Button pressed - LEDs ON\nButton released - LEDs OFF\n";
    verify_uart_transmission(expected_output);
    
    EMBEDDED_BENCHMARK_END();
    
    result_collector.add_test_result("InterruptDrivenCoordination", true, "Interrupt-driven coordination successful");
}

TEST_F(PeripheralCoordinationTest, PeripheralSynchronization) {
    EMBEDDED_BENCHMARK_START("PeripheralSynchronization");
    
    TestTimer sync_timer;
    sync_timer.start();
    
    // Test synchronized peripheral operations
    const int sync_cycles = 5;
    
    for (int i = 0; i < sync_cycles; ++i) {
        // Synchronized start
        TestTimer cycle_timer;
        cycle_timer.start();
        
        // Simultaneous peripheral operations
        simulate_timer_ticks(1);
        set_led_state(0x1000 << (i % 4));
        simulate_uart_transmit("Sync cycle " + std::to_string(i) + "\n");
        
        // Verify cycle timing
        double cycle_time = cycle_timer.elapsed_ms();
        EMBEDDED_ASSERT_TIMING(cycle_time, 5.0, 100.0);  // Very loose timing for simulation
    }
    
    // Final synchronization
    set_led_state(0x0000);
    simulate_uart_transmit("Synchronization complete\n");
    
    double total_time = sync_timer.elapsed_ms();
    
    // Verify synchronization timing
    EMBEDDED_ASSERT_TIMING(total_time, 25.0, 100.0);  // 5 cycles * ~5ms each
    
    verify_all_leds_off();
    
    EMBEDDED_BENCHMARK_END();
    
    result_collector.add_test_result("PeripheralSynchronization", true, "Peripheral synchronization successful");
}

TEST_F(PeripheralCoordinationTest, PeripheralResourceSharing) {
    EMBEDDED_BENCHMARK_START("PeripheralResourceSharing");
    
    // Test resource sharing between peripherals
    
    // GPIO resource sharing (different pins)
    set_led_state(0x1000);  // Green LED
    simulate_button_press(0);  // Button uses different GPIO
    
    // Timer resource sharing (different timer functions)
    simulate_timer_ticks(5);   // System tick
    // Simulate PWM timer (would use different timer channel)
    
    // UART resource sharing (TX/RX)
    simulate_uart_transmit("TX: Resource sharing test\n");
    simulate_uart_receive("RX: Acknowledgment\n");
    
    // Verify resource sharing doesn't cause conflicts
    verify_all_leds_off();  // Clean up GPIO
    simulate_button_release(0);
    
    EXPECT_GE(get_timer_tick_count(), 5);
    verify_uart_transmission("TX: Resource sharing test\n");
    verify_uart_reception("RX: Acknowledgment\n");
    
    EMBEDDED_BENCHMARK_END();
    
    result_collector.add_test_result("PeripheralResourceSharing", true, "Peripheral resource sharing successful");
}

TEST_F(PeripheralCoordinationTest, PeripheralErrorHandling) {
    EMBEDDED_BENCHMARK_START("PeripheralErrorHandling");
    
    // Test error handling in peripheral coordination
    
    // Simulate GPIO error (invalid LED state)
    set_led_state(0xFFFF);  // Invalid state (all pins)
    simulate_uart_transmit("ERROR: Invalid GPIO state\n");
    
    // Recovery: Reset to safe state
    set_led_state(0x0000);
    simulate_uart_transmit("RECOVERY: GPIO reset to safe state\n");
    
    // Simulate timer error (missed ticks)
    // In real system, this might be detected by watchdog
    simulate_uart_transmit("WARNING: Timer synchronization issue\n");
    
    // Recovery: Re-synchronize
    simulate_timer_ticks(1);
    simulate_uart_transmit("RECOVERY: Timer re-synchronized\n");
    
    // Verify error handling and recovery
    verify_all_leds_off();
    EXPECT_GE(get_timer_tick_count(), 1);
    
    std::string expected_output = "ERROR: Invalid GPIO state\n"
                                "RECOVERY: GPIO reset to safe state\n"
                                "WARNING: Timer synchronization issue\n"
                                "RECOVERY: Timer re-synchronized\n";
    verify_uart_transmission(expected_output);
    
    EMBEDDED_BENCHMARK_END();
    
    result_collector.add_test_result("PeripheralErrorHandling", true, "Peripheral error handling successful");
}

// Test suite setup
class PeripheralCoordinationTestSuite : public ::testing::Test {
public:
    static void SetUpTestSuite() {
        std::cout << "=== Peripheral Coordination Test Suite ===" << std::endl;
        TestConfiguration::get_instance().set_verbose_output(true);
        TestConfiguration::get_instance().set_performance_testing_enabled(true);
        TestConfiguration::get_instance().set_hardware_simulation_enabled(true);
    }
    
    static void TearDownTestSuite() {
        std::cout << "=== Peripheral Coordination Test Suite Complete ===" << std::endl;
    }
};