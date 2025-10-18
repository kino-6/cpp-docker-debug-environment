#!/bin/bash
# Integrated Test Runner for C++ Docker Debug Environment
# Usage: ./run-tests.sh [options]
# Examples:
#   ./run-tests.sh                    # Run all tests
#   ./run-tests.sh --quick            # Run quick tests only
#   ./run-tests.sh --docker           # Run Docker tests only
#   ./run-tests.sh --regression       # Run regression tests only
#   ./run-tests.sh --verbose          # Run with verbose output

set -e

# Default values
QUICK=false
DOCKER=false
REGRESSION=false
DEVCONTAINER=false
VERBOSE=false
HELP=false
OUTPUT_DIR="test-results"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --quick)
            QUICK=true
            shift
            ;;
        --docker)
            DOCKER=true
            shift
            ;;
        --regression)
            REGRESSION=true
            shift
            ;;
        --devcontainer)
            DEVCONTAINER=true
            shift
            ;;
        --verbose)
            VERBOSE=true
            shift
            ;;
        --help)
            HELP=true
            shift
            ;;
        --output-dir)
            OUTPUT_DIR="$2"
            shift 2
            ;;
        *)
            echo "Unknown option: $1"
            exit 1
            ;;
    esac
done

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
}

show_help() {
    cat << EOF
C++ Docker Debug Environment - Integrated Test Runner
====================================================

USAGE:
    ./run-tests.sh [OPTIONS]

OPTIONS:
    --quick          Run quick tests only (basic functionality)
    --docker         Run Docker environment tests only
    --regression     Run regression tests only
    --devcontainer   Run Dev Container tests only
    --verbose        Enable verbose output
    --help           Show this help message
    --output-dir     Specify output directory (default: test-results)

EXAMPLES:
    ./run-tests.sh                    # Run all tests
    ./run-tests.sh --quick            # Quick smoke test
    ./run-tests.sh --docker           # Docker environment test
    ./run-tests.sh --regression       # Full regression test
    ./run-tests.sh --verbose          # Verbose output

TEST TYPES:
    Quick Tests     - Basic build and execution tests (~30 seconds)
    Regression      - Full functionality tests (~2 minutes)
    Docker Tests    - Linux environment tests (~1 minute)
    DevContainer    - Dev Container configuration tests (~30 seconds)

OUTPUT:
    All test results are saved to the specified output directory.
    Text reports are generated for easy review.

EOF
}

