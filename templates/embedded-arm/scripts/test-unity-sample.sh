#!/bin/bash

echo "=== Unity/CMock Sample Test ==="
echo "Testing Unity framework with LED control sample"
echo

# Navigate to Unity sample directory
cd tests/unity_sample

echo "1. Building Unity/CMock sample..."
rm -rf build
mkdir -p build
cmake -B build -S . -G Ninja -DCMAKE_BUILD_TYPE=Debug

if [ $? -ne 0 ]; then
    echo "   ❌ CMake configuration failed"
    exit 1
fi
echo "   ✓ CMake configuration successful"

cmake --build build --parallel

if [ $? -ne 0 ]; then
    echo "   ❌ Build failed"
    exit 1
fi
echo "   ✓ Build successful"

echo "2. Analyzing Unity test binary..."
echo "Binary size:"
ls -la build/bin/UnityTestRunner
echo

echo "3. Running Unity tests..."
echo "Command: ./build/bin/UnityTestRunner"
echo "----------------------------------------"

./build/bin/UnityTestRunner

UNITY_EXIT_CODE=$?
echo "----------------------------------------"
echo "Unity test exit code: $UNITY_EXIT_CODE"

echo
echo "=== Unity/CMock Sample Test Summary ==="
echo "Unity test execution: Exit code $UNITY_EXIT_CODE"
echo
echo "This sample demonstrates:"
echo "- Unity test framework for C language"
echo "- Manual mock implementation (simpler than CMock)"
echo "- LED control logic testing"
echo "- Embedded-style test structure"
echo "- Minimal dependencies approach"
echo
if [ $UNITY_EXIT_CODE -eq 0 ]; then
    echo "✅ SUCCESS: Unity/CMock sample works correctly"
    echo "   LED control tests passed"
    echo "   Mock expectations verified"
    echo "   Unity framework integration confirmed"
else
    echo "❌ ISSUE: Unity tests failed"
    echo "   Check test implementation or mock setup"
fi

echo
echo "🎯 LEARNING POINTS:"
echo "1. Unity uses simple C macros for assertions"
echo "2. Manual mocks provide fine-grained control"
echo "3. Lightweight framework suitable for embedded systems"
echo "4. Different approach compared to Google Test"
echo "5. No complex dependencies - easy to integrate"
echo
echo "📚 For production use, consider the main Google Test environment"
echo "   which provides more features and VSCode integration."