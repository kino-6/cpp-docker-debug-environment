# Regression Test Script for CI/CD Compatibility
param([string]$OutputDir = "templates/validation/test-results")

$ErrorActionPreference = "Continue"

if (!(Test-Path $OutputDir)) { New-Item -ItemType Directory -Path $OutputDir -Force | Out-Null }

$logFile = Join-Path $OutputDir "regression-test.log"
$reportFile = Join-Path $OutputDir "regression-test-report.txt"

function Write-Log {
    param([string]$Message, [string]$Level = "INFO")
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logMessage = "[$timestamp] [$Level] $Message"
    Write-Host $logMessage
    Add-Content -Path $logFile -Value $logMessage
}

Write-Log "=== Regression Test Started ===" "INFO"

$testResults = @{
    TotalTests = 0
    PassedTests = 0
    FailedTests = 0
    Results = @()
}

function Test-Project {
    param([string]$ProjectName, [string]$ExecutableName, [string[]]$Args = @())
    
    $testResults.TotalTests++
    Write-Log "Testing project: $ProjectName" "INFO"
    
    $projectPath = "templates/$ProjectName"
    if (!(Test-Path $projectPath)) {
        Write-Log "Project directory not found: $projectPath" "ERROR"
        $testResults.FailedTests++
        $testResults.Results += "$ProjectName - FAIL: Directory not found"
        return
    }
    
    Push-Location $projectPath
    try {
        # Clean and rebuild
        if (Test-Path "build") { Remove-Item -Recurse -Force "build" }
        
        # Configure
        $configResult = cmake -B build -S . -G Ninja -DCMAKE_BUILD_TYPE=Debug 2>&1
        if ($LASTEXITCODE -ne 0) {
            Write-Log "CMake configure failed for $ProjectName" "ERROR"
            $testResults.FailedTests++
            $testResults.Results += "$ProjectName - FAIL: CMake configure failed"
            return
        }
        
        # Build
        $buildResult = cmake --build build --parallel 2>&1
        if ($LASTEXITCODE -ne 0) {
            Write-Log "Build failed for $ProjectName" "ERROR"
            $testResults.FailedTests++
            $testResults.Results += "$ProjectName - FAIL: Build failed"
            return
        }
        
        # Test execution
        $execPath = "./build/bin/$ExecutableName"
        if (!(Test-Path $execPath)) {
            Write-Log "Executable not found: $execPath" "ERROR"
            $testResults.FailedTests++
            $testResults.Results += "$ProjectName - FAIL: Executable not found"
            return
        }
        
        # Run with arguments
        if ($Args.Count -gt 0) {
            $runResult = & $execPath $Args 2>&1
        } else {
            $runResult = & $execPath 2>&1
        }
        
        if ($LASTEXITCODE -eq 0) {
            Write-Log "✅ PASS: $ProjectName executed successfully" "PASS"
            $testResults.PassedTests++
            $testResults.Results += "$ProjectName - PASS: Executed successfully"
        } else {
            Write-Log "❌ FAIL: $ProjectName execution failed (Exit Code: $LASTEXITCODE)" "FAIL"
            $testResults.FailedTests++
            $testResults.Results += "$ProjectName - FAIL: Execution failed (Exit Code: $LASTEXITCODE)"
        }
        
    } catch {
        Write-Log "❌ ERROR: $ProjectName - $($_.Exception.Message)" "ERROR"
        $testResults.FailedTests++
        $testResults.Results += "$ProjectName - ERROR: $($_.Exception.Message)"
    } finally {
        Pop-Location
    }
}

# Test all projects
Test-Project "basic-cpp" "BasicCppProject.exe" @("RegressionTest")
Test-Project "calculator-cpp" "CalculatorProject.exe"
Test-Project "json-parser-cpp" "JsonParserProject.exe" @("--ci")

# Generate report
$successRate = if ($testResults.TotalTests -gt 0) { 
    [math]::Round(($testResults.PassedTests / $testResults.TotalTests) * 100, 2) 
} else { 0 }

$report = @"
Regression Test Report
======================
Generated: $(Get-Date)
Test Type: CI/CD Compatibility Regression Test

Summary:
Total Tests: $($testResults.TotalTests)
Passed: $($testResults.PassedTests)
Failed: $($testResults.FailedTests)
Success Rate: $successRate%

Detailed Results:
$($testResults.Results -join "`n")

Test Environment:
OS: $([System.Environment]::OSVersion.VersionString)
PowerShell: $($PSVersionTable.PSVersion)
CMake: $(cmake --version | Select-Object -First 1)
Ninja: $(ninja --version)
GCC: $(gcc --version | Select-Object -First 1)
"@

$report | Out-File -FilePath $reportFile -Encoding UTF8

Write-Log "=== Regression Test Completed ===" "INFO"
Write-Log "Total: $($testResults.TotalTests), Passed: $($testResults.PassedTests), Failed: $($testResults.FailedTests)" "INFO"
Write-Log "Success Rate: $successRate%" "INFO"
Write-Log "Report saved to: $reportFile" "INFO"

if ($testResults.FailedTests -eq 0) {
    Write-Log "✅ All regression tests passed!" "SUCCESS"
    exit 0
} else {
    Write-Log "❌ Some regression tests failed!" "ERROR"
    exit 1
}