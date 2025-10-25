/**
 * @file test_system_integration.cpp
 * @brief System integration tests for embedded ARM project
 */

#include <gtest/gtest.h>
#include <gmock/gmock.h>
#include "../fixtures/hardware_fixtures.h"
#include "../utils/embedded_test_framework.h"

using namespace EmbeddedTest;

class SystemIntegrationTest : public SystemIntegrationTestFixture {
protected:
    void SetUp() override {
        SystemIntegrationTestFixture::SetUp();
        
        if (TestConfiguration::get_instance().is_verbose_output()) {
            std::cout << "Starting system integration test" << std::endl;
        }
    }
};

TEST_F(SystemIntegrationTest, SystemStartupSequence) {
    EMBEDDED_BENCHMARK_START("SystemStartup");
    
    // Test system startup sequence
    simulate_system_startup();
    
    // Verify initial state
    EXPECT_EQ(system_verifier.get_current_state(), SystemState::IDLE);
    
    // Verify state transition sequence
    std::vector<SystemState> expected_sequence = {
        SystemState::INIT,
        SystemState::IDLE
    };
    verify_system_state_sequence(expected_sequence);
    
    EMBEDDED_BENCHMARK_END();
    
    result_collector.add_test_result("SystemStartupSequence", true, "System startup completed successfully");
}

TEST_F(SystemIntegrationTest, SystemOperationCycle) {
    EMBEDDED_BENCHMARK_START("SystemOperation");
    
    // Start system
    simulate_system_startup();
    
    // Run operation cycle
    simulate_system_operation(100);  // 100ms operation
    
    // Verify system returned to idle
    EXPECT_EQ(system_verifier.get_current_state(), SystemState::IDLE);
    
    // Verify timer ticks occurred
    EXPECT_GT(get_timer_tick_count(), 0);
    
    EMBEDDED_BENCHMARK_END();
    
    result_collector.add_test_result("SystemOperationCycle", true, "Operation cycle completed successfully");
}

TEST_F(SystemIntegrationTest, MultipleSubsystemCoordination) {
    EMBEDDED_BENCHMARK_START("SubsystemCoordination");
    
    // Initialize system
    simulate_system_startup();
    
    // Test GPIO + Timer coordination
    simulate_button_press(0);  // User button
    simulate_timer_ticks(10);
    
    // Test LED + Timer coordination
    set_led_state(0xF000);  // All LEDs on
    simulate_timer_ticks(5);
    set_led_state(0x0000);  // All LEDs off
    
    // Test UART + System state coordination
    simulate_uart_transmit("System Status: OK\n");
    
    // Verify coordinated operation
    EXPECT_EQ(system_verifier.get_current_state(), SystemState::IDLE);
    verify_all_leds_off();
    EXPECT_EQ(get_uart_tx_buffer(), "System Status: OK\n");
    
    EMBEDDED_BENCHMARK_END();
    
    result_collector.add_test_result("MultipleSubsystemCoordination", true, "Subsystem coordination successful");
}

TEST_F(SystemIntegrationTest, SystemStateTransitions) {
    EMBEDDED_BENCHMARK_START("StateTransitions");
    
    // Test complete state transition cycle
    system_verifier.set_system_state(SystemState::INIT);
    system_verifier.set_system_state(SystemState::IDLE);
    system_verifier.set_system_state(SystemState::ACTIVE);
    system_verifier.set_system_state(SystemState::IDLE);
    
    // Verify state history
    std::vector<SystemState> expected_sequence = {
        SystemState::IDLE,
        SystemState::ACTIVE,
        SystemState::IDLE
    };
    verify_system_state_sequence(expected_sequence);
    
    EMBEDDED_BENCHMARK_END();
    
    result_collector.add_test_result("SystemStateTransitions", true, "State transitions working correctly");
}

