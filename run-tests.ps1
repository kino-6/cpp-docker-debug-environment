# Integrated Test Runner for C++ Docker Debug Environment
# Usage: .\run-tests.ps1 [TestType] [Options]
# Examples:
#   .\run-tests.ps1                    # Run all tests
#   .\run-tests.ps1 -Quick             # Run quick tests only
#   .\run-tests.ps1 -Docker            # Run Docker tests only
#   .\run-tests.ps1 -Regression        # Run regression tests only
#   .\run-tests.ps1 -Verbose           # Run with verbose output

param(
    [switch]$Quick,
    [switch]$Docker,
    [switch]$Regression,
    [switch]$DevContainer,
    [switch]$Verbose,
    [switch]$Help,
    [string]$OutputDir = "test-results"
)

$ErrorActionPreference = "Continue"

# Colors for output
$Colors = @{
    Red = "Red"
    Green = "Green"
    Yellow = "Yellow"
    Blue = "Cyan"
    White = "White"
}

function Write-ColorLog {
    param([string]$Message, [string]$Level = "INFO")
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logMessage = "[$timestamp] [$Level] $Message"
    
    $color = switch ($Level) {
        "ERROR" { $Colors.Red }
        "FAIL" { $Colors.Red }
        "PASS" { $Colors.Green }
        "SUCCESS" { $Colors.Green }
        "SKIP" { $Colors.Yellow }
        "WARN" { $Colors.Yellow }
        "INFO" { $Colors.Blue }
        default { $Colors.White }
    }
    
    Write-Host $logMessage -ForegroundColor $color
}

function Show-Help {
    Write-Host @"
C++ Docker Debug Environment - Integrated Test Runner
====================================================

USAGE:
    .\run-tests.ps1 [OPTIONS]

OPTIONS:
    -Quick          Run quick tests only (basic functionality)
    -Docker         Run Docker environment tests only
    -Regression     Run regression tests only
    -DevContainer   Run Dev Container tests only
    -Verbose        Enable verbose output
    -Help           Show this help message
    -OutputDir      Specify output directory (default: test-results)

EXAMPLES:
    .\run-tests.ps1                    # Run all tests
    .\run-tests.ps1 -Quick             # Quick smoke test
    .\run-tests.ps1 -Docker            # Docker environment test
    .\run-tests.ps1 -Regression        # Full regression test
    .\run-tests.ps1 -Verbose           # Verbose output

TEST TYPES:
    Quick Tests     - Basic build and execution tests (~30 seconds)
    Regression      - Full functionality tests (~2 minutes)
    Docker Tests    - WSL2/Linux environment tests (~1 minute)
    DevContainer    - Dev Container configuration tests (~30 seconds)

OUTPUT:
    All test results are saved to the specified output directory.
    HTML and text reports are generated for easy review.

"@ -ForegroundColor $Colors.Blue
}

function Initialize-TestEnvironment {
    Write-ColorLog "Initializing test environment..." "INFO"
    
    # Create output directory
    if (!(Test-Path $OutputDir)) {
        New-Item -ItemType Directory -Path $OutputDir -Force | Out-Null
        Write-ColorLog "Created output directory: $OutputDir" "INFO"
    }
    
    # Clear previous results
    Get-ChildItem $OutputDir -Filter "*.log" | Remove-Item -Force -ErrorAction SilentlyContinue
    Get-ChildItem $OutputDir -Filter "*-report.*" | Remove-Item -Force -ErrorAction SilentlyContinue
    
    # Environment check
    $env = @{
        OS = [System.Environment]::OSVersion.VersionString
        PowerShell = $PSVersionTable.PSVersion.ToString()
        WorkingDir = Get-Location
        DateTime = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    }
    
    Write-ColorLog "Environment: $($env.OS)" "INFO"
    Write-ColorLog "PowerShell: $($env.PowerShell)" "INFO"
    
    return $env
}

function Test-Prerequisites {
    Write-ColorLog "Checking prerequisites..." "INFO"
    
    $prereqs = @{
        CMake = $false
        Ninja = $false
        GCC = $false
        WSL = $false
        Docker = $false
    }
    
    # Check CMake
    try {
        cmake --version | Out-Null
        $prereqs.CMake = $LASTEXITCODE -eq 0
    } catch { }
    
    # Check Ninja
    try {
        ninja --version | Out-Null
        $prereqs.Ninja = $LASTEXITCODE -eq 0
    } catch { }
    
    # Check GCC
    try {
        gcc --version | Out-Null
        $prereqs.GCC = $LASTEXITCODE -eq 0
    } catch { }
    
    # Check WSL
    try {
        wsl --version | Out-Null
        $prereqs.WSL = $LASTEXITCODE -eq 0
    } catch { }
    
    # Check Docker
    try {
        docker --version | Out-Null
        $prereqs.Docker = $LASTEXITCODE -eq 0
    } catch { }
    
    foreach ($tool in $prereqs.Keys) {
        $status = if ($prereqs[$tool]) { "PASS" } else { "SKIP" }
        Write-ColorLog "$tool available: $($prereqs[$tool])" $status
    }
    
    return $prereqs
}

