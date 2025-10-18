# GoogleTest Integration for Embedded ARM Project
cmake_minimum_required(VERSION 3.16)

# Native test configuration
set(CMAKE_C_STANDARD 17)
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# Test project
project(EmbeddedArmTests VERSION 1.0.0 LANGUAGES C CXX)

# Use native compiler for tests
set(CMAKE_C_COMPILER gcc)
set(CMAKE_CXX_COMPILER g++)

# Test build configuration
set(CMAKE_BUILD_TYPE Debug)
set(CMAKE_C_FLAGS "-Wall -Wextra -g3 -O0 -DUNIT_TEST")
set(CMAKE_CXX_FLAGS "-Wall -Wextra -g3 -O0 -DUNIT_TEST")

# Include directories
include_directories(
    ${CMAKE_SOURCE_DIR}/../include
    ${CMAKE_SOURCE_DIR}/../src/hal
    ${CMAKE_SOURCE_DIR}/../src/drivers
    ${CMAKE_SOURCE_DIR}/mocks
)

# Find GoogleTest
find_package(GTest REQUIRED)
include(GoogleTest)

# Source files to test (native-compatible versions)
set(TEST_SOURCES
    ../src/main.c
    mocks/mock_hal.c
    mocks/mock_gpio.c
    mocks/mock_system.c
    mocks/mock_led.c
)

# Test files
set(UNIT_TEST_SOURCES
    unit/test_led_logic.cpp
    unit/test_gpio_abstraction.cpp
    unit/test_system_logic.cpp
    unit/test_main_logic.cpp
)

# Create test executable
add_executable(UnitTestRunner
    ${TEST_SOURCES}
    ${UNIT_TEST_SOURCES}
)

# Link GoogleTest
target_link_libraries(UnitTestRunner
    GTest::gtest
    GTest::gtest_main
    pthread
)

# Discover tests
gtest_discover_tests(UnitTestRunner)

# Set output directory
set_target_properties(UnitTestRunner PROPERTIES
    RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/bin
)

# Enable testing
enable_testing()