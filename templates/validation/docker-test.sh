#!/bin/bash
# Docker Environment Test Script

set -e

PROJECT_NAME="${1:-basic-cpp}"
OUTPUT_DIR="templates/validation/test-results"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log() {
    local level="$1"
    local message="$2"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    local color=""
    
    case "$level" in
        "ERROR") color="$RED" ;;
        "PASS") color="$GREEN" ;;
        "FAIL") color="$RED" ;;
        "SKIP") color="$YELLOW" ;;
        "INFO") color="$BLUE" ;;
        *) color="$NC" ;;
    esac
    
    echo -e "${color}[$timestamp] [$level] $message${NC}"
}

# Test results
TOTAL_TESTS=0
PASSED_TESTS=0
FAILED_TESTS=0

test_docker_environment() {
    log "INFO" "=== Docker Environment Test Started ==="
    log "INFO" "Testing project: $PROJECT_NAME"
    
    # Check if we're running in a container
    if [ -f /.dockerenv ]; then
        log "INFO" "Running inside Docker container"
    else
        log "INFO" "Running on host system (not in container)"
    fi
    
    # Environment information
    log "INFO" "OS: $(uname -s) $(uname -r)"
    log "INFO" "Architecture: $(uname -m)"
    log "INFO" "User: $(whoami)"
    log "INFO" "Working directory: $(pwd)"
    
    # Check required tools
    TOTAL_TESTS=$((TOTAL_TESTS + 1))
    if command -v cmake >/dev/null 2>&1; then
        log "PASS" "CMake available: $(cmake --version | head -1)"
        PASSED_TESTS=$((PASSED_TESTS + 1))
    else
        log "FAIL" "CMake not found"
        FAILED_TESTS=$((FAILED_TESTS + 1))
    fi
    
    TOTAL_TESTS=$((TOTAL_TESTS + 1))
    if command -v ninja >/dev/null 2>&1; then
        log "PASS" "Ninja available: $(ninja --version)"
        PASSED_TESTS=$((PASSED_TESTS + 1))
    else
        log "FAIL" "Ninja not found"
        FAILED_TESTS=$((FAILED_TESTS + 1))
    fi
    
    TOTAL_TESTS=$((TOTAL_TESTS + 1))
    if command -v gcc >/dev/null 2>&1; then
        log "PASS" "GCC available: $(gcc --version | head -1)"
        PASSED_TESTS=$((PASSED_TESTS + 1))
    else
        log "FAIL" "GCC not found"
        FAILED_TESTS=$((FAILED_TESTS + 1))
    fi
    
    # Test project build
    PROJECT_PATH="templates/$PROJECT_NAME"
    if [ -d "$PROJECT_PATH" ]; then
        log "INFO" "Testing project build in: $PROJECT_PATH"
        cd "$PROJECT_PATH"
        
        # Clean previous build
        if [ -d "build" ]; then
            rm -rf build
            log "INFO" "Cleaned previous build directory"
        fi
        
        # Configure
        TOTAL_TESTS=$((TOTAL_TESTS + 1))
        if cmake -B build -S . -G Ninja -DCMAKE_BUILD_TYPE=Debug -DCMAKE_EXPORT_COMPILE_COMMANDS=ON; then
            log "PASS" "CMake configure successful"
            PASSED_TESTS=$((PASSED_TESTS + 1))
        else
            log "FAIL" "CMake configure failed"
            FAILED_TESTS=$((FAILED_TESTS + 1))
            return 1
        fi
        
        # Build
        TOTAL_TESTS=$((TOTAL_TESTS + 1))
        if cmake --build build --parallel; then
            log "PASS" "Build successful"
            PASSED_TESTS=$((PASSED_TESTS + 1))
        else
            log "FAIL" "Build failed"
            FAILED_TESTS=$((FAILED_TESTS + 1))
            return 1
        fi
        
        # Find and test executable
        EXECUTABLE_NAMES=("BasicCppProject" "CalculatorProject" "JsonParserProject")
        FOUND_EXEC=""
        
        for name in "${EXECUTABLE_NAMES[@]}"; do
            if [ -f "build/bin/$name" ]; then
                FOUND_EXEC="$name"
                break
            fi
        done
        
        TOTAL_TESTS=$((TOTAL_TESTS + 1))
        if [ -n "$FOUND_EXEC" ]; then
            log "PASS" "Executable found: $FOUND_EXEC"
            PASSED_TESTS=$((PASSED_TESTS + 1))
            
            # Test execution
            TOTAL_TESTS=$((TOTAL_TESTS + 1))
            case "$FOUND_EXEC" in
                "BasicCppProject")
                    if ./build/bin/$FOUND_EXEC "Docker-Test"; then
                        log "PASS" "Application execution successful"
                        PASSED_TESTS=$((PASSED_TESTS + 1))
                    else
                        log "FAIL" "Application execution failed"
                        FAILED_TESTS=$((FAILED_TESTS + 1))
                    fi
                    ;;
                "CalculatorProject")
                    if ./build/bin/$FOUND_EXEC; then
                        log "PASS" "Application execution successful"
                        PASSED_TESTS=$((PASSED_TESTS + 1))
                    else
                        log "FAIL" "Application execution failed"
                        FAILED_TESTS=$((FAILED_TESTS + 1))
                    fi
                    ;;
                "JsonParserProject")
                    if ./build/bin/$FOUND_EXEC --ci; then
                        log "PASS" "Application execution successful"
                        PASSED_TESTS=$((PASSED_TESTS + 1))
                    else
                        log "FAIL" "Application execution failed"
                        FAILED_TESTS=$((FAILED_TESTS + 1))
                    fi
                    ;;
            esac
        else
            log "FAIL" "No executable found in build/bin/"
            FAILED_TESTS=$((FAILED_TESTS + 1))
        fi
        
        # Test compile_commands.json
        TOTAL_TESTS=$((TOTAL_TESTS + 1))
        if [ -f "build/compile_commands.json" ]; then
            log "PASS" "compile_commands.json generated"
            PASSED_TESTS=$((PASSED_TESTS + 1))
        else
            log "FAIL" "compile_commands.json not found"
            FAILED_TESTS=$((FAILED_TESTS + 1))
        fi
        
        cd - >/dev/null
    else
        log "FAIL" "Project directory not found: $PROJECT_PATH"
        FAILED_TESTS=$((FAILED_TESTS + 1))
    fi
}

