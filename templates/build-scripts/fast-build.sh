#!/bin/bash
# Fast Build Script for C++ Templates
# This script optimizes build performance using Ninja and parallel compilation

set -e

PROJECT_PATH="."
BUILD_TYPE="RelWithDebInfo"
CLEAN=false
JOBS=0

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -p|--project)
            PROJECT_PATH="$2"
            shift 2
            ;;
        -t|--type)
            BUILD_TYPE="$2"
            shift 2
            ;;
        -c|--clean)
            CLEAN=true
            shift
            ;;
        -j|--jobs)
            JOBS="$2"
            shift 2
            ;;
        -h|--help)
            echo "Usage: $0 [OPTIONS]"
            echo "Options:"
            echo "  -p, --project PATH    Project path (default: .)"
            echo "  -t, --type TYPE       Build type (default: RelWithDebInfo)"
            echo "  -c, --clean           Clean build directory"
            echo "  -j, --jobs N          Number of parallel jobs (default: auto-detect)"
            echo "  -h, --help            Show this help"
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            exit 1
            ;;
    esac
done

# Detect optimal number of CPU cores if not specified
if [ $JOBS -eq 0 ]; then
    PHYSICAL_CORES=$(lscpu | grep "Core(s) per socket" | awk '{print $4}')
    SOCKETS=$(lscpu | grep "Socket(s)" | awk '{print $2}')
    LOGICAL_CORES=$(nproc)
    TOTAL_PHYSICAL=$((PHYSICAL_CORES * SOCKETS))
    
    # Get available memory in GB
    MEMORY_KB=$(grep MemAvailable /proc/meminfo | awk '{print $2}')
    MEMORY_GB=$((MEMORY_KB / 1024 / 1024))
    
    # Optimal thread calculation based on CPU architecture and available memory
    # For compilation, physical cores + some hyperthreading is usually optimal
    # But we need to consider memory constraints (roughly 1GB per thread for C++)
    MEMORY_LIMITED_THREADS=$((MEMORY_GB * 2 / 3))  # Conservative estimate
    CPU_OPTIMAL_THREADS=$((TOTAL_PHYSICAL + TOTAL_PHYSICAL / 2))
    
    if [ $CPU_OPTIMAL_THREADS -gt $LOGICAL_CORES ]; then
        CPU_OPTIMAL_THREADS=$LOGICAL_CORES
    fi
    
    if [ $MEMORY_LIMITED_THREADS -lt $CPU_OPTIMAL_THREADS ]; then
        JOBS=$MEMORY_LIMITED_THREADS
    else
        JOBS=$CPU_OPTIMAL_THREADS
    fi
    
    # Ensure at least 1 thread
    if [ $JOBS -lt 1 ]; then
        JOBS=1
    fi
    
    echo "🔍 System Analysis:"
    echo "  Physical Cores: $TOTAL_PHYSICAL (${PHYSICAL_CORES} per socket × ${SOCKETS} sockets)"
    echo "  Logical Cores: $LOGICAL_CORES"
    echo "  Available Memory: ${MEMORY_GB} GB"
    echo "  Memory-limited threads: $MEMORY_LIMITED_THREADS"
    echo "  CPU-optimal threads: $CPU_OPTIMAL_THREADS"
    echo "✅ Selected optimal thread count: $JOBS"
fi

# Check if Ninja is available
NINJA_AVAILABLE=false
if command -v ninja &> /dev/null; then
    NINJA_AVAILABLE=true
    echo "✓ Ninja build system detected"
else
    echo "⚠ Ninja not found, falling back to default generator"
fi

# Set build directory
BUILD_DIR="$PROJECT_PATH/build"

# Clean build if requested
if [ "$CLEAN" = true ] && [ -d "$BUILD_DIR" ]; then
    echo "🧹 Cleaning build directory..."
    rm -rf "$BUILD_DIR"
fi

# Create build directory
mkdir -p "$BUILD_DIR"

# Configure with optimal settings
echo "⚙️ Configuring project..."
CONFIGURE_ARGS=(
    -S "$PROJECT_PATH"
    -B "$BUILD_DIR"
    -DCMAKE_BUILD_TYPE="$BUILD_TYPE"
    -DCMAKE_EXPORT_COMPILE_COMMANDS=ON
)

if [ "$NINJA_AVAILABLE" = true ]; then
    CONFIGURE_ARGS+=(-G "Ninja")
fi

cmake "${CONFIGURE_ARGS[@]}"

# Build with parallel jobs
echo "🔨 Building project with $JOBS parallel jobs..."
cmake --build "$BUILD_DIR" --config "$BUILD_TYPE" --parallel "$JOBS"

echo "✅ Build completed successfully!"

# Show build artifacts
BIN_DIR="$BUILD_DIR/bin"
if [ -d "$BIN_DIR" ]; then
    echo "📦 Build artifacts:"
    ls -la "$BIN_DIR"
fi