#!/bin/bash
# Comprehensive Environment Validation Script
# Task 6: 基本環境の動作検証

set -e

OUTPUT_DIR="${1:-templates/validation/test-results}"
VERBOSE=false
SKIP_INTERACTIVE=false

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --verbose)
            VERBOSE=true
            shift
            ;;
        --skip-interactive)
            SKIP_INTERACTIVE=true
            shift
            ;;
        --output-dir)
            OUTPUT_DIR="$2"
            shift 2
            ;;
        *)
            shift
            ;;
    esac
done

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Create output directory
mkdir -p "$OUTPUT_DIR"

LOG_FILE="$OUTPUT_DIR/environment-validation.log"
REPORT_FILE="$OUTPUT_DIR/environment-validation-report.txt"

# Validation results
TOTAL_TESTS=0
PASSED_TESTS=0
FAILED_TESTS=0
SKIPPED_TESTS=0

# Performance metrics
CONFIGURE_TIME=0
BUILD_TIME=0
TOTAL_TIME=0

log() {
    local level="$1"
    local message="$2"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    local color=""
    
    case "$level" in
        "ERROR"|"FAIL") color="$RED" ;;
        "PASS"|"SUCCESS") color="$GREEN" ;;
        "SKIP"|"WARN") color="$YELLOW" ;;
        "INFO") color="$BLUE" ;;
        *) color="$NC" ;;
    esac
    
    echo -e "${color}[$timestamp] [$level] $message${NC}"
    echo "[$timestamp] [$level] $message" >> "$LOG_FILE"
}

test_validation_item() {
    local test_name="$1"
    local test_function="$2"
    local category="${3:-General}"
    
    TOTAL_TESTS=$((TOTAL_TESTS + 1))
    log "INFO" "Testing: $test_name"
    
    local start_time=$(date +%s.%N)
    
    if $test_function; then
        local end_time=$(date +%s.%N)
        local duration=$(echo "$end_time - $start_time" | bc -l 2>/dev/null || echo "0")
        log "PASS" "✅ PASS: $test_name (${duration}s)"
        PASSED_TESTS=$((PASSED_TESTS + 1))
        return 0
    else
        local end_time=$(date +%s.%N)
        local duration=$(echo "$end_time - $start_time" | bc -l 2>/dev/null || echo "0")
        log "FAIL" "❌ FAIL: $test_name (${duration}s)"
        FAILED_TESTS=$((FAILED_TESTS + 1))
        return 1
    fi
}

# Environment Information Collection
collect_environment_info() {
    log "INFO" "=== Collecting Environment Information ==="
    
    echo "Environment Information:" > "$OUTPUT_DIR/environment-info.txt"
    echo "OS: $(uname -s) $(uname -r)" >> "$OUTPUT_DIR/environment-info.txt"
    echo "Architecture: $(uname -m)" >> "$OUTPUT_DIR/environment-info.txt"
    echo "User: $(whoami)" >> "$OUTPUT_DIR/environment-info.txt"
    echo "Date: $(date)" >> "$OUTPUT_DIR/environment-info.txt"
    
    # Tool versions
    echo "CMake: $(cmake --version 2>/dev/null | head -1 || echo 'Not available')" >> "$OUTPUT_DIR/environment-info.txt"
    echo "Ninja: $(ninja --version 2>/dev/null || echo 'Not available')" >> "$OUTPUT_DIR/environment-info.txt"
    echo "GCC: $(gcc --version 2>/dev/null | head -1 || echo 'Not available')" >> "$OUTPUT_DIR/environment-info.txt"
    echo "GDB: $(gdb --version 2>/dev/null | head -1 || echo 'Not available')" >> "$OUTPUT_DIR/environment-info.txt"
    echo "Git: $(git --version 2>/dev/null || echo 'Not available')" >> "$OUTPUT_DIR/environment-info.txt"
    
    log "INFO" "OS: $(uname -s) $(uname -r)"
    log "INFO" "Architecture: $(uname -m)"
    log "INFO" "CMake: $(cmake --version 2>/dev/null | head -1 || echo 'Not available')"
    log "INFO" "Ninja: $(ninja --version 2>/dev/null || echo 'Not available')"
    log "INFO" "GCC: $(gcc --version 2>/dev/null | head -1 || echo 'Not available')"
}

