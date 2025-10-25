/**
 * @file simple_test.cpp
 * @brief Simple Google Test without complex dependencies
 */

#include <gtest/gtest.h>

// Simple test without any external dependencies
TEST(SimpleTest, BasicAssertion) {
    EXPECT_EQ(2 + 2, 4);
    EXPECT_TRUE(true);
    EXPECT_FALSE(false);
}

TEST(SimpleTest, StringComparison) {
    std::string hello = "Hello";
    std::string world = "World";
    
    EXPECT_EQ(hello, "Hello");
    EXPECT_NE(hello, world);
    EXPECT_LT(hello.length(), 10);
}

TEST(SimpleTest, NumericOperations) {
    int a = 10;
    int b = 20;
    
    EXPECT_EQ(a + b, 30);
    EXPECT_GT(b, a);
    EXPECT_LE(a, 10);
}

// Test class with setup/teardown
class SimpleTestFixture : public ::testing::Test {
protected:
    void SetUp() override {
        value = 42;
    }
    
    void TearDown() override {
        value = 0;
    }
    
    int value;
};

TEST_F(SimpleTestFixture, FixtureTest) {
    EXPECT_EQ(value, 42);
    
    value *= 2;
    EXPECT_EQ(value, 84);
}