initialize_test_environment() {
    log "INFO" "Initializing test environment..."
    
    # Create output directory
    mkdir -p "$OUTPUT_DIR"
    log "INFO" "Output directory: $OUTPUT_DIR"
    
    # Clear previous results
    rm -f "$OUTPUT_DIR"/*.log
    rm -f "$OUTPUT_DIR"/*-report.*
    
    # Environment info
    log "INFO" "OS: $(uname -s) $(uname -r)"
    log "INFO" "Architecture: $(uname -m)"
    log "INFO" "User: $(whoami)"
    log "INFO" "Working directory: $(pwd)"
}

test_prerequisites() {
    log "INFO" "Checking prerequisites..."
    
    local prereqs_passed=0
    local prereqs_total=0
    
    # Check CMake
    prereqs_total=$((prereqs_total + 1))
    if command -v cmake >/dev/null 2>&1; then
        log "PASS" "CMake available: $(cmake --version | head -1)"
        prereqs_passed=$((prereqs_passed + 1))
    else
        log "SKIP" "CMake not found"
    fi
    
    # Check Ninja
    prereqs_total=$((prereqs_total + 1))
    if command -v ninja >/dev/null 2>&1; then
        log "PASS" "Ninja available: $(ninja --version)"
        prereqs_passed=$((prereqs_passed + 1))
    else
        log "SKIP" "Ninja not found"
    fi
    
    # Check GCC
    prereqs_total=$((prereqs_total + 1))
    if command -v gcc >/dev/null 2>&1; then
        log "PASS" "GCC available: $(gcc --version | head -1)"
        prereqs_passed=$((prereqs_passed + 1))
    else
        log "SKIP" "GCC not found"
    fi
    
    # Check Docker
    prereqs_total=$((prereqs_total + 1))
    if command -v docker >/dev/null 2>&1; then
        log "PASS" "Docker available: $(docker --version)"
        prereqs_passed=$((prereqs_passed + 1))
    else
        log "SKIP" "Docker not found"
    fi
    
    log "INFO" "Prerequisites: $prereqs_passed/$prereqs_total available"
    return 0
}

run_quick_tests() {
    log "INFO" "=== Running Quick Tests ==="
    
    local start_time=$(date +%s)
    local total_tests=0
    local passed_tests=0
    local failed_tests=0
    
    # Test project structure
    local projects=("basic-cpp" "calculator-cpp" "json-parser-cpp")
    
    for project in "${projects[@]}"; do
        total_tests=$((total_tests + 1))
        if [ -d "templates/$project" ]; then
            log "PASS" "✅ Project structure: $project"
            passed_tests=$((passed_tests + 1))
        else
            log "FAIL" "❌ Project structure: $project"
            failed_tests=$((failed_tests + 1))
        fi
        
        # Check VSCode tasks
        total_tests=$((total_tests + 1))
        if [ -f "templates/$project/.vscode/tasks.json" ]; then
            log "PASS" "✅ VSCode tasks: $project"
            passed_tests=$((passed_tests + 1))
        else
            log "FAIL" "❌ VSCode tasks: $project"
            failed_tests=$((failed_tests + 1))
        fi
    done
    
    # Quick build test
    total_tests=$((total_tests + 1))
    if [ -d "templates/basic-cpp" ]; then
        cd "templates/basic-cpp"
        
        # Clean previous build
        rm -rf build
        
        if cmake -B build -S . -G Ninja -DCMAKE_BUILD_TYPE=Debug >/dev/null 2>&1; then
            if cmake --build build --parallel >/dev/null 2>&1; then
                log "PASS" "✅ Quick build test"
                passed_tests=$((passed_tests + 1))
            else
                log "FAIL" "❌ Quick build test (build failed)"
                failed_tests=$((failed_tests + 1))
            fi
        else
            log "FAIL" "❌ Quick build test (configure failed)"
            failed_tests=$((failed_tests + 1))
        fi
        
        cd - >/dev/null
    else
        log "FAIL" "❌ Quick build test (project not found)"
        failed_tests=$((failed_tests + 1))
    fi
    
    local end_time=$(date +%s)
    local duration=$((end_time - start_time))
    
    echo "Quick Tests: $passed_tests/$total_tests passed (${duration}s)" > "$OUTPUT_DIR/quick-test-summary.txt"
    
    if [ $failed_tests -eq 0 ]; then
        log "SUCCESS" "✅ Quick tests completed successfully ($passed_tests/$total_tests passed)"
        return 0
    else
        log "FAIL" "❌ Quick tests failed ($failed_tests/$total_tests failed)"
        return 1
    fi
}

run_regression_tests() {
    log "INFO" "=== Running Regression Tests ==="
    
    local start_time=$(date +%s)
    local total_tests=0
    local passed_tests=0
    local failed_tests=0
    
    # Test all projects
    local projects=("basic-cpp" "calculator-cpp" "json-parser-cpp")
    
    for project in "${projects[@]}"; do
        log "INFO" "Testing project: $project"
        
        local project_path="templates/$project"
        if [ ! -d "$project_path" ]; then
            log "FAIL" "Project directory not found: $project_path"
            failed_tests=$((failed_tests + 1))
            continue
        fi
        
        cd "$project_path"
        
        # Clean and rebuild
        rm -rf build
        
        # Configure
        total_tests=$((total_tests + 1))
        if cmake -B build -S . -G Ninja -DCMAKE_BUILD_TYPE=Debug -DCMAKE_EXPORT_COMPILE_COMMANDS=ON >/dev/null 2>&1; then
            log "PASS" "✅ CMake configure: $project"
            passed_tests=$((passed_tests + 1))
        else
            log "FAIL" "❌ CMake configure: $project"
            failed_tests=$((failed_tests + 1))
            cd - >/dev/null
            continue
        fi
        
        # Build
        total_tests=$((total_tests + 1))
        if cmake --build build --parallel >/dev/null 2>&1; then
            log "PASS" "✅ Build: $project"
            passed_tests=$((passed_tests + 1))
        else
            log "FAIL" "❌ Build: $project"
            failed_tests=$((failed_tests + 1))
            cd - >/dev/null
            continue
        fi
        
        # Find and test executable
        local executable_names=("BasicCppProject" "CalculatorProject" "JsonParserProject")
        local found_exec=""
        
        for name in "${executable_names[@]}"; do
            if [ -f "build/bin/$name" ]; then
                found_exec="$name"
                break
            fi
        done
        
        total_tests=$((total_tests + 1))
        if [ -n "$found_exec" ]; then
            # Test execution with appropriate arguments
            case "$found_exec" in
                "BasicCppProject")
                    if ./build/bin/$found_exec "RegressionTest" >/dev/null 2>&1; then
                        log "PASS" "✅ Execution: $project"
                        passed_tests=$((passed_tests + 1))
                    else
                        log "FAIL" "❌ Execution: $project"
                        failed_tests=$((failed_tests + 1))
                    fi
                    ;;
                "CalculatorProject")
                    if ./build/bin/$found_exec >/dev/null 2>&1; then
                        log "PASS" "✅ Execution: $project"
                        passed_tests=$((passed_tests + 1))
                    else
                        log "FAIL" "❌ Execution: $project"
                        failed_tests=$((failed_tests + 1))
                    fi
                    ;;
                "JsonParserProject")
                    if ./build/bin/$found_exec --ci >/dev/null 2>&1; then
                        log "PASS" "✅ Execution: $project"
                        passed_tests=$((passed_tests + 1))
                    else
                        log "FAIL" "❌ Execution: $project"
                        failed_tests=$((failed_tests + 1))
                    fi
                    ;;
            esac
        else
            log "FAIL" "❌ Executable not found: $project"
            failed_tests=$((failed_tests + 1))
        fi
        
        cd - >/dev/null
    done
    
    local end_time=$(date +%s)
    local duration=$((end_time - start_time))
    
    echo "Regression Tests: $passed_tests/$total_tests passed (${duration}s)" > "$OUTPUT_DIR/regression-test-summary.txt"
    
    if [ $failed_tests -eq 0 ]; then
        log "SUCCESS" "✅ Regression tests completed successfully ($passed_tests/$total_tests passed, ${duration}s)"
        return 0
    else
        log "FAIL" "❌ Regression tests failed ($failed_tests/$total_tests failed, ${duration}s)"
        return 1
    fi
}

run_docker_tests() {
    log "INFO" "=== Running Docker Tests ==="
    
    local start_time=$(date +%s)
    
    if [ -f "templates/validation/docker-test.sh" ]; then
        if bash templates/validation/docker-test.sh basic-cpp; then
            local end_time=$(date +%s)
            local duration=$((end_time - start_time))
            log "SUCCESS" "✅ Docker tests completed successfully (${duration}s)"
            return 0
        else
            local end_time=$(date +%s)
            local duration=$((end_time - start_time))
            log "FAIL" "❌ Docker tests failed (${duration}s)"
            return 1
        fi
    else
        log "FAIL" "❌ Docker test script not found"
        return 1
    fi
}

generate_summary_report() {
    local quick_result="$1"
    local regression_result="$2"
    local docker_result="$3"
    
    local overall_success=true
    
    if [ "$quick_result" != "0" ] && [ "$quick_result" != "skip" ]; then
        overall_success=false
    fi
    
    if [ "$regression_result" != "0" ] && [ "$regression_result" != "skip" ]; then
        overall_success=false
    fi
    
    if [ "$docker_result" != "0" ] && [ "$docker_result" != "skip" ]; then
        overall_success=false
    fi
    
    local report="C++ Docker Debug Environment - Test Summary Report
==================================================
Generated: $(date)
OS: $(uname -s) $(uname -r)
Architecture: $(uname -m)

Test Results:"
    
    if [ "$quick_result" != "skip" ]; then
        if [ "$quick_result" = "0" ]; then
            report="$report
  Quick Tests: ✅ PASS"
        else
            report="$report
  Quick Tests: ❌ FAIL"
        fi
    fi
    
    if [ "$regression_result" != "skip" ]; then
        if [ "$regression_result" = "0" ]; then
            report="$report
  Regression Tests: ✅ PASS"
        else
            report="$report
  Regression Tests: ❌ FAIL"
        fi
    fi
    
    if [ "$docker_result" != "skip" ]; then
        if [ "$docker_result" = "0" ]; then
            report="$report
  Docker Tests: ✅ PASS"
        else
            report="$report
  Docker Tests: ❌ FAIL"
        fi
    fi
    
    if [ "$overall_success" = true ]; then
        report="$report

Overall Result: ✅ SUCCESS"
    else
        report="$report

Overall Result: ❌ FAILURE"
    fi
    
    report="$report

Detailed reports available in: $OUTPUT_DIR"
    
    echo "$report" > "$OUTPUT_DIR/test-summary.txt"
    echo "$report"
    
    if [ "$overall_success" = true ]; then
        return 0
    else
        return 1
    fi
}

main() {
    if [ "$HELP" = true ]; then
        show_help
        return 0
    fi
    
    log "INFO" "C++ Docker Debug Environment - Integrated Test Runner"
    log "INFO" "====================================================="
    
    initialize_test_environment
    test_prerequisites
    
    # Determine which tests to run
    local run_all=true
    if [ "$QUICK" = true ] || [ "$DOCKER" = true ] || [ "$REGRESSION" = true ]; then
        run_all=false
    fi
    
    local quick_result="skip"
    local regression_result="skip"
    local docker_result="skip"
    
    if [ "$QUICK" = true ] || [ "$run_all" = true ]; then
        if run_quick_tests; then
            quick_result="0"
        else
            quick_result="1"
        fi
    fi
    
    if [ "$REGRESSION" = true ] || [ "$run_all" = true ]; then
        if run_regression_tests; then
            regression_result="0"
        else
            regression_result="1"
        fi
    fi
    
    if [ "$DOCKER" = true ] || [ "$run_all" = true ]; then
        if run_docker_tests; then
            docker_result="0"
        else
            docker_result="1"
        fi
    fi
    
    # Generate summary report
    if generate_summary_report "$quick_result" "$regression_result" "$docker_result"; then
        log "SUCCESS" "🎉 All tests completed successfully!"
        return 0
    else
        log "ERROR" "❌ Some tests failed. Check detailed reports in $OUTPUT_DIR"
        return 1
    fi
}

# Execute main function
main "$@"