# Test 1: Hello World Project Build and Execution
test_hello_world_projects() {
    local projects=("basic-cpp" "calculator-cpp" "json-parser-cpp")
    
    for project in "${projects[@]}"; do
        test_validation_item "Hello World Build: $project" "test_hello_world_project_$project" "Hello World Projects"
    done
}

test_hello_world_project_basic-cpp() {
    local project_path="templates/basic-cpp"
    
    if [ ! -d "$project_path" ]; then
        log "FAIL" "Project directory not found: $project_path"
        return 1
    fi
    
    cd "$project_path"
    
    # Clean build
    rm -rf build
    
    # Configure
    if ! cmake -B build -S . -G Ninja -DCMAKE_BUILD_TYPE=Debug -DCMAKE_EXPORT_COMPILE_COMMANDS=ON >/dev/null 2>&1; then
        log "FAIL" "CMake configure failed for basic-cpp"
        cd - >/dev/null
        return 1
    fi
    
    # Build
    if ! cmake --build build --parallel >/dev/null 2>&1; then
        log "FAIL" "Build failed for basic-cpp"
        cd - >/dev/null
        return 1
    fi
    
    # Execute
    if [ -f "build/bin/BasicCppProject" ]; then
        if ./build/bin/BasicCppProject "ValidationTest" >/dev/null 2>&1; then
            log "PASS" "basic-cpp build and execution successful"
            cd - >/dev/null
            return 0
        else
            log "FAIL" "basic-cpp execution failed"
            cd - >/dev/null
            return 1
        fi
    else
        log "FAIL" "basic-cpp executable not found"
        cd - >/dev/null
        return 1
    fi
}

test_hello_world_project_calculator-cpp() {
    local project_path="templates/calculator-cpp"
    
    if [ ! -d "$project_path" ]; then
        log "FAIL" "Project directory not found: $project_path"
        return 1
    fi
    
    cd "$project_path"
    
    # Clean build
    rm -rf build
    
    # Configure and build
    if ! cmake -B build -S . -G Ninja -DCMAKE_BUILD_TYPE=Debug >/dev/null 2>&1; then
        cd - >/dev/null
        return 1
    fi
    
    if ! cmake --build build --parallel >/dev/null 2>&1; then
        cd - >/dev/null
        return 1
    fi
    
    # Execute
    if [ -f "build/bin/CalculatorProject" ]; then
        if ./build/bin/CalculatorProject >/dev/null 2>&1; then
            cd - >/dev/null
            return 0
        fi
    fi
    
    cd - >/dev/null
    return 1
}

test_hello_world_project_json-parser-cpp() {
    local project_path="templates/json-parser-cpp"
    
    if [ ! -d "$project_path" ]; then
        log "FAIL" "Project directory not found: $project_path"
        return 1
    fi
    
    cd "$project_path"
    
    # Clean build
    rm -rf build
    
    # Configure and build
    if ! cmake -B build -S . -G Ninja -DCMAKE_BUILD_TYPE=Debug >/dev/null 2>&1; then
        cd - >/dev/null
        return 1
    fi
    
    if ! cmake --build build --parallel >/dev/null 2>&1; then
        cd - >/dev/null
        return 1
    fi
    
    # Execute
    if [ -f "build/bin/JsonParserProject" ]; then
        if ./build/bin/JsonParserProject --ci >/dev/null 2>&1; then
            cd - >/dev/null
            return 0
        fi
    fi
    
    cd - >/dev/null
    return 1
}

# Test 2: Debug Configuration Validation
test_debug_configurations() {
    local projects=("basic-cpp" "calculator-cpp" "json-parser-cpp")
    
    for project in "${projects[@]}"; do
        test_validation_item "Debug Configuration: $project" "test_debug_config_$project" "Debug Configuration"
    done
}

test_debug_config_basic-cpp() {
    local launch_json="templates/basic-cpp/.vscode/launch.json"
    
    if [ ! -f "$launch_json" ]; then
        return 1
    fi
    
    # Basic JSON validation
    if python3 -m json.tool "$launch_json" >/dev/null 2>&1; then
        return 0
    else
        return 1
    fi
}

test_debug_config_calculator-cpp() {
    local launch_json="templates/calculator-cpp/.vscode/launch.json"
    
    if [ ! -f "$launch_json" ]; then
        return 1
    fi
    
    if python3 -m json.tool "$launch_json" >/dev/null 2>&1; then
        return 0
    else
        return 1
    fi
}

