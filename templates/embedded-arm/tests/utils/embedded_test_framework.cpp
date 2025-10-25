/**
 * @file embedded_test_framework.cpp
 * @brief Embedded-specific test framework extensions
 */

#include "embedded_test_framework.h"
#include <gtest/gtest.h>
#include <gmock/gmock.h>
#include <iostream>
#include <iomanip>

namespace EmbeddedTest {

// Test environment setup
void EmbeddedTestEnvironment::SetUp() {
    std::cout << "=== Embedded Test Environment Setup ===" << std::endl;
    
    // Reset all mock states
    reset_all_mocks();
    
    // Initialize test utilities
    MemoryTracker::reset();
    
    std::cout << "Test environment initialized successfully" << std::endl;
}

void EmbeddedTestEnvironment::TearDown() {
    std::cout << "=== Embedded Test Environment Teardown ===" << std::endl;
    
    // Report memory usage
    std::cout << "Peak memory usage: " << MemoryTracker::get_peak_usage() << " bytes" << std::endl;
    
    // Clean up
    reset_all_mocks();
    
    std::cout << "Test environment cleaned up successfully" << std::endl;
}

void EmbeddedTestEnvironment::reset_all_mocks() {
    // Reset mock states (implementation depends on specific mocks)
    std::cout << "All mocks reset to initial state" << std::endl;
}

// Hardware simulation
void HardwareSimulator::simulate_gpio_interrupt(uint32_t pin) {
    std::cout << "Simulating GPIO interrupt on pin " << pin << std::endl;
    // Trigger mock interrupt handler
    if (gpio_interrupt_callback) {
        gpio_interrupt_callback(pin);
    }
}

void HardwareSimulator::simulate_timer_interrupt() {
    std::cout << "Simulating timer interrupt" << std::endl;
    timer_tick_count++;
    if (timer_interrupt_callback) {
        timer_interrupt_callback();
    }
}

void HardwareSimulator::simulate_uart_data_received(const std::string& data) {
    std::cout << "Simulating UART data received: " << data << std::endl;
    uart_rx_buffer += data;
    if (uart_rx_callback) {
        uart_rx_callback(data);
    }
}

void HardwareSimulator::set_gpio_interrupt_callback(std::function<void(uint32_t)> callback) {
    gpio_interrupt_callback = callback;
}

void HardwareSimulator::set_timer_interrupt_callback(std::function<void()> callback) {
    timer_interrupt_callback = callback;
}

void HardwareSimulator::set_uart_rx_callback(std::function<void(const std::string&)> callback) {
    uart_rx_callback = callback;
}

uint32_t HardwareSimulator::get_timer_tick_count() const {
    return timer_tick_count;
}

const std::string& HardwareSimulator::get_uart_rx_buffer() const {
    return uart_rx_buffer;
}

void HardwareSimulator::reset() {
    timer_tick_count = 0;
    uart_rx_buffer.clear();
    gpio_interrupt_callback = nullptr;
    timer_interrupt_callback = nullptr;
    uart_rx_callback = nullptr;
}

// Test result collector
void TestResultCollector::add_test_result(const std::string& test_name, bool passed, const std::string& details) {
    TestResult result;
    result.test_name = test_name;
    result.passed = passed;
    result.details = details;
    result.timestamp = std::chrono::system_clock::now();
    
    test_results.push_back(result);
    
    if (passed) {
        passed_count++;
    } else {
        failed_count++;
    }
}

void TestResultCollector::print_summary() const {
    std::cout << "\n=== Test Results Summary ===" << std::endl;
    std::cout << "Total tests: " << test_results.size() << std::endl;
    std::cout << "Passed: " << passed_count << std::endl;
    std::cout << "Failed: " << failed_count << std::endl;
    std::cout << "Success rate: " << std::fixed << std::setprecision(1) 
              << (100.0 * passed_count / test_results.size()) << "%" << std::endl;
    
    if (failed_count > 0) {
        std::cout << "\nFailed tests:" << std::endl;
        for (const auto& result : test_results) {
            if (!result.passed) {
                std::cout << "  - " << result.test_name << ": " << result.details << std::endl;
            }
        }
    }
    
    std::cout << "=========================" << std::endl;
}

void TestResultCollector::reset() {
    test_results.clear();
    passed_count = 0;
    failed_count = 0;
}

size_t TestResultCollector::get_total_count() const {
    return test_results.size();
}

size_t TestResultCollector::get_passed_count() const {
    return passed_count;
}

size_t TestResultCollector::get_failed_count() const {
    return failed_count;
}

// Performance benchmarking
void PerformanceBenchmark::start_benchmark(const std::string& name) {
    current_benchmark = name;
    benchmark_timer.start();
}

void PerformanceBenchmark::end_benchmark() {
    if (!current_benchmark.empty()) {
        double elapsed = benchmark_timer.elapsed_ms();
        benchmark_results[current_benchmark] = elapsed;
        
        std::cout << "Benchmark '" << current_benchmark 
                  << "' completed in " << elapsed << " ms" << std::endl;
        
        current_benchmark.clear();
    }
}

void PerformanceBenchmark::print_benchmark_results() const {
    std::cout << "\n=== Performance Benchmark Results ===" << std::endl;
    
    for (const auto& result : benchmark_results) {
        std::cout << std::setw(30) << std::left << result.first 
                  << ": " << std::fixed << std::setprecision(3) 
                  << result.second << " ms" << std::endl;
    }
    
    std::cout << "=====================================" << std::endl;
}

double PerformanceBenchmark::get_benchmark_result(const std::string& name) const {
    auto it = benchmark_results.find(name);
    return (it != benchmark_results.end()) ? it->second : -1.0;
}

void PerformanceBenchmark::reset() {
    benchmark_results.clear();
    current_benchmark.clear();
}

// Test configuration
TestConfiguration& TestConfiguration::get_instance() {
    static TestConfiguration instance;
    return instance;
}

void TestConfiguration::set_verbose_output(bool verbose) {
    verbose_output = verbose;
}

void TestConfiguration::set_performance_testing_enabled(bool enabled) {
    performance_testing_enabled = enabled;
}

void TestConfiguration::set_hardware_simulation_enabled(bool enabled) {
    hardware_simulation_enabled = enabled;
}

void TestConfiguration::set_memory_tracking_enabled(bool enabled) {
    memory_tracking_enabled = enabled;
}

bool TestConfiguration::is_verbose_output() const {
    return verbose_output;
}

bool TestConfiguration::is_performance_testing_enabled() const {
    return performance_testing_enabled;
}

bool TestConfiguration::is_hardware_simulation_enabled() const {
    return hardware_simulation_enabled;
}

bool TestConfiguration::is_memory_tracking_enabled() const {
    return memory_tracking_enabled;
}

} // namespace EmbeddedTest