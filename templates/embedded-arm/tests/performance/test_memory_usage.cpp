/**
 * @file test_memory_usage.cpp
 * @brief Memory usage performance tests for embedded ARM project
 */

#include <gtest/gtest.h>
// Remove gmock include to avoid version conflicts
#include "../utils/test_helpers.h"

using namespace EmbeddedTest;

class MemoryUsageTest : public ::testing::Test {
protected:
    void SetUp() override {
        MemoryTracker::reset();
    }
};

TEST_F(MemoryUsageTest, BasicMemoryTracking) {
    // Reset memory tracker
    MemoryTracker::reset();
    EXPECT_EQ(MemoryTracker::get_current_usage(), 0);
    
    // Simulate memory allocation
    MemoryTracker::allocate(1024);
    EXPECT_EQ(MemoryTracker::get_current_usage(), 1024);
    EXPECT_EQ(MemoryTracker::get_peak_usage(), 1024);
    
    // Additional allocation
    MemoryTracker::allocate(512);
    EXPECT_EQ(MemoryTracker::get_current_usage(), 1536);
    EXPECT_EQ(MemoryTracker::get_peak_usage(), 1536);
    
    // Deallocation
    MemoryTracker::deallocate(512);
    EXPECT_EQ(MemoryTracker::get_current_usage(), 1024);
    EXPECT_EQ(MemoryTracker::get_peak_usage(), 1536);  // Peak remains
    
    // Complete deallocation
    MemoryTracker::deallocate(1024);
    EXPECT_EQ(MemoryTracker::get_current_usage(), 0);
    EXPECT_EQ(MemoryTracker::get_peak_usage(), 1536);  // Peak remains
}

TEST_F(MemoryUsageTest, MemoryLimitValidation) {
    MemoryTracker::reset();
    
    // Test memory limit assertions
    MemoryTracker::allocate(1024);
    EXPECT_LE(MemoryTracker::get_current_usage(), 2048);  // Should pass
    
    MemoryTracker::allocate(512);
    EXPECT_LE(MemoryTracker::get_current_usage(), 2048);  // Should pass
    
    // Clean up
    MemoryTracker::deallocate(1536);
}

// Simple test suite without complex dependencies