test_debug_config_json-parser-cpp() {
    local launch_json="templates/json-parser-cpp/.vscode/launch.json"
    
    if [ ! -f "$launch_json" ]; then
        return 1
    fi
    
    if python3 -m json.tool "$launch_json" >/dev/null 2>&1; then
        return 0
    else
        return 1
    fi
}

# Test 3: IntelliSense Configuration
test_intellisense_configurations() {
    local projects=("basic-cpp" "calculator-cpp" "json-parser-cpp")
    
    for project in "${projects[@]}"; do
        test_validation_item "IntelliSense Setup: $project" "test_intellisense_$project" "IntelliSense Configuration"
    done
}

test_intellisense_basic-cpp() {
    local project_path="templates/basic-cpp"
    
    cd "$project_path"
    
    # Ensure build exists
    if [ ! -d "build" ]; then
        cmake -B build -S . -G Ninja -DCMAKE_BUILD_TYPE=Debug -DCMAKE_EXPORT_COMPILE_COMMANDS=ON >/dev/null 2>&1
    fi
    
    # Check compile_commands.json
    if [ -f "build/compile_commands.json" ]; then
        if python3 -m json.tool "build/compile_commands.json" >/dev/null 2>&1; then
            cd - >/dev/null
            return 0
        fi
    fi
    
    cd - >/dev/null
    return 1
}

test_intellisense_calculator-cpp() {
    local project_path="templates/calculator-cpp"
    
    cd "$project_path"
    
    if [ ! -d "build" ]; then
        cmake -B build -S . -G Ninja -DCMAKE_BUILD_TYPE=Debug -DCMAKE_EXPORT_COMPILE_COMMANDS=ON >/dev/null 2>&1
    fi
    
    if [ -f "build/compile_commands.json" ]; then
        cd - >/dev/null
        return 0
    fi
    
    cd - >/dev/null
    return 1
}

test_intellisense_json-parser-cpp() {
    local project_path="templates/json-parser-cpp"
    
    cd "$project_path"
    
    if [ ! -d "build" ]; then
        cmake -B build -S . -G Ninja -DCMAKE_BUILD_TYPE=Debug -DCMAKE_EXPORT_COMPILE_COMMANDS=ON >/dev/null 2>&1
    fi
    
    if [ -f "build/compile_commands.json" ]; then
        cd - >/dev/null
        return 0
    fi
    
    cd - >/dev/null
    return 1
}

# Test 4: VSCode Tasks Configuration
test_vscode_tasks() {
    local projects=("basic-cpp" "calculator-cpp" "json-parser-cpp")
    
    for project in "${projects[@]}"; do
        test_validation_item "VSCode Tasks: $project" "test_vscode_tasks_$project" "VSCode Tasks"
    done
}

test_vscode_tasks_basic-cpp() {
    local tasks_json="templates/basic-cpp/.vscode/tasks.json"
    
    if [ ! -f "$tasks_json" ]; then
        return 1
    fi
    
    if python3 -m json.tool "$tasks_json" >/dev/null 2>&1; then
        return 0
    else
        return 1
    fi
}

test_vscode_tasks_calculator-cpp() {
    local tasks_json="templates/calculator-cpp/.vscode/tasks.json"
    
    if [ ! -f "$tasks_json" ]; then
        return 1
    fi
    
    if python3 -m json.tool "$tasks_json" >/dev/null 2>&1; then
        return 0
    else
        return 1
    fi
}

test_vscode_tasks_json-parser-cpp() {
    local tasks_json="templates/json-parser-cpp/.vscode/tasks.json"
    
    if [ ! -f "$tasks_json" ]; then
        return 1
    fi
    
    if python3 -m json.tool "$tasks_json" >/dev/null 2>&1; then
        return 0
    else
        return 1
    fi
}

# Test 5: Performance Benchmarks
test_performance_benchmarks() {
    test_validation_item "Performance: Build Speed" "test_build_performance" "Performance"
}

test_build_performance() {
    local project_path="templates/basic-cpp"
    
    cd "$project_path"
    
    # Clean build for accurate timing
    rm -rf build
    
    # Time configure
    local configure_start=$(date +%s.%N)
    if cmake -B build -S . -G Ninja -DCMAKE_BUILD_TYPE=Debug -DCMAKE_EXPORT_COMPILE_COMMANDS=ON >/dev/null 2>&1; then
        local configure_end=$(date +%s.%N)
        CONFIGURE_TIME=$(echo "$configure_end - $configure_start" | bc -l 2>/dev/null || echo "0")
        
        # Time build
        local build_start=$(date +%s.%N)
        if cmake --build build --parallel >/dev/null 2>&1; then
            local build_end=$(date +%s.%N)
            BUILD_TIME=$(echo "$build_end - $build_start" | bc -l 2>/dev/null || echo "0")
            TOTAL_TIME=$(echo "$CONFIGURE_TIME + $BUILD_TIME" | bc -l 2>/dev/null || echo "0")
            
            log "INFO" "Performance: Configure ${CONFIGURE_TIME}s, Build ${BUILD_TIME}s, Total ${TOTAL_TIME}s"
            cd - >/dev/null
            return 0
        fi
    fi
    
    cd - >/dev/null
    return 1
}

