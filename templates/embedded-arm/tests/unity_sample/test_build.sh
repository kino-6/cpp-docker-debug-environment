#!/bin/bash

echo "=== Unity Sample Build Test ==="
echo "Testing Unity framework build with manual verification"
echo

# Clean and build
rm -rf build
mkdir -p build

echo "1. CMake Configuration..."
cmake -B build -S . -G Ninja -DCMAKE_BUILD_TYPE=Debug

if [ $? -ne 0 ]; then
    echo "   ❌ CMake configuration failed"
    exit 1
fi
echo "   ✓ CMake configuration successful"

echo "2. Building Unity sample..."
cmake --build build --parallel

if [ $? -ne 0 ]; then
    echo "   ❌ Build failed"
    exit 1
fi
echo "   ✓ Build successful"

echo "3. Checking build output..."
if [ -f build/bin/UnityTestRunner ]; then
    echo "   ✓ UnityTestRunner executable created"
    ls -la build/bin/UnityTestRunner
else
    echo "   ❌ UnityTestRunner executable not found"
    exit 1
fi

echo "4. Running Unity tests..."
./build/bin/UnityTestRunner

UNITY_EXIT_CODE=$?
echo "Unity test exit code: $UNITY_EXIT_CODE"

if [ $UNITY_EXIT_CODE -eq 0 ]; then
    echo "   ✅ SUCCESS: Unity sample works correctly"
else
    echo "   ❌ ISSUE: Unity tests failed"
fi

echo
echo "=== Unity Sample Build Test Complete ==="