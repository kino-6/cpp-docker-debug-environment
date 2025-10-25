/**
 * @file test_helpers.h
 * @brief Test Helper Functions and Utilities for Embedded ARM Testing
 */

#ifndef TEST_HELPERS_H
#define TEST_HELPERS_H

#include <vector>
#include <map>
#include <chrono>
#include <cstdint>
#include <cstddef>

namespace EmbeddedTest {

// System states for testing
enum class SystemState {
    UNKNOWN,
    INIT,
    IDLE,
    ACTIVE,
    ERROR
};

// Pattern types for LED testing
enum class PatternType {
    SEQUENTIAL,
    BINARY_COUNTER,
    KNIGHT_RIDER,
    RANDOM
};

/**
 * @brief Timer utility for performance testing
 */
class TestTimer {
private:
    std::chrono::high_resolution_clock::time_point start_time;

public:
    void start();
    double elapsed_ms() const;
};

/**
 * @brief Memory usage tracking for embedded systems
 */
class MemoryTracker {
private:
    static size_t current_usage;
    static size_t peak_usage;

public:
    static void allocate(size_t size);
    static void deallocate(size_t size);
    static void reset();
    static size_t get_current_usage();
    static size_t get_peak_usage();
};

/**
 * @brief GPIO state verification utilities
 */
class GPIOStateVerifier {
private:
    std::map<uint32_t, bool> mock_gpio_states;

public:
    bool verify_pin_state(uint32_t pin, bool expected_state);
    void set_mock_pin_state(uint32_t pin, bool state);
    void reset_all_pins();
};

/**
 * @brief LED pattern verification utilities
 */
class LEDPatternVerifier {
private:
    std::vector<uint32_t> recorded_pattern;

public:
    bool verify_pattern(const std::vector<uint32_t>& expected_pattern);
    void record_led_state(uint32_t led_state);
    void clear_pattern();
    const std::vector<uint32_t>& get_recorded_pattern() const;
};

/**
 * @brief System state verification utilities
 */
class SystemStateVerifier {
private:
    SystemState current_state = SystemState::UNKNOWN;
    std::vector<SystemState> state_history;

public:
    void set_system_state(SystemState state);
    SystemState get_current_state() const;
    const std::vector<SystemState>& get_state_history() const;
    bool verify_state_sequence(const std::vector<SystemState>& expected_sequence);
    void reset();
};

/**
 * @brief Test data generators
 */
class TestDataGenerator {
public:
    static std::vector<uint32_t> generate_led_pattern(PatternType type, size_t length);
    static std::vector<SystemState> generate_state_sequence(size_t length);
};

/**
 * @brief Enhanced test assertions for embedded systems
 */
class TestAssertions {
public:
    static void assert_timing_within_tolerance(double actual_ms, double expected_ms, double tolerance_percent = 5.0);
    static void assert_memory_usage_within_limit(size_t actual_bytes, size_t limit_bytes);
    static void assert_gpio_pattern_matches(const std::vector<uint32_t>& actual, const std::vector<uint32_t>& expected);
};

} // namespace EmbeddedTest

#endif // TEST_HELPERS_H