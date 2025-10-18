#!/bin/bash
# Container Health Check Script
# Monitors container performance and resource usage

set -e

echo "=== Container Health Check ==="
echo "Timestamp: $(date)"
echo

# System Information
echo "--- System Information ---"
echo "OS: $(cat /etc/os-release | grep PRETTY_NAME | cut -d'"' -f2)"
echo "Kernel: $(uname -r)"
echo "Architecture: $(uname -m)"
echo

# CPU Information
echo "--- CPU Information ---"
echo "CPU Cores: $(nproc)"
echo "CPU Model: $(cat /proc/cpuinfo | grep 'model name' | head -1 | cut -d':' -f2 | xargs)"
echo "Load Average: $(cat /proc/loadavg)"
echo

# Memory Information
echo "--- Memory Information ---"
echo "Total Memory: $(free -h | grep Mem | awk '{print $2}')"
echo "Available Memory: $(free -h | grep Mem | awk '{print $7}')"
echo "Memory Usage: $(free | grep Mem | awk '{printf "%.1f%%", $3/$2 * 100.0}')"
echo

# Disk Information
echo "--- Disk Information ---"
echo "Workspace Disk Usage:"
df -h /workspace 2>/dev/null || echo "Workspace not mounted"
echo "Temp Disk Usage:"
df -h /tmp
echo

# Development Tools Verification
echo "--- Development Tools ---"
echo "GCC Version: $(gcc --version | head -1)"
echo "Clang Version: $(clang --version | head -1)"
echo "CMake Version: $(cmake --version | head -1)"
echo "Ninja Version: $(ninja --version)"
echo "GDB Version: $(gdb --version | head -1)"
echo

# Network Connectivity
echo "--- Network Connectivity ---"
if ping -c 1 github.com &> /dev/null; then
    echo "GitHub: ✓ Reachable"
else
    echo "GitHub: ✗ Not reachable"
fi

if ping -c 1 8.8.8.8 &> /dev/null; then
    echo "Internet: ✓ Connected"
else
    echo "Internet: ✗ Not connected"
fi
echo

# Build Performance Test
echo "--- Build Performance Test ---"
if [ -f "/workspace/CMakeLists.txt" ]; then
    echo "Running quick build test..."
    cd /workspace
    
    # Clean previous builds
    rm -rf build-test
    
    # Time the build process
    echo "Configuring..."
    time_start=$(date +%s.%N)
    cmake -S . -B build-test -G Ninja > /dev/null 2>&1
    time_config=$(date +%s.%N)
    
    echo "Building..."
    cmake --build build-test --parallel $(nproc) > /dev/null 2>&1
    time_build=$(date +%s.%N)
    
    # Calculate times
    config_time=$(echo "$time_config - $time_start" | bc -l)
    build_time=$(echo "$time_build - $time_config" | bc -l)
    total_time=$(echo "$time_build - $time_start" | bc -l)
    
    printf "Configure Time: %.2fs\n" $config_time
    printf "Build Time: %.2fs\n" $build_time
    printf "Total Time: %.2fs\n" $total_time
    
    # Clean up
    rm -rf build-test
else
    echo "No CMakeLists.txt found - skipping build test"
fi

echo
echo "=== Health Check Complete ==="