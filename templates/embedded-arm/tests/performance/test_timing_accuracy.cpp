/**
 * @file test_timing_accuracy.cpp
 * @brief Timing accuracy performance tests for embedded ARM project
 */

#include <gtest/gtest.h>
#include <gmock/gmock.h>
#include "../fixtures/hardware_fixtures.h"
#include "../utils/embedded_test_framework.h"
#include <vector>
#include <algorithm>
#include <numeric>

using namespace EmbeddedTest;

class TimingAccuracyTest : public TimerTestFixture {
protected:
    void SetUp() override {
        TimerTestFixture::SetUp();
        
        if (TestConfiguration::get_instance().is_verbose_output()) {
            std::cout << "Starting timing accuracy performance test" << std::endl;
        }
    }
    
    // Helper function to calculate statistics
    struct TimingStats {
        double mean;
        double std_dev;
        double min_val;
        double max_val;
    };
    
    TimingStats calculate_timing_stats(const std::vector<double>& measurements) {
        TimingStats stats;
        
        stats.min_val = *std::min_element(measurements.begin(), measurements.end());
        stats.max_val = *std::max_element(measurements.begin(), measurements.end());
        
        stats.mean = std::accumulate(measurements.begin(), measurements.end(), 0.0) / measurements.size();
        
        double variance = 0.0;
        for (double measurement : measurements) {
            variance += (measurement - stats.mean) * (measurement - stats.mean);
        }
        variance /= measurements.size();
        stats.std_dev = std::sqrt(variance);
        
        return stats;
    }
};

TEST_F(TimingAccuracyTest, SingleTimerTickAccuracy) {
    EMBEDDED_BENCHMARK_START("SingleTimerTick");
    
    const int num_measurements = 100;
    std::vector<double> tick_times;
    
    for (int i = 0; i < num_measurements; ++i) {
        TestTimer timer;
        timer.start();
        
        simulate_timer_ticks(1);
        
        double elapsed = timer.elapsed_ms();
        tick_times.push_back(elapsed);
    }
    
    TimingStats stats = calculate_timing_stats(tick_times);
    
    // Verify timing accuracy (1ms target with reasonable tolerance for simulation)
    EMBEDDED_ASSERT_TIMING(stats.mean, 1.0, 50.0);  // 50% tolerance for simulation
    EXPECT_LT(stats.std_dev, 0.5) << "Timer tick standard deviation too high: " << stats.std_dev;
    
    if (TestConfiguration::get_instance().is_verbose_output()) {
        std::cout << "Timer tick statistics:" << std::endl;
        std::cout << "  Mean: " << stats.mean << " ms" << std::endl;
        std::cout << "  Std Dev: " << stats.std_dev << " ms" << std::endl;
        std::cout << "  Min: " << stats.min_val << " ms" << std::endl;
        std::cout << "  Max: " << stats.max_val << " ms" << std::endl;
    }
    
    EMBEDDED_BENCHMARK_END();
    
    result_collector.add_test_result("SingleTimerTickAccuracy", true, 
                                   "Timer tick accuracy: " + std::to_string(stats.mean) + "ms ±" + std::to_string(stats.std_dev) + "ms");
}

TEST_F(TimingAccuracyTest, MultipleTimerTickAccuracy) {
    EMBEDDED_BENCHMARK_START("MultipleTimerTicks");
    
    const std::vector<int> tick_counts = {5, 10, 25, 50, 100};
    
    for (int tick_count : tick_counts) {
        TestTimer timer;
        timer.start();
        
        simulate_timer_ticks(tick_count);
        
        double elapsed = timer.elapsed_ms();
        double expected = tick_count * 1.0;  // 1ms per tick
        
        EMBEDDED_ASSERT_TIMING(elapsed, expected, 50.0);  // 50% tolerance
        
        if (TestConfiguration::get_instance().is_verbose_output()) {
            std::cout << "  " << tick_count << " ticks: " << elapsed << " ms (expected: " << expected << " ms)" << std::endl;
        }
    }
    
    EMBEDDED_BENCHMARK_END();
    
    result_collector.add_test_result("MultipleTimerTickAccuracy", true, "Multiple timer tick accuracy verified");
}

