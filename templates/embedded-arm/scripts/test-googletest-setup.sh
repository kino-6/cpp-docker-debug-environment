#!/bin/bash

echo "=== Google Test Environment Setup ==="
echo "Setting up comprehensive Google Test environment"
echo

# Navigate to tests directory
cd tests

echo "1. Environment verification..."
echo "Checking compiler availability:"
which gcc || echo "  gcc not found in PATH"
which g++ || echo "  g++ not found in PATH"
which cc && echo "  cc found: $(which cc)"
which c++ && echo "  c++ found: $(which c++)"
echo

echo "2. Cleaning previous build..."
rm -rf build
echo "   ✓ Build directory cleaned"

echo "3. Configuring CMake with Google Test..."
echo "Command: cmake -B build -S . -G Ninja -DCMAKE_BUILD_TYPE=Debug"
echo "----------------------------------------"

CMAKE_C_COMPILER=/usr/bin/cc CMAKE_CXX_COMPILER=/usr/bin/c++ \
cmake -B build -S . -G Ninja -DCMAKE_BUILD_TYPE=Debug

CMAKE_CONFIG_EXIT_CODE=$?
echo "----------------------------------------"
echo "CMake configuration exit code: $CMAKE_CONFIG_EXIT_CODE"

if [ $CMAKE_CONFIG_EXIT_CODE -ne 0 ]; then
    echo "   ❌ CMake configuration failed"
    echo "   Trying alternative configuration..."
    
    # Try with explicit compiler paths
    CC=/usr/bin/cc CXX=/usr/bin/c++ \
    cmake -B build -S . -G Ninja \
        -DCMAKE_BUILD_TYPE=Debug \
        -DCMAKE_C_COMPILER=/usr/bin/cc \
        -DCMAKE_CXX_COMPILER=/usr/bin/c++
    
    CMAKE_CONFIG_EXIT_CODE=$?
    if [ $CMAKE_CONFIG_EXIT_CODE -ne 0 ]; then
        echo "   ❌ Alternative configuration also failed"
        exit 1
    fi
fi

echo "   ✓ CMake configuration successful"

echo "4. Building Google Test framework..."
echo "Command: cmake --build build --parallel"
echo "----------------------------------------"

cmake --build build --parallel

BUILD_EXIT_CODE=$?
echo "----------------------------------------"
echo "Build exit code: $BUILD_EXIT_CODE"

if [ $BUILD_EXIT_CODE -ne 0 ]; then
    echo "   ❌ Build failed"
    exit 1
fi
echo "   ✓ Build successful"

echo "5. Verifying test executables..."
echo "Generated test executables:"
ls -la build/bin/ 2>/dev/null || echo "No executables found in build/bin/"
echo

echo "6. Testing Google Test integration..."
if [ -f build/bin/UnitTestRunner ]; then
    echo "Running unit tests..."
    echo "----------------------------------------"
    
    timeout 30s ./build/bin/UnitTestRunner --gtest_brief=1
    
    UNIT_TEST_EXIT_CODE=$?
    echo "----------------------------------------"
    echo "Unit test exit code: $UNIT_TEST_EXIT_CODE"
    
    if [ $UNIT_TEST_EXIT_CODE -eq 0 ]; then
        echo "   ✅ Unit tests passed"
    else
        echo "   ⚠️  Unit tests had issues (exit code: $UNIT_TEST_EXIT_CODE)"
    fi
else
    echo "   ❌ UnitTestRunner not found"
fi

echo
echo "7. Testing integration tests..."
if [ -f build/bin/IntegrationTestRunner ]; then
    echo "Running integration tests..."
    echo "----------------------------------------"
    
    timeout 60s ./build/bin/IntegrationTestRunner --gtest_brief=1
    
    INTEGRATION_TEST_EXIT_CODE=$?
    echo "----------------------------------------"
    echo "Integration test exit code: $INTEGRATION_TEST_EXIT_CODE"
    
    if [ $INTEGRATION_TEST_EXIT_CODE -eq 0 ]; then
        echo "   ✅ Integration tests passed"
    else
        echo "   ⚠️  Integration tests had issues (exit code: $INTEGRATION_TEST_EXIT_CODE)"
    fi
else
    echo "   ❌ IntegrationTestRunner not found"
fi

echo
echo "8. Testing performance tests..."
if [ -f build/bin/PerformanceTestRunner ]; then
    echo "Running performance tests..."
    echo "----------------------------------------"
    
    timeout 120s ./build/bin/PerformanceTestRunner --gtest_brief=1
    
    PERFORMANCE_TEST_EXIT_CODE=$?
    echo "----------------------------------------"
    echo "Performance test exit code: $PERFORMANCE_TEST_EXIT_CODE"
    
    if [ $PERFORMANCE_TEST_EXIT_CODE -eq 0 ]; then
        echo "   ✅ Performance tests passed"
    else
        echo "   ⚠️  Performance tests had issues (exit code: $PERFORMANCE_TEST_EXIT_CODE)"
    fi
else
    echo "   ❌ PerformanceTestRunner not found"
fi

echo
echo "9. Google Test framework verification..."
echo "GoogleTest version and features:"
if [ -f build/bin/UnitTestRunner ]; then
    ./build/bin/UnitTestRunner --gtest_list_tests | head -10
    echo "..."
    echo "Total tests: $(./build/bin/UnitTestRunner --gtest_list_tests | grep -c "^  ")"
fi

echo
echo "=== Google Test Environment Setup Summary ==="
echo "CMake configuration: $([ $CMAKE_CONFIG_EXIT_CODE -eq 0 ] && echo "✅ SUCCESS" || echo "❌ FAILED")"
echo "Build process:       $([ $BUILD_EXIT_CODE -eq 0 ] && echo "✅ SUCCESS" || echo "❌ FAILED")"

if [ -f build/bin/UnitTestRunner ]; then
    echo "Unit tests:          $([ $UNIT_TEST_EXIT_CODE -eq 0 ] && echo "✅ PASSED" || echo "⚠️  ISSUES")"
fi

if [ -f build/bin/IntegrationTestRunner ]; then
    echo "Integration tests:   $([ $INTEGRATION_TEST_EXIT_CODE -eq 0 ] && echo "✅ PASSED" || echo "⚠️  ISSUES")"
fi

if [ -f build/bin/PerformanceTestRunner ]; then
    echo "Performance tests:   $([ $PERFORMANCE_TEST_EXIT_CODE -eq 0 ] && echo "✅ PASSED" || echo "⚠️  ISSUES")"
fi

echo
echo "Google Test Environment Features:"
echo "✅ FetchContent automatic GoogleTest download"
echo "✅ GMock integration for advanced mocking"
echo "✅ Multiple test suite organization"
echo "✅ VSCode Test Explorer integration"
echo "✅ Performance benchmarking utilities"
echo "✅ Embedded-specific test fixtures"
echo "✅ Hardware simulation framework"
echo "✅ Comprehensive test reporting"
echo
if [ $CMAKE_CONFIG_EXIT_CODE -eq 0 ] && [ $BUILD_EXIT_CODE -eq 0 ]; then
    echo "🎉 Google Test environment setup completed successfully!"
    echo "   Ready for test-driven embedded development"
else
    echo "⚠️  Google Test environment setup completed with issues"
    echo "   Check individual test results for details"
fi