# Run tests
test_docker_environment

# Results
SUCCESS_RATE=0
if [ $TOTAL_TESTS -gt 0 ]; then
    SUCCESS_RATE=$(echo "scale=2; $PASSED_TESTS * 100 / $TOTAL_TESTS" | bc -l 2>/dev/null || echo "0")
fi

log "INFO" "=== Docker Environment Test Completed ==="
log "INFO" "Total Tests: $TOTAL_TESTS"
log "INFO" "Passed: $PASSED_TESTS"
log "INFO" "Failed: $FAILED_TESTS"
log "INFO" "Success Rate: $SUCCESS_RATE%"

# Generate report
mkdir -p "$OUTPUT_DIR"
cat > "$OUTPUT_DIR/docker-test-report.txt" << EOF
Docker Environment Test Report
==============================
Generated: $(date)
Project: $PROJECT_NAME
Environment: $(uname -s) $(uname -r)
Container: $([ -f /.dockerenv ] && echo "Yes" || echo "No")

Summary:
Total Tests: $TOTAL_TESTS
Passed: $PASSED_TESTS
Failed: $FAILED_TESTS
Success Rate: $SUCCESS_RATE%

Tools:
CMake: $(cmake --version 2>/dev/null | head -1 || echo "Not found")
Ninja: $(ninja --version 2>/dev/null || echo "Not found")
GCC: $(gcc --version 2>/dev/null | head -1 || echo "Not found")
EOF

if [ $FAILED_TESTS -eq 0 ]; then
    log "PASS" "All Docker environment tests passed!"
    exit 0
else
    log "FAIL" "Some Docker environment tests failed!"
    exit 1
fi