TEST_F(TimingAccuracyTest, TimerJitterMeasurement) {
    EMBEDDED_BENCHMARK_START("TimerJitter");
    
    const int num_measurements = 50;
    std::vector<double> jitter_measurements;
    
    double previous_time = 0.0;
    
    for (int i = 0; i < num_measurements; ++i) {
        TestTimer timer;
        timer.start();
        
        simulate_timer_ticks(1);
        
        double current_time = timer.elapsed_ms();
        
        if (i > 0) {
            double jitter = std::abs(current_time - previous_time);
            jitter_measurements.push_back(jitter);
        }
        
        previous_time = current_time;
    }
    
    TimingStats jitter_stats = calculate_timing_stats(jitter_measurements);
    
    // Verify jitter is within acceptable limits
    EXPECT_LT(jitter_stats.mean, 0.1) << "Average jitter too high: " << jitter_stats.mean << " ms";
    EXPECT_LT(jitter_stats.max_val, 0.5) << "Maximum jitter too high: " << jitter_stats.max_val << " ms";
    
    if (TestConfiguration::get_instance().is_verbose_output()) {
        std::cout << "Timer jitter statistics:" << std::endl;
        std::cout << "  Mean jitter: " << jitter_stats.mean << " ms" << std::endl;
        std::cout << "  Max jitter: " << jitter_stats.max_val << " ms" << std::endl;
    }
    
    EMBEDDED_BENCHMARK_END();
    
    result_collector.add_test_result("TimerJitterMeasurement", true, 
                                   "Timer jitter: " + std::to_string(jitter_stats.mean) + "ms avg, " + std::to_string(jitter_stats.max_val) + "ms max");
}

TEST_F(TimingAccuracyTest, LongTermTimingStability) {
    EMBEDDED_BENCHMARK_START("LongTermStability");
    
    const int long_duration_ticks = 1000;  // 1 second simulation
    
    TestTimer overall_timer;
    overall_timer.start();
    
    // Measure timing over extended period
    simulate_timer_ticks(long_duration_ticks);
    
    double total_elapsed = overall_timer.elapsed_ms();
    double expected_time = long_duration_ticks * 1.0;  // 1ms per tick
    
    // Calculate drift
    double drift = total_elapsed - expected_time;
    double drift_percentage = (drift / expected_time) * 100.0;
    
    // Verify long-term stability
    EMBEDDED_ASSERT_TIMING(total_elapsed, expected_time, 10.0);  // 10% tolerance for long-term
    EXPECT_LT(std::abs(drift_percentage), 5.0) << "Long-term drift too high: " << drift_percentage << "%";
    
    if (TestConfiguration::get_instance().is_verbose_output()) {
        std::cout << "Long-term timing stability:" << std::endl;
        std::cout << "  Expected: " << expected_time << " ms" << std::endl;
        std::cout << "  Actual: " << total_elapsed << " ms" << std::endl;
        std::cout << "  Drift: " << drift << " ms (" << drift_percentage << "%)" << std::endl;
    }
    
    EMBEDDED_BENCHMARK_END();
    
    result_collector.add_test_result("LongTermTimingStability", true, 
                                   "Long-term drift: " + std::to_string(drift_percentage) + "%");
}