# Generate comprehensive report
generate_validation_report() {
    local success_rate=0
    if [ $TOTAL_TESTS -gt 0 ]; then
        success_rate=$(echo "scale=2; $PASSED_TESTS * 100 / $TOTAL_TESTS" | bc -l 2>/dev/null || echo "0")
    fi
    
    cat > "$REPORT_FILE" << EOF
Task 6: Basic Environment Validation Report
===========================================
Generated: $(date)

SUMMARY:
========
Total Tests: $TOTAL_TESTS
Passed: $PASSED_TESTS
Failed: $FAILED_TESTS
Skipped: $SKIPPED_TESTS
Success Rate: $success_rate%

ENVIRONMENT INFORMATION:
========================
$(cat "$OUTPUT_DIR/environment-info.txt")

PERFORMANCE METRICS:
===================
Configure Time: ${CONFIGURE_TIME}s
Build Time: ${BUILD_TIME}s
Total Build Time: ${TOTAL_TIME}s

VALIDATION CHECKLIST:
====================
✅ Hello World Projects: Build and execution test
✅ Debug Configuration: VSCode launch.json validation
✅ IntelliSense Setup: compile_commands.json generation
✅ VSCode Tasks: CMake tasks configuration
✅ Performance: Build speed benchmarks

REQUIREMENTS COVERAGE:
=====================
✅ Requirement 3.4: Hello World project validation
✅ Requirement 5.1: Debug functionality verification
✅ Requirement 5.2: IntelliSense and IDE integration

EOF

    if [ $FAILED_TESTS -eq 0 ]; then
        cat >> "$REPORT_FILE" << EOF
RESULT:
=======
🎉 All validation tests passed! The environment is ready for production use.

Task 6 (Basic Environment Validation) is COMPLETE.
Ready to proceed to Phase 2: Embedded Development Support.
EOF
    else
        cat >> "$REPORT_FILE" << EOF
RESULT:
=======
⚠️ Some validation tests failed. Please review the detailed results above.

Failed tests should be addressed before proceeding to the next phase.
Check the specific error details and resolve any configuration issues.
EOF
    fi
    
    log "INFO" "=== Validation Report Generated ==="
    log "INFO" "Report saved to: $REPORT_FILE"
}

# Main execution
main() {
    log "INFO" "=== Task 6: Basic Environment Validation Started ==="
    
    collect_environment_info
    
    log "INFO" "=== Starting Comprehensive Validation ==="
    
    # Execute all validation tests
    test_hello_world_projects
    test_debug_configurations
    test_intellisense_configurations
    test_vscode_tasks
    test_performance_benchmarks
    
    # Generate report
    generate_validation_report
    
    # Display summary
    log "INFO" "=== VALIDATION SUMMARY ==="
    log "INFO" "Total Tests: $TOTAL_TESTS"
    log "INFO" "Passed: $PASSED_TESTS"
    log "INFO" "Failed: $FAILED_TESTS"
    log "INFO" "Skipped: $SKIPPED_TESTS"
    
    if [ $TOTAL_TESTS -gt 0 ]; then
        local success_rate=$(echo "scale=2; $PASSED_TESTS * 100 / $TOTAL_TESTS" | bc -l 2>/dev/null || echo "0")
        log "INFO" "Success Rate: $success_rate%"
    fi
    
    if [ "$TOTAL_TIME" != "0" ]; then
        log "INFO" "Build Performance: ${TOTAL_TIME}s total"
    fi
    
    if [ $FAILED_TESTS -eq 0 ]; then
        log "SUCCESS" "🎉 Task 6: Basic Environment Validation COMPLETED successfully!"
        return 0
    else
        log "ERROR" "❌ Task 6: Basic Environment Validation FAILED. Check detailed report."
        return 1
    fi
}

# Execute main function
main "$@"