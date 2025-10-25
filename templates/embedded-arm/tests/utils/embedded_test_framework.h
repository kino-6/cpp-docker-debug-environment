/**
 * @file embedded_test_framework.h
 * @brief Embedded-specific test framework extensions
 */

#ifndef EMBEDDED_TEST_FRAMEWORK_H
#define EMBEDDED_TEST_FRAMEWORK_H

#include "test_helpers.h"
#include <gtest/gtest.h>
#include <functional>
#include <string>
#include <vector>
#include <map>
#include <chrono>

namespace EmbeddedTest {

/**
 * @brief Test environment for embedded systems
 */
class EmbeddedTestEnvironment : public ::testing::Environment {
public:
    void SetUp() override;
    void TearDown() override;

private:
    void reset_all_mocks();
};

/**
 * @brief Hardware simulation utilities
 */
class HardwareSimulator {
private:
    std::function<void(uint32_t)> gpio_interrupt_callback;
    std::function<void()> timer_interrupt_callback;
    std::function<void(const std::string&)> uart_rx_callback;
    
    uint32_t timer_tick_count = 0;
    std::string uart_rx_buffer;

public:
    void simulate_gpio_interrupt(uint32_t pin);
    void simulate_timer_interrupt();
    void simulate_uart_data_received(const std::string& data);
    
    void set_gpio_interrupt_callback(std::function<void(uint32_t)> callback);
    void set_timer_interrupt_callback(std::function<void()> callback);
    void set_uart_rx_callback(std::function<void(const std::string&)> callback);
    
    uint32_t get_timer_tick_count() const;
    const std::string& get_uart_rx_buffer() const;
    
    void reset();
};

/**
 * @brief Test result collection and reporting
 */
class TestResultCollector {
private:
    struct TestResult {
        std::string test_name;
        bool passed;
        std::string details;
        std::chrono::system_clock::time_point timestamp;
    };
    
    std::vector<TestResult> test_results;
    size_t passed_count = 0;
    size_t failed_count = 0;

public:
    void add_test_result(const std::string& test_name, bool passed, const std::string& details = "");
    void print_summary() const;
    void reset();
    
    size_t get_total_count() const;
    size_t get_passed_count() const;
    size_t get_failed_count() const;
};

/**
 * @brief Performance benchmarking utilities
 */
class PerformanceBenchmark {
private:
    std::map<std::string, double> benchmark_results;
    TestTimer benchmark_timer;
    std::string current_benchmark;

public:
    void start_benchmark(const std::string& name);
    void end_benchmark();
    void print_benchmark_results() const;
    double get_benchmark_result(const std::string& name) const;
    void reset();
};

/**
 * @brief Test configuration management
 */
class TestConfiguration {
private:
    bool verbose_output = false;
    bool performance_testing_enabled = true;
    bool hardware_simulation_enabled = true;
    bool memory_tracking_enabled = true;
    
    TestConfiguration() = default;

public:
    static TestConfiguration& get_instance();
    
    void set_verbose_output(bool verbose);
    void set_performance_testing_enabled(bool enabled);
    void set_hardware_simulation_enabled(bool enabled);
    void set_memory_tracking_enabled(bool enabled);
    
    bool is_verbose_output() const;
    bool is_performance_testing_enabled() const;
    bool is_hardware_simulation_enabled() const;
    bool is_memory_tracking_enabled() const;
};

/**
 * @brief Embedded test fixture base class
 */
class EmbeddedTestFixture : public ::testing::Test {
protected:
    HardwareSimulator hardware_sim;
    TestResultCollector result_collector;
    PerformanceBenchmark benchmark;
    
    void SetUp() override {
        hardware_sim.reset();
        result_collector.reset();
        benchmark.reset();
        MemoryTracker::reset();
    }
    
    void TearDown() override {
        if (TestConfiguration::get_instance().is_verbose_output()) {
            result_collector.print_summary();
            benchmark.print_benchmark_results();
        }
    }
};

} // namespace EmbeddedTest

// Convenience macros for embedded testing
#define EMBEDDED_TEST_F(test_fixture, test_name) \
    TEST_F(test_fixture, test_name)

#define EMBEDDED_ASSERT_TIMING(actual_ms, expected_ms, tolerance_percent) \
    EmbeddedTest::TestAssertions::assert_timing_within_tolerance(actual_ms, expected_ms, tolerance_percent)

#define EMBEDDED_ASSERT_MEMORY_LIMIT(actual_bytes, limit_bytes) \
    EmbeddedTest::TestAssertions::assert_memory_usage_within_limit(actual_bytes, limit_bytes)

#define EMBEDDED_BENCHMARK_START(name) \
    benchmark.start_benchmark(name)

#define EMBEDDED_BENCHMARK_END() \
    benchmark.end_benchmark()

#endif // EMBEDDED_TEST_FRAMEWORK_H