# Debug Configuration Test Script
param(
    [string]$ProjectName = "basic-cpp",
    [string]$OutputDir = "templates/validation/test-results"
)

$ErrorActionPreference = "Continue"

if (!(Test-Path $OutputDir)) { New-Item -ItemType Directory -Path $OutputDir -Force | Out-Null }

$logFile = Join-Path $OutputDir "debug-test.log"
$reportFile = Join-Path $OutputDir "debug-test-report.txt"

function Write-Log {
    param([string]$Message, [string]$Level = "INFO")
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logMessage = "[$timestamp] [$Level] $Message"
    Write-Host $logMessage
    Add-Content -Path $logFile -Value $logMessage
}

Write-Log "=== Debug Configuration Test Started ===" "INFO"
Write-Log "Project: $ProjectName" "INFO"

$testResults = @{
    TotalTests = 0
    PassedTests = 0
    FailedTests = 0
    Results = @()
}

function Test-DebugConfiguration {
    param([string]$Project)
    
    $projectPath = "templates/$Project"
    if (!(Test-Path $projectPath)) {
        Write-Log "Project directory not found: $projectPath" "ERROR"
        return $false
    }
    
    Write-Log "Testing debug configuration for: $Project" "INFO"
    
    # Check launch.json
    $testResults.TotalTests++
    $launchJson = "$projectPath/.vscode/launch.json"
    if (Test-Path $launchJson) {
        Write-Log "✅ PASS: launch.json exists" "PASS"
        $testResults.PassedTests++
        $testResults.Results += "$Project launch.json - PASS"
        
        # Validate JSON syntax
        try {
            $config = Get-Content $launchJson | ConvertFrom-Json
            Write-Log "✅ PASS: launch.json is valid JSON" "PASS"
            $testResults.PassedTests++
            $testResults.Results += "$Project JSON syntax - PASS"
            
            # Check debug configurations
            $testResults.TotalTests++
            if ($config.configurations -and $config.configurations.Count -gt 0) {
                Write-Log "✅ PASS: Debug configurations found: $($config.configurations.Count)" "PASS"
                $testResults.PassedTests++
                $testResults.Results += "$Project debug configs - PASS"
                
                # Check each configuration
                foreach ($debugConfig in $config.configurations) {
                    $testResults.TotalTests++
                    if ($debugConfig.name -and $debugConfig.type -eq "cppdbg") {
                        Write-Log "✅ PASS: Valid debug config: $($debugConfig.name)" "PASS"
                        $testResults.PassedTests++
                        $testResults.Results += "$Project config '$($debugConfig.name)' - PASS"
                    } else {
                        Write-Log "❌ FAIL: Invalid debug config: $($debugConfig.name)" "FAIL"
                        $testResults.FailedTests++
                        $testResults.Results += "$Project config '$($debugConfig.name)' - FAIL"
                    }
                }
            } else {
                Write-Log "❌ FAIL: No debug configurations found" "FAIL"
                $testResults.FailedTests++
                $testResults.Results += "$Project debug configs - FAIL"
            }
            
        } catch {
            Write-Log "❌ FAIL: launch.json syntax error: $($_.Exception.Message)" "FAIL"
            $testResults.FailedTests++
            $testResults.Results += "$Project JSON syntax - FAIL: $($_.Exception.Message)"
        }
        $testResults.TotalTests++
    } else {
        Write-Log "❌ FAIL: launch.json not found" "FAIL"
        $testResults.FailedTests++
        $testResults.Results += "$Project launch.json - FAIL"
    }
    
    # Test debug build
    Push-Location $projectPath
    try {
        Write-Log "Testing debug build for $Project..." "INFO"
        
        # Clean and configure for debug
        if (Test-Path "build") { Remove-Item -Recurse -Force "build" }
        
        $testResults.TotalTests++
        $configResult = cmake -B build -S . -G Ninja -DCMAKE_BUILD_TYPE=Debug 2>&1
        if ($LASTEXITCODE -eq 0) {
            Write-Log "✅ PASS: Debug configure successful" "PASS"
            $testResults.PassedTests++
            $testResults.Results += "$Project debug configure - PASS"
            
            # Check for debug symbols in build files
            $testResults.TotalTests++
            $buildResult = cmake --build build --parallel 2>&1
            if ($LASTEXITCODE -eq 0) {
                Write-Log "✅ PASS: Debug build successful" "PASS"
                $testResults.PassedTests++
                $testResults.Results += "$Project debug build - PASS"
                
                # Check if executable has debug symbols (basic check)
                $executableNames = @("BasicCppProject.exe", "CalculatorProject.exe", "JsonParserProject.exe")
                $foundExec = $null
                foreach ($name in $executableNames) {
                    if (Test-Path "build/bin/$name") {
                        $foundExec = $name
                        break
                    }
                }
                
                $testResults.TotalTests++
                if ($foundExec) {
                    Write-Log "✅ PASS: Debug executable found: $foundExec" "PASS"
                    $testResults.PassedTests++
                    $testResults.Results += "$Project debug executable - PASS"
                    
                    # Test execution with debug build
                    $testResults.TotalTests++
                    try {
                        switch ($foundExec) {
                            "BasicCppProject.exe" {
                                $runResult = & "./build/bin/$foundExec" "DebugTest" 2>&1
                            }
                            "CalculatorProject.exe" {
                                $runResult = & "./build/bin/$foundExec" 2>&1
                            }
                            "JsonParserProject.exe" {
                                $runResult = & "./build/bin/$foundExec" "--ci" 2>&1
                            }
                        }
                        
                        if ($LASTEXITCODE -eq 0) {
                            Write-Log "✅ PASS: Debug executable runs successfully" "PASS"
                            $testResults.PassedTests++
                            $testResults.Results += "$Project debug execution - PASS"
                        } else {
                            Write-Log "❌ FAIL: Debug executable failed to run" "FAIL"
                            $testResults.FailedTests++
                            $testResults.Results += "$Project debug execution - FAIL"
                        }
                    } catch {
                        Write-Log "❌ FAIL: Debug execution error: $($_.Exception.Message)" "FAIL"
                        $testResults.FailedTests++
                        $testResults.Results += "$Project debug execution - FAIL: $($_.Exception.Message)"
                    }
                } else {
                    Write-Log "❌ FAIL: Debug executable not found" "FAIL"
                    $testResults.FailedTests++
                    $testResults.Results += "$Project debug executable - FAIL"
                }
            } else {
                Write-Log "❌ FAIL: Debug build failed" "FAIL"
                $testResults.FailedTests++
                $testResults.Results += "$Project debug build - FAIL"
            }
        } else {
            Write-Log "❌ FAIL: Debug configure failed" "FAIL"
            $testResults.FailedTests++
            $testResults.Results += "$Project debug configure - FAIL"
        }
        
    } finally {
        Pop-Location
    }
    
    return $true
}