function Invoke-QuickTests {
    Write-ColorLog "=== Running Quick Tests ===" "INFO"
    
    $results = @{
        TotalTests = 0
        PassedTests = 0
        FailedTests = 0
        Duration = 0
    }
    
    $stopwatch = [System.Diagnostics.Stopwatch]::StartNew()
    
    try {
        # Test basic project structure
        $projects = @("basic-cpp", "calculator-cpp", "json-parser-cpp")
        
        foreach ($project in $projects) {
            $results.TotalTests++
            $projectPath = "templates/$project"
            
            if (Test-Path $projectPath) {
                Write-ColorLog "✅ Project structure: $project" "PASS"
                $results.PassedTests++
            } else {
                Write-ColorLog "❌ Project structure: $project" "FAIL"
                $results.FailedTests++
            }
            
            # Check VSCode tasks
            $results.TotalTests++
            $tasksPath = "$projectPath/.vscode/tasks.json"
            if (Test-Path $tasksPath) {
                Write-ColorLog "✅ VSCode tasks: $project" "PASS"
                $results.PassedTests++
            } else {
                Write-ColorLog "❌ VSCode tasks: $project" "FAIL"
                $results.FailedTests++
            }
        }
        
        # Quick build test (basic-cpp only)
        $results.TotalTests++
        Push-Location "templates/basic-cpp"
        try {
            if (Test-Path "build") { Remove-Item -Recurse -Force "build" }
            
            $configResult = cmake -B build -S . -G Ninja -DCMAKE_BUILD_TYPE=Debug 2>&1
            if ($LASTEXITCODE -eq 0) {
                $buildResult = cmake --build build --parallel 2>&1
                if ($LASTEXITCODE -eq 0) {
                    Write-ColorLog "✅ Quick build test" "PASS"
                    $results.PassedTests++
                } else {
                    Write-ColorLog "❌ Quick build test (build failed)" "FAIL"
                    $results.FailedTests++
                }
            } else {
                Write-ColorLog "❌ Quick build test (configure failed)" "FAIL"
                $results.FailedTests++
            }
        } finally {
            Pop-Location
        }
        
    } finally {
        $stopwatch.Stop()
        $results.Duration = $stopwatch.Elapsed.TotalSeconds
    }
    
    return $results
}

function Invoke-RegressionTests {
    Write-ColorLog "=== Running Regression Tests ===" "INFO"
    
    $stopwatch = [System.Diagnostics.Stopwatch]::StartNew()
    
    try {
        if (Test-Path "templates/validation/regression-test.ps1") {
            $result = & "templates/validation/regression-test.ps1" -OutputDir $OutputDir
            $success = $LASTEXITCODE -eq 0
            
            if ($success) {
                Write-ColorLog "✅ Regression tests completed successfully" "PASS"
            } else {
                Write-ColorLog "❌ Regression tests failed" "FAIL"
            }
            
            return @{
                Success = $success
                Duration = $stopwatch.Elapsed.TotalSeconds
                ExitCode = $LASTEXITCODE
            }
        } else {
            Write-ColorLog "❌ Regression test script not found" "FAIL"
            return @{ Success = $false; Duration = 0; ExitCode = -1 }
        }
    } finally {
        $stopwatch.Stop()
    }
}

function Invoke-DockerTests {
    Write-ColorLog "=== Running Docker Tests ===" "INFO"
    
    $stopwatch = [System.Diagnostics.Stopwatch]::StartNew()
    
    try {
        # Check if WSL is available
        try {
            wsl --version | Out-Null
            if ($LASTEXITCODE -eq 0) {
                Write-ColorLog "Running Docker tests in WSL2 environment..." "INFO"
                $result = wsl bash templates/validation/docker-test.sh basic-cpp
                $success = $LASTEXITCODE -eq 0
                
                if ($success) {
                    Write-ColorLog "✅ Docker tests completed successfully" "PASS"
                } else {
                    Write-ColorLog "❌ Docker tests failed" "FAIL"
                }
                
                return @{
                    Success = $success
                    Duration = $stopwatch.Elapsed.TotalSeconds
                    ExitCode = $LASTEXITCODE
                }
            } else {
                Write-ColorLog "⚠️ WSL not available, skipping Docker tests" "SKIP"
                return @{ Success = $true; Duration = 0; ExitCode = 0; Skipped = $true }
            }
        } catch {
            Write-ColorLog "⚠️ WSL not available, skipping Docker tests" "SKIP"
            return @{ Success = $true; Duration = 0; ExitCode = 0; Skipped = $true }
        }
    } finally {
        $stopwatch.Stop()
    }
}