TEST_F(SystemIntegrationTest, ErrorHandlingAndRecovery) {
    EMBEDDED_BENCHMARK_START("ErrorHandling");
    
    // Simulate error condition
    system_verifier.set_system_state(SystemState::ERROR);
    
    // Simulate recovery sequence
    simulate_timer_ticks(5);  // Error handling time
    system_verifier.set_system_state(SystemState::INIT);
    system_verifier.set_system_state(SystemState::IDLE);
    
    // Verify recovery
    EXPECT_EQ(system_verifier.get_current_state(), SystemState::IDLE);
    
    // Verify error was in state history
    const auto& history = system_verifier.get_state_history();
    bool error_found = false;
    for (const auto& state : history) {
        if (state == SystemState::ERROR) {
            error_found = true;
            break;
        }
    }
    EXPECT_TRUE(error_found) << "Error state should be recorded in history";
    
    EMBEDDED_BENCHMARK_END();
    
    result_collector.add_test_result("ErrorHandlingAndRecovery", true, "Error handling and recovery successful");
}

TEST_F(SystemIntegrationTest, RealTimeConstraints) {
    EMBEDDED_BENCHMARK_START("RealTimeConstraints");
    
    TestTimer timer;
    timer.start();
    
    // Simulate real-time operation
    simulate_system_startup();
    simulate_timer_ticks(100);  // 100ms of operation
    
    double elapsed = timer.elapsed_ms();
    
    // Verify timing constraints (should complete within reasonable time)
    EMBEDDED_ASSERT_TIMING(elapsed, 100.0, 50.0);  // 50% tolerance for simulation
    
    EMBEDDED_BENCHMARK_END();
    
    result_collector.add_test_result("RealTimeConstraints", true, "Real-time constraints met");
}

TEST_F(SystemIntegrationTest, MemoryUsageValidation) {
    EMBEDDED_BENCHMARK_START("MemoryUsage");
    
    // Track memory usage during system operation
    MemoryTracker::reset();
    
    // Simulate memory allocation during operation
    MemoryTracker::allocate(1024);  // Simulate 1KB allocation
    simulate_system_operation(50);
    MemoryTracker::allocate(512);   // Additional allocation
    
    // Verify memory usage is within limits
    size_t peak_usage = MemoryTracker::get_peak_usage();
    EMBEDDED_ASSERT_MEMORY_LIMIT(peak_usage, 2048);  // 2KB limit
    
    // Clean up
    MemoryTracker::deallocate(1536);  // Total allocated
    
    EMBEDDED_BENCHMARK_END();
    
    result_collector.add_test_result("MemoryUsageValidation", true, "Memory usage within limits");
}

TEST_F(SystemIntegrationTest, ConcurrentOperations) {
    EMBEDDED_BENCHMARK_START("ConcurrentOperations");
    
    // Simulate concurrent operations
    simulate_system_startup();
    
    // Concurrent GPIO and Timer operations
    simulate_button_press(0);
    simulate_timer_ticks(5);
    set_led_state(0x1000);  // Green LED
    simulate_timer_ticks(5);
    simulate_button_release(0);
    set_led_state(0x0000);  // LEDs off
    
    // Concurrent UART and system state operations
    simulate_uart_transmit("Concurrent test\n");
    system_verifier.set_system_state(SystemState::ACTIVE);
    simulate_uart_transmit("Active state\n");
    system_verifier.set_system_state(SystemState::IDLE);
    
    // Verify all operations completed successfully
    EXPECT_EQ(system_verifier.get_current_state(), SystemState::IDLE);
    verify_all_leds_off();
    EXPECT_EQ(get_uart_tx_buffer(), "Concurrent test\nActive state\n");
    
    EMBEDDED_BENCHMARK_END();
    
    result_collector.add_test_result("ConcurrentOperations", true, "Concurrent operations successful");
}

// Test suite setup
class SystemIntegrationTestSuite : public ::testing::Test {
public:
    static void SetUpTestSuite() {
        std::cout << "=== System Integration Test Suite ===" << std::endl;
        TestConfiguration::get_instance().set_verbose_output(true);
        TestConfiguration::get_instance().set_performance_testing_enabled(true);
    }
    
    static void TearDownTestSuite() {
        std::cout << "=== System Integration Test Suite Complete ===" << std::endl;
    }
};

} // Anonymous namespace for test suite