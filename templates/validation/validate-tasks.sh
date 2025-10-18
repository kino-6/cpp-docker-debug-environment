#!/bin/bash
# VSCodeタスク設定検証スクリプト
# Bash版 - Linux/macOS環境用

set -e

# パラメータ設定
TEST_PROJECT="${1:-basic-cpp}"
OUTPUT_DIR="${2:-test-results}"

# 色付きログ出力
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# ログ関数
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
    echo "[$timestamp] [$level] $message" >> "$OUTPUT_DIR/validation.log"
}

# テスト結果カウンタ
TOTAL_TESTS=0
PASSED_TESTS=0
FAILED_TESTS=0
ERRORS=()

# テスト実行関数
test_command() {
    local command="$1"
    local test_name="$2"
    
    TOTAL_TESTS=$((TOTAL_TESTS + 1))
    
    log "INFO" "Testing: $test_name"
    
    if eval "$command" >/dev/null 2>&1; then
        log "PASS" "✅ PASS: $test_name"
        PASSED_TESTS=$((PASSED_TESTS + 1))
        return 0
    else
        log "FAIL" "❌ FAIL: $test_name"
        FAILED_TESTS=$((FAILED_TESTS + 1))
        ERRORS+=("$test_name failed")
        return 1
    fi
}

# ファイル存在確認関数
test_file_exists() {
    local file_path="$1"
    local test_name="$2"
    
    TOTAL_TESTS=$((TOTAL_TESTS + 1))
    
    if [ -f "$file_path" ]; then
        log "PASS" "✅ PASS: $test_name - File exists: $file_path"
        PASSED_TESTS=$((PASSED_TESTS + 1))
        return 0
    else
        log "FAIL" "❌ FAIL: $test_name - File not found: $file_path"
        FAILED_TESTS=$((FAILED_TESTS + 1))
        ERRORS+=("$test_name: File not found - $file_path")
        return 1
    fi
}

# 出力ディレクトリの作成
mkdir -p "$OUTPUT_DIR"

log "INFO" "=== VSCode Tasks Validation Started ==="
log "INFO" "Test Project: $TEST_PROJECT"
log "INFO" "Output Directory: $OUTPUT_DIR"

# 環境情報の収集
log "INFO" "=== Environment Information ==="
echo "OS: $(uname -s)" > "$OUTPUT_DIR/environment.txt"
echo "Kernel: $(uname -r)" >> "$OUTPUT_DIR/environment.txt"
echo "Architecture: $(uname -m)" >> "$OUTPUT_DIR/environment.txt"
echo "Date: $(date)" >> "$OUTPUT_DIR/environment.txt"

# 必要なツールの確認
log "INFO" "=== Tool Availability Tests ==="
test_command "cmake --version" "CMake Installation"
test_command "ninja --version" "Ninja Installation"
test_command "gcc --version" "GCC Installation"

# テストプロジェクトディレクトリの確認
PROJECT_PATH="templates/$TEST_PROJECT"
if [ ! -d "$PROJECT_PATH" ]; then
    log "ERROR" "Test project not found: $PROJECT_PATH"
    exit 1
fi

cd "$PROJECT_PATH"

# VSCodeタスク設定ファイルの存在確認
log "INFO" "=== File Existence Tests ==="
test_file_exists ".vscode/tasks.json" "VSCode Tasks Configuration"

# CMake Configure テスト
log "INFO" "=== CMake Configure Test ==="

# 既存のbuildディレクトリをクリーンアップ
if [ -d "build" ]; then
    rm -rf build
    log "INFO" "Cleaned existing build directory"
fi

if test_command "cmake -B build -S . -G Ninja -DCMAKE_BUILD_TYPE=Debug -DCMAKE_EXPORT_COMPILE_COMMANDS=ON" "CMake Configure"; then
    # compile_commands.jsonの生成確認
    test_file_exists "build/compile_commands.json" "compile_commands.json Generation"
    
    # CMakeCache.txtの生成確認
    test_file_exists "build/CMakeCache.txt" "CMakeCache.txt Generation"
fi

# CMake Build テスト
log "INFO" "=== CMake Build Test ==="
if test_command "cmake --build build --config Debug --parallel" "CMake Build"; then
    # 実行ファイルの生成確認
    EXECUTABLE_NAME="$TEST_PROJECT"
    test_file_exists "build/bin/$EXECUTABLE_NAME" "Executable Generation"
    
    # アプリケーション実行テスト
    log "INFO" "=== Application Run Test ==="
    if [ -f "build/bin/$EXECUTABLE_NAME" ]; then
        if test_command "./build/bin/$EXECUTABLE_NAME" "Application Execution"; then
            log "PASS" "Application executed successfully"
        fi
    else
        log "SKIP" "⚠️ SKIP: Application execution test (executable not found)"
    fi
fi

# エラー解析テスト用のファイル準備
log "INFO" "=== Error Analysis Test Setup ==="

ERROR_TEST_SOURCE="../../validation/error-test.cpp"
ERROR_TEST_DEST="src/error-test.cpp"

