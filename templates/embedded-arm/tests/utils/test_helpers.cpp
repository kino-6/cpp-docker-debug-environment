/**
 * @file test_helpers.cpp
 * @brief Test Helper Functions for Embedded ARM Testing
 */

#include "test_helpers.h"
#include <gtest/gtest.h>
#include <gmock/gmock.h>
#include <chrono>
#include <thread>

namespace EmbeddedTest {

// Test timing utilities
void TestTimer::start() {
    start_time = std::chrono::high_resolution_clock::now();
}

double TestTimer::elapsed_ms() const {
    auto end_time = std::chrono::high_resolution_clock::now();
    auto duration = std::chrono::duration_cast<std::chrono::microseconds>(end_time - start_time);
    return duration.count() / 1000.0;
}

// Memory usage tracking
size_t MemoryTracker::current_usage = 0;
size_t MemoryTracker::peak_usage = 0;

void MemoryTracker::allocate(size_t size) {
    current_usage += size;
    if (current_usage > peak_usage) {
        peak_usage = current_usage;
    }
}

void MemoryTracker::deallocate(size_t size) {
    if (current_usage >= size) {
        current_usage -= size;
    }
}

void MemoryTracker::reset() {
    current_usage = 0;
    peak_usage = 0;
}

size_t MemoryTracker::get_current_usage() {
    return current_usage;
}

size_t MemoryTracker::get_peak_usage() {
    return peak_usage;
}

// GPIO state verification
bool GPIOStateVerifier::verify_pin_state(uint32_t pin, bool expected_state) {
    // Mock GPIO state verification
    // In real implementation, this would check actual GPIO registers
    return mock_gpio_states[pin] == expected_state;
}

void GPIOStateVerifier::set_mock_pin_state(uint32_t pin, bool state) {
    mock_gpio_states[pin] = state;
}

void GPIOStateVerifier::reset_all_pins() {
    mock_gpio_states.clear();
}

// LED pattern verification
bool LEDPatternVerifier::verify_pattern(const std::vector<uint32_t>& expected_pattern) {
    if (recorded_pattern.size() != expected_pattern.size()) {
        return false;
    }
    
    for (size_t i = 0; i < expected_pattern.size(); ++i) {
        if (recorded_pattern[i] != expected_pattern[i]) {
            return false;
        }
    }
    
    return true;
}

void LEDPatternVerifier::record_led_state(uint32_t led_state) {
    recorded_pattern.push_back(led_state);
}

void LEDPatternVerifier::clear_pattern() {
    recorded_pattern.clear();
}

const std::vector<uint32_t>& LEDPatternVerifier::get_recorded_pattern() const {
    return recorded_pattern;
}

// System state verification
void SystemStateVerifier::set_system_state(SystemState state) {
    current_state = state;
    state_history.push_back(state);
}

SystemState SystemStateVerifier::get_current_state() const {
    return current_state;
}

const std::vector<SystemState>& SystemStateVerifier::get_state_history() const {
    return state_history;
}

bool SystemStateVerifier::verify_state_sequence(const std::vector<SystemState>& expected_sequence) {
    if (state_history.size() < expected_sequence.size()) {
        return false;
    }
    
    // Check the last N states match the expected sequence
    size_t start_index = state_history.size() - expected_sequence.size();
    for (size_t i = 0; i < expected_sequence.size(); ++i) {
        if (state_history[start_index + i] != expected_sequence[i]) {
            return false;
        }
    }
    
    return true;
}

void SystemStateVerifier::reset() {
    current_state = SystemState::UNKNOWN;
    state_history.clear();
}

// Test data generators
std::vector<uint32_t> TestDataGenerator::generate_led_pattern(PatternType type, size_t length) {
    std::vector<uint32_t> pattern;
    
    switch (type) {
        case PatternType::SEQUENTIAL:
            for (size_t i = 0; i < length; ++i) {
                pattern.push_back(1 << (i % 4));  // Cycle through 4 LEDs
            }
            break;
            
        case PatternType::BINARY_COUNTER:
            for (size_t i = 0; i < length; ++i) {
                pattern.push_back(i % 16);  // 4-bit binary counter
            }
            break;
            
        case PatternType::KNIGHT_RIDER:
            // Forward sweep
            for (int i = 0; i < 4; ++i) {
                pattern.push_back(1 << i);
            }
            // Backward sweep
            for (int i = 2; i >= 1; --i) {
                pattern.push_back(1 << i);
            }
            break;
            
        case PatternType::RANDOM:
            for (size_t i = 0; i < length; ++i) {
                pattern.push_back(rand() % 16);
            }
            break;
    }
    
    return pattern;
}

std::vector<SystemState> TestDataGenerator::generate_state_sequence(size_t length) {
    std::vector<SystemState> sequence;
    SystemState states[] = {
        SystemState::INIT,
        SystemState::IDLE,
        SystemState::ACTIVE,
        SystemState::ERROR
    };
    
    for (size_t i = 0; i < length; ++i) {
        sequence.push_back(states[i % 4]);
    }
    
    return sequence;
}

// Test assertions
void TestAssertions::assert_timing_within_tolerance(double actual_ms, double expected_ms, double tolerance_percent) {
    double tolerance = expected_ms * (tolerance_percent / 100.0);
    EXPECT_NEAR(actual_ms, expected_ms, tolerance) 
        << "Timing assertion failed: actual=" << actual_ms 
        << "ms, expected=" << expected_ms 
        << "ms, tolerance=" << tolerance_percent << "%";
}

void TestAssertions::assert_memory_usage_within_limit(size_t actual_bytes, size_t limit_bytes) {
    EXPECT_LE(actual_bytes, limit_bytes)
        << "Memory usage exceeded limit: actual=" << actual_bytes 
        << " bytes, limit=" << limit_bytes << " bytes";
}

void TestAssertions::assert_gpio_pattern_matches(const std::vector<uint32_t>& actual, const std::vector<uint32_t>& expected) {
    ASSERT_EQ(actual.size(), expected.size()) << "Pattern length mismatch";
    
    for (size_t i = 0; i < expected.size(); ++i) {
        EXPECT_EQ(actual[i], expected[i]) 
            << "Pattern mismatch at index " << i 
            << ": actual=0x" << std::hex << actual[i] 
            << ", expected=0x" << std::hex << expected[i];
    }
}

} // namespace EmbeddedTest