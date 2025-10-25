#!/bin/bash

echo "=== Simple Google Test Build ==="
echo "Testing basic Google Test setup with minimal configuration"
echo

# Navigate to tests directory
cd tests

echo "1. Cleaning previous build..."
rm -rf build
echo "   ✓ Build directory cleaned"

echo "2. Creating minimal test configuration..."
# Create a minimal CMakeLists.txt for testing
cat > CMakeLists_minimal.txt << 'EOF'
# Minimal GoogleTest Configuration
cmake_minimum_required(VERSION 3.16)

# Project
project(MinimalGoogleTest VERSION 1.0.0 LANGUAGES C CXX)

# Compiler settings
set(CMAKE_C_STANDARD 17)
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# Find or fetch GoogleTest
include(FetchContent)
FetchContent_Declare(
    googletest
    GIT_REPOSITORY https://github.com/google/googletest.git
    GIT_TAG        v1.14.0
)

set(gtest_force_shared_crt ON CACHE BOOL "" FORCE)
set(BUILD_GMOCK OFF CACHE BOOL "" FORCE)
set(INSTALL_GTEST OFF CACHE BOOL "" FORCE)
FetchContent_MakeAvailable(googletest)

# Include GoogleTest utilities
include(GoogleTest)

# Include directories
include_directories(
    utils
)

# Simple test executable (basic test without dependencies)
add_executable(MinimalTestRunner
    simple_test.cpp
)

# Link GoogleTest (without GMock)
target_link_libraries(MinimalTestRunner
    gtest
    gtest_main
    pthread
)

# Discover tests
gtest_discover_tests(MinimalTestRunner)

# Enable testing
enable_testing()
EOF

echo "3. Configuring minimal CMake..."
# Backup original CMakeLists.txt and use minimal version
cp CMakeLists.txt CMakeLists_backup.txt
cp CMakeLists_minimal.txt CMakeLists.txt

echo "Command: cmake -B build -S . -G Ninja"
echo "----------------------------------------"

CC=/usr/bin/cc CXX=/usr/bin/c++ \
cmake -B build -S . -G Ninja \
    -DCMAKE_C_COMPILER=/usr/bin/cc \
    -DCMAKE_CXX_COMPILER=/usr/bin/c++

CMAKE_EXIT_CODE=$?
echo "----------------------------------------"
echo "CMake configuration exit code: $CMAKE_EXIT_CODE"

if [ $CMAKE_EXIT_CODE -ne 0 ]; then
    echo "   ❌ Minimal CMake configuration failed"
    echo "   Restoring original CMakeLists.txt..."
    
    # Restore original CMakeLists.txt
    cp CMakeLists_backup.txt CMakeLists.txt
    
    CC=/usr/bin/cc CXX=/usr/bin/c++ \
    cmake -B build -S . -G Ninja \
        -DCMAKE_C_COMPILER=/usr/bin/cc \
        -DCMAKE_CXX_COMPILER=/usr/bin/c++
    
    CMAKE_EXIT_CODE=$?
    if [ $CMAKE_EXIT_CODE -ne 0 ]; then
        echo "   ❌ Original CMake configuration also failed"
        exit 1
    fi
else
    echo "   ✓ Minimal CMake configuration successful"
fi

echo "   ✓ CMake configuration successful"

echo "4. Building Google Test..."
echo "Command: cmake --build build --parallel"
echo "----------------------------------------"

cmake --build build --parallel

BUILD_EXIT_CODE=$?
echo "----------------------------------------"
echo "Build exit code: $BUILD_EXIT_CODE"

if [ $BUILD_EXIT_CODE -ne 0 ]; then
    echo "   ❌ Build failed"
    echo "   Checking for specific errors..."
    
    # Try building just GoogleTest
    echo "   Trying to build just GoogleTest..."
    cmake --build build --target gtest
    
    GTEST_BUILD_EXIT_CODE=$?
    if [ $GTEST_BUILD_EXIT_CODE -eq 0 ]; then
        echo "   ✓ GoogleTest built successfully"
        echo "   Issue is with our test code"
    else
        echo "   ❌ GoogleTest build also failed"
    fi
    
    exit 1
fi

echo "   ✓ Build successful"

echo "5. Listing generated executables..."
echo "Build output:"
ls -la build/bin/ 2>/dev/null || echo "No executables in build/bin/"
find build -name "*TestRunner*" -type f 2>/dev/null || echo "No TestRunner executables found"

echo
echo "6. Testing Google Test integration..."
if [ -f build/MinimalTestRunner ]; then
    echo "Running minimal test..."
    echo "----------------------------------------"
    
    timeout 30s ./build/MinimalTestRunner --gtest_brief=1
    
    TEST_EXIT_CODE=$?
    echo "----------------------------------------"
    echo "Test exit code: $TEST_EXIT_CODE"
    
    if [ $TEST_EXIT_CODE -eq 0 ]; then
        echo "   ✅ Minimal tests passed"
    else
        echo "   ⚠️  Tests had issues (exit code: $TEST_EXIT_CODE)"
    fi
else
    echo "   ❌ MinimalTestRunner not found"
    echo "   Available executables:"
    find build -name "*" -type f -executable 2>/dev/null | head -10
fi

echo
echo "=== Simple Google Test Build Summary ==="
echo "CMake configuration: $([ $CMAKE_EXIT_CODE -eq 0 ] && echo "✅ SUCCESS" || echo "❌ FAILED")"
echo "Build process:       $([ $BUILD_EXIT_CODE -eq 0 ] && echo "✅ SUCCESS" || echo "❌ FAILED")"

if [ -f build/MinimalTestRunner ]; then
    echo "Test execution:      $([ $TEST_EXIT_CODE -eq 0 ] && echo "✅ PASSED" || echo "⚠️  ISSUES")"
fi

echo
# Restore original CMakeLists.txt if it was backed up
if [ -f CMakeLists_backup.txt ]; then
    cp CMakeLists_backup.txt CMakeLists.txt
    rm CMakeLists_backup.txt
fi

if [ $CMAKE_EXIT_CODE -eq 0 ] && [ $BUILD_EXIT_CODE -eq 0 ]; then
    echo "🎉 Simple Google Test setup completed successfully!"
    echo "   Ready to proceed with full test suite"
else
    echo "⚠️  Simple Google Test setup completed with issues"
    echo "   Check configuration and dependencies"
fi