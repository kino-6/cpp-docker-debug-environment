# Unity/CMock Sample Configuration
cmake_minimum_required(VERSION 3.16)

# Project
project(UnitySample VERSION 1.0.0 LANGUAGES C)

# C standard
set(CMAKE_C_STANDARD 17)
set(CMAKE_C_STANDARD_REQUIRED ON)

# Fetch Unity framework
include(FetchContent)
FetchContent_Declare(
    unity
    GIT_REPOSITORY https://github.com/ThrowTheSwitch/Unity.git
    GIT_TAG        v2.5.2
)
FetchContent_MakeAvailable(unity)

# Note: CMock has complex dependencies, so we use manual mocks for this sample
# This demonstrates the same concepts with simpler implementation

# Include directories
include_directories(
    ${unity_SOURCE_DIR}/src
    src
    mocks
)

# Unity source files
set(UNITY_SOURCES
    ${unity_SOURCE_DIR}/src/unity.c
)

# Mock files (manual mocks - simpler than CMock for learning)
set(MOCK_SOURCES
    mocks/mock_gpio.c
)

# Test source files
set(TEST_SOURCES
    src/test_led_unity.c
    src/test_runner.c
)

# Create test executable
add_executable(UnityTestRunner
    ${UNITY_SOURCES}
    ${MOCK_SOURCES}
    ${TEST_SOURCES}
)

# Compiler definitions
target_compile_definitions(UnityTestRunner PRIVATE
    UNITY_INCLUDE_CONFIG_H
)

# Set output directory
set_target_properties(UnityTestRunner PROPERTIES
    RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/bin
)

# Enable testing
enable_testing()
add_test(NAME UnityTests COMMAND UnityTestRunner)