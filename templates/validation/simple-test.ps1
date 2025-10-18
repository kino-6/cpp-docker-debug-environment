# 簡単なVSCodeタスク設定検証スクリプト
param(
    [string]$TestProject = "basic-cpp"
)

$ErrorActionPreference = "Continue"
$OutputDir = "templates/validation/test-results"

# 出力ディレクトリの作成
if (!(Test-Path $OutputDir)) {
    New-Item -ItemType Directory -Path $OutputDir -Force | Out-Null
}

$logFile = Join-Path $OutputDir "validation.log"
$reportFile = Join-Path $OutputDir "validation-report.txt"

function Write-Log {
    param([string]$Message, [string]$Level = "INFO")
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logMessage = "[$timestamp] [$Level] $Message"
    Write-Host $logMessage
    Add-Content -Path $logFile -Value $logMessage
}

# 検証開始
Write-Log "=== VSCode Tasks Validation Started ===" "INFO"
Write-Log "Test Project: $TestProject" "INFO"

$testResults = @{
    TotalTests = 0
    PassedTests = 0
    FailedTests = 0
    Results = @()
}

function Test-Item {
    param([string]$TestName, [scriptblock]$TestScript)
    
    $testResults.TotalTests++
    Write-Log "Testing: $TestName" "INFO"
    
    try {
        $result = & $TestScript
        if ($result) {
            Write-Log "✅ PASS: $TestName" "PASS"
            $testResults.PassedTests++
            $testResults.Results += @{ Name = $TestName; Status = "PASS"; Details = "" }
        } else {
            Write-Log "❌ FAIL: $TestName" "FAIL"
            $testResults.FailedTests++
            $testResults.Results += @{ Name = $TestName; Status = "FAIL"; Details = "Test returned false" }
        }
    } catch {
        Write-Log "❌ ERROR: $TestName - $($_.Exception.Message)" "ERROR"
        $testResults.FailedTests++
        $testResults.Results += @{ Name = $TestName; Status = "ERROR"; Details = $_.Exception.Message }
    }
}

# 1. 環境確認
Test-Item "CMake Installation" { 
    try { cmake --version | Out-Null; return $true } catch { return $false }
}

Test-Item "Ninja Installation" { 
    try { ninja --version | Out-Null; return $true } catch { return $false }
}

Test-Item "GCC Installation" { 
    try { gcc --version | Out-Null; return $true } catch { return $false }
}

# 2. ファイル存在確認
$projectPath = "templates/$TestProject"
Test-Item "Project Directory Exists" { 
    Test-Path $projectPath
}

Test-Item "VSCode Tasks Configuration Exists" { 
    Test-Path "$projectPath/.vscode/tasks.json"
}

# 3. プロジェクトディレクトリに移動してビルドテスト
if (Test-Path $projectPath) {
    Push-Location $projectPath
    
    try {
        # 既存のbuildディレクトリをクリーンアップ
        if (Test-Path "build") {
            Remove-Item -Recurse -Force "build"
            Write-Log "Cleaned existing build directory" "INFO"
        }
        
        Test-Item "CMake Configure" {
            try {
                cmake -B build -S . -G Ninja -DCMAKE_BUILD_TYPE=Debug -DCMAKE_EXPORT_COMPILE_COMMANDS=ON 2>&1 | Out-Null
                return $LASTEXITCODE -eq 0
            } catch {
                return $false
            }
        }
        
        Test-Item "compile_commands.json Generation" {
            Test-Path "build/compile_commands.json"
        }
        
        Test-Item "CMake Build" {
            try {
                cmake --build build --config Debug --parallel 2>&1 | Out-Null
                return $LASTEXITCODE -eq 0
            } catch {
                return $false
            }
        }
        
        Test-Item "Executable Generation" {
            $execName = "$TestProject"
            if ($IsWindows) { $execName += ".exe" }
            Test-Path "build/bin/$execName"
        }
        
        Test-Item "Application Execution" {
            try {
                $execName = "$TestProject"
                if ($IsWindows) { $execName += ".exe" }
                if (Test-Path "build/bin/$execName") {
                    & "./build/bin/$execName" 2>&1 | Out-Null
                    return $LASTEXITCODE -eq 0
                } else {
                    return $false
                }
            } catch {
                return $false
            }
        }
        
    } finally {
        Pop-Location
    }
} else {
    Write-Log "Project directory not found, skipping build tests" "SKIP"
}

# 結果の集計
$successRate = if ($testResults.TotalTests -gt 0) { 
    [math]::Round(($testResults.PassedTests / $testResults.TotalTests) * 100, 2) 
} else { 0 }

# レポート生成
$report = @"
VSCode Tasks Validation Report
==============================
Generated: $(Get-Date -Format "yyyy-MM-dd HH:mm:ss")
Test Project: $TestProject
OS: $([System.Environment]::OSVersion.VersionString)

Summary:
--------
Total Tests: $($testResults.TotalTests)
Passed: $($testResults.PassedTests)
Failed: $($testResults.FailedTests)
Success Rate: $successRate%

Detailed Results:
-----------------
"@

foreach ($result in $testResults.Results) {
    $status = $result.Status
    $statusSymbol = switch ($status) {
        "PASS" { "✅" }
        "FAIL" { "❌" }
        "ERROR" { "🚨" }
        default { "❓" }
    }
    
    $report += "`n$statusSymbol $status`: $($result.Name)"
    if ($result.Details) {
        $report += "`n   Details: $($result.Details)"
    }
}

$report | Out-File -FilePath $reportFile -Encoding UTF8

# 最終結果
Write-Log "=== Validation Completed ===" "INFO"
Write-Log "Total Tests: $($testResults.TotalTests)" "INFO"
Write-Log "Passed: $($testResults.PassedTests)" "INFO"
Write-Log "Failed: $($testResults.FailedTests)" "INFO"
Write-Log "Success Rate: $successRate%" "INFO"
Write-Log "Report saved to: $reportFile" "INFO"

if ($testResults.FailedTests -gt 0) {
    Write-Log "❌ Some tests failed. Check the detailed report." "ERROR"
    exit 1
} else {
    Write-Log "✅ All tests passed!" "SUCCESS"
    exit 0
}