if [ -f "$ERROR_TEST_SOURCE" ]; then
    cp "$ERROR_TEST_SOURCE" "$ERROR_TEST_DEST"
    log "INFO" "Copied error test file to project"
    
    # CMakeLists.txtにエラーテスト用のターゲットを追加
    ERROR_TARGET_LINE="add_executable(error-test src/error-test.cpp)"
    
    if ! grep -q "$ERROR_TARGET_LINE" CMakeLists.txt; then
        echo "" >> CMakeLists.txt
        echo "# Error test target" >> CMakeLists.txt
        echo "$ERROR_TARGET_LINE" >> CMakeLists.txt
        log "INFO" "Added error test target to CMakeLists.txt"
    fi
    
    # エラービルドテスト（失敗することを期待）
    log "INFO" "=== Error Build Test (Expected to Fail) ==="
    
    if cmake --build build --target error-test 2>"$OUTPUT_DIR/error-build-output.txt"; then
        log "FAIL" "❌ FAIL: Error build test should have failed but passed"
        FAILED_TESTS=$((FAILED_TESTS + 1))
        ERRORS+=("Error build test should have failed but passed")
    else
        log "PASS" "✅ PASS: Error build test correctly failed (as expected)"
        PASSED_TESTS=$((PASSED_TESTS + 1))
        
        # エラー出力の解析
        ERROR_OUTPUT=$(cat "$OUTPUT_DIR/error-build-output.txt")
        
        # 特定のエラーパターンの検出
        EXPECTED_ERRORS=("non_existent_header.h" "undefined_variable" "non_existent_function")
        DETECTED_ERRORS=()
        
        for error in "${EXPECTED_ERRORS[@]}"; do
            if echo "$ERROR_OUTPUT" | grep -q "$error"; then
                DETECTED_ERRORS+=("$error")
                log "PASS" "✅ Detected expected error: $error"
            else
                log "FAIL" "❌ Expected error not detected: $error"
            fi
        done
        
        echo "Expected Errors: ${EXPECTED_ERRORS[*]}" > "$OUTPUT_DIR/error-analysis.txt"
        echo "Detected Errors: ${DETECTED_ERRORS[*]}" >> "$OUTPUT_DIR/error-analysis.txt"
    fi
    
    TOTAL_TESTS=$((TOTAL_TESTS + 1))
else
    log "SKIP" "⚠️ SKIP: Error analysis test (error-test.cpp not found)"
fi

# Clean テスト
log "INFO" "=== CMake Clean Test ==="
test_command "cmake --build build --target clean" "CMake Clean"

# 結果の集計
SUCCESS_RATE=0
if [ $TOTAL_TESTS -gt 0 ]; then
    SUCCESS_RATE=$(echo "scale=2; $PASSED_TESTS * 100 / $TOTAL_TESTS" | bc -l)
fi

# JSON形式でのレポート出力
cat > "$OUTPUT_DIR/validation-report.json" << EOF
{
    "summary": {
        "totalTests": $TOTAL_TESTS,
        "passedTests": $PASSED_TESTS,
        "failedTests": $FAILED_TESTS,
        "successRate": $SUCCESS_RATE,
        "errors": [$(printf '"%s",' "${ERRORS[@]}" | sed 's/,$//')],
        "timestamp": "$(date -Iseconds)",
        "testProject": "$TEST_PROJECT"
    },
    "environment": {
        "os": "$(uname -s)",
        "kernel": "$(uname -r)",
        "architecture": "$(uname -m)"
    }
}
EOF

# HTML形式でのレポート生成
cat > "$OUTPUT_DIR/validation-report.html" << EOF
<!DOCTYPE html>
<html>
<head>
    <title>VSCode Tasks Validation Report</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 20px; }
        .header { background-color: #f0f0f0; padding: 20px; border-radius: 5px; }
        .summary { background-color: #e8f5e8; padding: 15px; border-radius: 5px; margin: 20px 0; }
        .error { background-color: #ffe8e8; padding: 15px; border-radius: 5px; margin: 20px 0; }
        table { border-collapse: collapse; width: 100%; }
        th, td { border: 1px solid #ddd; padding: 8px; text-align: left; }
        th { background-color: #f2f2f2; }
        .pass { color: green; }
        .fail { color: red; }
    </style>
</head>
<body>
    <div class="header">
        <h1>VSCode Tasks Validation Report</h1>
        <p><strong>Generated:</strong> $(date)</p>
        <p><strong>Test Project:</strong> $TEST_PROJECT</p>
        <p><strong>OS:</strong> $(uname -s) $(uname -r)</p>
    </div>
    
    <div class="summary">
        <h2>Summary</h2>
        <table>
            <tr><th>Total Tests</th><td>$TOTAL_TESTS</td></tr>
            <tr><th>Passed</th><td class="pass">$PASSED_TESTS</td></tr>
            <tr><th>Failed</th><td class="fail">$FAILED_TESTS</td></tr>
            <tr><th>Success Rate</th><td>$SUCCESS_RATE%</td></tr>
        </table>
    </div>
EOF

if [ ${#ERRORS[@]} -gt 0 ]; then
    cat >> "$OUTPUT_DIR/validation-report.html" << EOF
    <div class="error">
        <h2>Errors</h2>
        <ul>
EOF
    for error in "${ERRORS[@]}"; do
        echo "            <li>$error</li>" >> "$OUTPUT_DIR/validation-report.html"
    done
    cat >> "$OUTPUT_DIR/validation-report.html" << EOF
        </ul>
    </div>
EOF
fi

cat >> "$OUTPUT_DIR/validation-report.html" << EOF
</body>
</html>
EOF

# 最終結果の出力
log "INFO" "=== Validation Completed ==="
log "INFO" "Total Tests: $TOTAL_TESTS"
log "INFO" "Passed: $PASSED_TESTS"
log "INFO" "Failed: $FAILED_TESTS"
log "INFO" "Success Rate: $SUCCESS_RATE%"
log "INFO" "Reports generated in: $OUTPUT_DIR"

if [ $FAILED_TESTS -gt 0 ]; then
    log "ERROR" "❌ Some tests failed. Check the detailed report."
    exit 1
else
    log "SUCCESS" "✅ All tests passed!"
    exit 0
fi