# Test all projects with debug configurations
$projects = @("basic-cpp", "calculator-cpp", "json-parser-cpp")

foreach ($project in $projects) {
    Write-Log "=== Testing $project ===" "INFO"
    Test-DebugConfiguration $project
}

# Test breakpoint test file
Write-Log "=== Testing Breakpoint Test File ===" "INFO"
$testResults.TotalTests++
$breakpointTestFile = "templates/validation/breakpoint-test.cpp"
if (Test-Path $breakpointTestFile) {
    Write-Log "✅ PASS: Breakpoint test file exists" "PASS"
    $testResults.PassedTests++
    $testResults.Results += "Breakpoint test file - PASS"
    
    # Try to compile the breakpoint test file
    $testResults.TotalTests++
    try {
        $compileResult = g++ -g3 -O0 -std=c++17 $breakpointTestFile -o "templates/validation/breakpoint-test.exe" 2>&1
        if ($LASTEXITCODE -eq 0) {
            Write-Log "✅ PASS: Breakpoint test file compiles successfully" "PASS"
            $testResults.PassedTests++
            $testResults.Results += "Breakpoint test compile - PASS"
            
            # Test execution
            $testResults.TotalTests++
            $runResult = & "templates/validation/breakpoint-test.exe" 2>&1
            if ($LASTEXITCODE -eq 0) {
                Write-Log "✅ PASS: Breakpoint test executes successfully" "PASS"
                $testResults.PassedTests++
                $testResults.Results += "Breakpoint test execution - PASS"
            } else {
                Write-Log "❌ FAIL: Breakpoint test execution failed" "FAIL"
                $testResults.FailedTests++
                $testResults.Results += "Breakpoint test execution - FAIL"
            }
            
            # Clean up
            if (Test-Path "templates/validation/breakpoint-test.exe") {
                Remove-Item "templates/validation/breakpoint-test.exe" -Force
            }
        } else {
            Write-Log "❌ FAIL: Breakpoint test file compilation failed" "FAIL"
            $testResults.FailedTests++
            $testResults.Results += "Breakpoint test compile - FAIL"
        }
    } catch {
        Write-Log "❌ FAIL: Breakpoint test compilation error: $($_.Exception.Message)" "FAIL"
        $testResults.FailedTests++
        $testResults.Results += "Breakpoint test compile - FAIL: $($_.Exception.Message)"
    }
} else {
    Write-Log "❌ FAIL: Breakpoint test file not found" "FAIL"
    $testResults.FailedTests++
    $testResults.Results += "Breakpoint test file - FAIL"
}

# Generate report
$successRate = if ($testResults.TotalTests -gt 0) { 
    [math]::Round(($testResults.PassedTests / $testResults.TotalTests) * 100, 2) 
} else { 0 }

$report = @"
Debug Configuration Test Report
===============================
Generated: $(Get-Date)
Test Environment: Windows PowerShell

Summary:
Total Tests: $($testResults.TotalTests)
Passed: $($testResults.PassedTests)
Failed: $($testResults.FailedTests)
Success Rate: $successRate%

Detailed Results:
$($testResults.Results -join "`n")

Environment Information:
OS: $([System.Environment]::OSVersion.VersionString)
PowerShell: $($PSVersionTable.PSVersion)
GCC: $(try { gcc --version | Select-Object -First 1 } catch { "Not available" })
GDB: $(try { gdb --version | Select-Object -First 1 } catch { "Not available" })
"@

$report | Out-File -FilePath $reportFile -Encoding UTF8

Write-Log "=== Debug Configuration Test Completed ===" "INFO"
Write-Log "Total: $($testResults.TotalTests), Passed: $($testResults.PassedTests), Failed: $($testResults.FailedTests)" "INFO"
Write-Log "Success Rate: $successRate%" "INFO"
Write-Log "Report saved to: $reportFile" "INFO"

if ($testResults.FailedTests -eq 0) {
    Write-Log "✅ All debug configuration tests passed!" "SUCCESS"
    exit 0
} else {
    Write-Log "❌ Some debug configuration tests failed!" "ERROR"
    exit 1
}