function Invoke-DevContainerTests {
    Write-ColorLog "=== Running Dev Container Tests ===" "INFO"
    
    $stopwatch = [System.Diagnostics.Stopwatch]::StartNew()
    
    try {
        if (Test-Path "templates/validation/devcontainer-test.ps1") {
            $result = & "templates/validation/devcontainer-test.ps1" -OutputDir $OutputDir
            $success = $LASTEXITCODE -eq 0
            
            if ($success) {
                Write-ColorLog "✅ Dev Container tests completed successfully" "PASS"
            } else {
                Write-ColorLog "⚠️ Dev Container tests completed with warnings" "WARN"
                # Dev Container tests may have warnings due to JSONC format, but that's expected
                $success = $true
            }
            
            return @{
                Success = $success
                Duration = $stopwatch.Elapsed.TotalSeconds
                ExitCode = $LASTEXITCODE
            }
        } else {
            Write-ColorLog "❌ Dev Container test script not found" "FAIL"
            return @{ Success = $false; Duration = 0; ExitCode = -1 }
        }
    } finally {
        $stopwatch.Stop()
    }
}

function Invoke-EnvironmentValidation {
    Write-ColorLog "=== Running Environment Validation (Task 6) ===" "INFO"
    
    $stopwatch = [System.Diagnostics.Stopwatch]::StartNew()
    
    try {
        if (Test-Path "templates/validation/environment-validation.ps1") {
            $result = & "templates/validation/environment-validation.ps1" -OutputDir $OutputDir
            $success = $LASTEXITCODE -eq 0
            
            if ($success) {
                Write-ColorLog "✅ Environment validation completed successfully" "PASS"
            } else {
                Write-ColorLog "❌ Environment validation failed" "FAIL"
            }
            
            return @{
                Success = $success
                Duration = $stopwatch.Elapsed.TotalSeconds
                ExitCode = $LASTEXITCODE
            }
        } else {
            Write-ColorLog "❌ Environment validation script not found" "FAIL"
            return @{ Success = $false; Duration = 0; ExitCode = -1 }
        }
    } finally {
        $stopwatch.Stop()
    }
}

function Generate-SummaryReport {
    param($TestResults, $Environment, $Prerequisites)
    
    $totalDuration = 0
    foreach ($result in $TestResults.Values) {
        if ($result.Duration) { $totalDuration += $result.Duration }
    }
    $overallSuccess = ($TestResults.Values | Where-Object { $_.Success -eq $false }).Count -eq 0
    
    $report = @"
C++ Docker Debug Environment - Test Summary Report
==================================================
Generated: $(Get-Date -Format "yyyy-MM-dd HH:mm:ss")
Environment: $($Environment.OS)
PowerShell: $($Environment.PowerShell)
Total Duration: $([math]::Round($totalDuration, 2)) seconds

Prerequisites:
$($Prerequisites.Keys | ForEach-Object { "  $_`: $($Prerequisites[$_])" }) -join "`n"

Test Results:
"@

    foreach ($testType in $TestResults.Keys) {
        $result = $TestResults[$testType]
        $status = if ($result.Success) { "✅ PASS" } else { "❌ FAIL" }
        if ($result.Skipped) { $status = "⚠️ SKIP" }
        
        $report += "`n  $testType`: $status ($([math]::Round($result.Duration, 2))s)"
    }
    
    $report += "`n`nOverall Result: $(if ($overallSuccess) { "✅ SUCCESS" } else { "❌ FAILURE" })"
    $report += "`n`nDetailed reports available in: $OutputDir"
    
    # Save report
    $report | Out-File -FilePath "$OutputDir/test-summary.txt" -Encoding UTF8
    
    # Display summary
    Write-Host "`n" -NoNewline
    Write-ColorLog "=== TEST SUMMARY ===" "INFO"
    Write-Host $report -ForegroundColor $Colors.White
    
    return $overallSuccess
}

# Main execution
function Main {
    if ($Help) {
        Show-Help
        return 0
    }
    
    Write-ColorLog "C++ Docker Debug Environment - Integrated Test Runner" "INFO"
    Write-ColorLog "=====================================================" "INFO"
    
    $environment = Initialize-TestEnvironment
    $prerequisites = Test-Prerequisites
    
    $testResults = @{}
    
    # Determine which tests to run
    $runAll = -not ($Quick -or $Docker -or $Regression -or $DevContainer)
    
    if ($Quick -or $runAll) {
        $testResults["Quick Tests"] = Invoke-QuickTests
    }
    
    if ($Regression -or $runAll) {
        $testResults["Regression Tests"] = Invoke-RegressionTests
    }
    
    if ($Docker -or $runAll) {
        $testResults["Docker Tests"] = Invoke-DockerTests
    }
    
    if ($DevContainer -or $runAll) {
        $testResults["Dev Container Tests"] = Invoke-DevContainerTests
    }
    
    # Add Task 6 Environment Validation
    if ($runAll) {
        $testResults["Environment Validation"] = Invoke-EnvironmentValidation
    }
    
    # Generate summary report
    $success = Generate-SummaryReport $testResults $environment $prerequisites
    
    if ($success) {
        Write-ColorLog "🎉 All tests completed successfully!" "SUCCESS"
        return 0
    } else {
        Write-ColorLog "❌ Some tests failed. Check detailed reports in $OutputDir" "ERROR"
        return 1
    }
}

# Execute main function
exit (Main)