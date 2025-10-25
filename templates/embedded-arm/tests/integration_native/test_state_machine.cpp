/**
 * @file test_state_machine.cpp
 * @brief State machine tests for embedded ARM project
 */

#include <gtest/gtest.h>
#include <gmock/gmock.h>
#include "../fixtures/hardware_fixtures.h"
#include "../utils/embedded_test_framework.h"

using namespace EmbeddedTest;

class StateMachineTest : public SystemIntegrationTestFixture {
protected:
    void SetUp() override {
        SystemIntegrationTestFixture::SetUp();
        
        if (TestConfiguration::get_instance().is_verbose_output()) {
            std::cout << "Starting state machine test" << std::endl;
        }
    }
};

TEST_F(StateMachineTest, BasicStateTransitions) {
    EMBEDDED_BENCHMARK_START("BasicStateTransitions");
    
    // Test basic state transitions
    system_verifier.set_system_state(SystemState::INIT);
    EXPECT_EQ(system_verifier.get_current_state(), SystemState::INIT);
    
    system_verifier.set_system_state(SystemState::IDLE);
    EXPECT_EQ(system_verifier.get_current_state(), SystemState::IDLE);
    
    system_verifier.set_system_state(SystemState::ACTIVE);
    EXPECT_EQ(system_verifier.get_current_state(), SystemState::ACTIVE);
    
    system_verifier.set_system_state(SystemState::IDLE);
    EXPECT_EQ(system_verifier.get_current_state(), SystemState::IDLE);
    
    EMBEDDED_BENCHMARK_END();
    
    result_collector.add_test_result("BasicStateTransitions", true, "Basic state transitions successful");
}

TEST_F(StateMachineTest, StateSequenceValidation) {
    EMBEDDED_BENCHMARK_START("StateSequenceValidation");
    
    // Create expected state sequence
    std::vector<SystemState> expected_sequence = {
        SystemState::INIT,
        SystemState::IDLE,
        SystemState::ACTIVE,
        SystemState::IDLE
    };
    
    // Execute state sequence
    for (SystemState state : expected_sequence) {
        system_verifier.set_system_state(state);
    }
    
    // Verify sequence
    verify_system_state_sequence(expected_sequence);
    
    EMBEDDED_BENCHMARK_END();
    
    result_collector.add_test_result("StateSequenceValidation", true, "State sequence validation successful");
}

TEST_F(StateMachineTest, ErrorStateHandling) {
    EMBEDDED_BENCHMARK_START("ErrorStateHandling");
    
    // Normal operation
    system_verifier.set_system_state(SystemState::INIT);
    system_verifier.set_system_state(SystemState::IDLE);
    system_verifier.set_system_state(SystemState::ACTIVE);
    
    // Error condition
    system_verifier.set_system_state(SystemState::ERROR);
    EXPECT_EQ(system_verifier.get_current_state(), SystemState::ERROR);
    
    // Recovery
    system_verifier.set_system_state(SystemState::INIT);
    system_verifier.set_system_state(SystemState::IDLE);
    
    // Verify recovery
    EXPECT_EQ(system_verifier.get_current_state(), SystemState::IDLE);
    
    EMBEDDED_BENCHMARK_END();
    
    result_collector.add_test_result("ErrorStateHandling", true, "Error state handling successful");
}

// Test suite setup
class StateMachineTestSuite : public ::testing::Test {
public:
    static void SetUpTestSuite() {
        std::cout << "=== State Machine Test Suite ===" << std::endl;
        TestConfiguration::get_instance().set_verbose_output(true);
    }
    
    static void TearDownTestSuite() {
        std::cout << "=== State Machine Test Suite Complete ===" << std::endl;
    }
};