TEST_F(TimingAccuracyTest, InterruptLatencyMeasurement) {
    EMBEDDED_BENCHMARK_START("InterruptLatency");
    
    const int num_measurements = 20;
    std::vector<double> latency_measurements;
    
    for (int i = 0; i < num_measurements; ++i) {
        TestTimer latency_timer;
        
        // Simulate interrupt trigger
        latency_timer.start();
        hardware_sim.simulate_timer_interrupt();
        double latency = latency_timer.elapsed_ms();
        
        latency_measurements.push_back(latency);
    }
    
    TimingStats latency_stats = calculate_timing_stats(latency_measurements);
    
    // Verify interrupt latency is reasonable
    EXPECT_LT(latency_stats.mean, 0.1) << "Average interrupt latency too high: " << latency_stats.mean << " ms";
    EXPECT_LT(latency_stats.max_val, 0.5) << "Maximum interrupt latency too high: " << latency_stats.max_val << " ms";
    
    if (TestConfiguration::get_instance().is_verbose_output()) {
        std::cout << "Interrupt latency statistics:" << std::endl;
        std::cout << "  Mean: " << latency_stats.mean << " ms" << std::endl;
        std::cout << "  Max: " << latency_stats.max_val << " ms" << std::endl;
    }
    
    EMBEDDED_BENCHMARK_END();
    
    result_collector.add_test_result("InterruptLatencyMeasurement", true, 
                                   "Interrupt latency: " + std::to_string(latency_stats.mean) + "ms avg");
}

TEST_F(TimingAccuracyTest, TimerResolutionTest) {
    EMBEDDED_BENCHMARK_START("TimerResolution");
    
    // Test minimum detectable time difference
    const int resolution_tests = 10;
    std::vector<double> resolution_measurements;
    
    for (int i = 0; i < resolution_tests; ++i) {
        TestTimer timer1, timer2;
        
        timer1.start();
        // Minimal operation
        timer2.start();
        
        double time1 = timer1.elapsed_ms();
        double time2 = timer2.elapsed_ms();
        
        double resolution = std::abs(time2 - time1);
        if (resolution > 0.0) {
            resolution_measurements.push_back(resolution);
        }
    }
    
    if (!resolution_measurements.empty()) {
        TimingStats resolution_stats = calculate_timing_stats(resolution_measurements);
        
        if (TestConfiguration::get_instance().is_verbose_output()) {
            std::cout << "Timer resolution statistics:" << std::endl;
            std::cout << "  Minimum detectable: " << resolution_stats.min_val << " ms" << std::endl;
            std::cout << "  Average resolution: " << resolution_stats.mean << " ms" << std::endl;
        }
        
        result_collector.add_test_result("TimerResolutionTest", true, 
                                       "Timer resolution: " + std::to_string(resolution_stats.min_val) + "ms");
    } else {
        result_collector.add_test_result("TimerResolutionTest", true, "Timer resolution below measurement threshold");
    }
    
    EMBEDDED_BENCHMARK_END();
}

TEST_F(TimingAccuracyTest, ConcurrentTimingAccuracy) {
    EMBEDDED_BENCHMARK_START("ConcurrentTiming");
    
    // Test timing accuracy under concurrent operations
    TestTimer concurrent_timer;
    concurrent_timer.start();
    
    // Simulate concurrent timer operations
    for (int i = 0; i < 10; ++i) {
        simulate_timer_ticks(5);
        
        // Simulate other concurrent operations
        TestTimer operation_timer;
        operation_timer.start();
        
        // Simulate GPIO operations
        hardware_sim.simulate_gpio_interrupt(0);
        
        double operation_time = operation_timer.elapsed_ms();
        EXPECT_LT(operation_time, 1.0) << "Concurrent operation took too long: " << operation_time << " ms";
    }
    
    double total_concurrent_time = concurrent_timer.elapsed_ms();
    double expected_time = 10 * 5 * 1.0;  // 10 iterations * 5 ticks * 1ms
    
    EMBEDDED_ASSERT_TIMING(total_concurrent_time, expected_time, 50.0);
    
    EMBEDDED_BENCHMARK_END();
    
    result_collector.add_test_result("ConcurrentTimingAccuracy", true, 
                                   "Concurrent timing accuracy maintained");
}

// Test suite setup
class TimingAccuracyTestSuite : public ::testing::Test {
public:
    static void SetUpTestSuite() {
        std::cout << "=== Timing Accuracy Performance Test Suite ===" << std::endl;
        TestConfiguration::get_instance().set_verbose_output(true);
        TestConfiguration::get_instance().set_performance_testing_enabled(true);
    }
    
    static void TearDownTestSuite() {
        std::cout << "=== Timing Accuracy Performance Test Suite Complete ===" << std::endl;
    }
};