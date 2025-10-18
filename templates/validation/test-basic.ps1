# Basic VSCode Tasks Validation
param([string]$TestProject = "basic-cpp")

$OutputDir = "templates/validation/test-results"
if (!(Test-Path $OutputDir)) { New-Item -ItemType Directory -Path $OutputDir -Force | Out-Null }

$logFile = Join-Path $OutputDir "validation.log"
$reportFile = Join-Path $OutputDir "validation-report.txt"

function Write-Log {
    param([string]$Message, [string]$Level = "INFO")
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logMessage = "[$timestamp] [$Level] $Message"
    Write-Host $logMessage
    Add-Content -Path $logFile -Value $logMessage
}

Write-Log "Starting validation for project: $TestProject"

$results = @()
$totalTests = 0
$passedTests = 0

function Test-Item {
    param([string]$Name, [scriptblock]$Test)
    $script:totalTests++
    Write-Log "Testing: $Name"
    
    try {
        $result = & $Test
        if ($result) {
            Write-Log "PASS: $Name"
            $script:passedTests++
            $script:results += "$Name - PASS"
        } else {
            Write-Log "FAIL: $Name"
            $script:results += "$Name - FAIL"
        }
    } catch {
        Write-Log "ERROR: $Name - $($_.Exception.Message)"
        $script:results += "$Name - ERROR: $($_.Exception.Message)"
    }
}

# Environment Tests
Test-Item "CMake Available" { try { cmake --version | Out-Null; $LASTEXITCODE -eq 0 } catch { $false } }
Test-Item "Ninja Available" { try { ninja --version | Out-Null; $LASTEXITCODE -eq 0 } catch { $false } }
Test-Item "GCC Available" { try { gcc --version | Out-Null; $LASTEXITCODE -eq 0 } catch { $false } }

# File Tests
$projectPath = "templates/$TestProject"
Test-Item "Project Directory" { Test-Path $projectPath }
Test-Item "VSCode Tasks Config" { Test-Path "$projectPath/.vscode/tasks.json" }

# Build Tests
if (Test-Path $projectPath) {
    Push-Location $projectPath
    try {
        if (Test-Path "build") { Remove-Item -Recurse -Force "build" }
        
        Test-Item "CMake Configure" {
            cmake -B build -S . -G Ninja -DCMAKE_BUILD_TYPE=Debug -DCMAKE_EXPORT_COMPILE_COMMANDS=ON 2>&1 | Out-Null
            $LASTEXITCODE -eq 0
        }
        
        Test-Item "Compile Commands Generated" { Test-Path "build/compile_commands.json" }
        
        Test-Item "CMake Build" {
            cmake --build build --config Debug --parallel 2>&1 | Out-Null
            $LASTEXITCODE -eq 0
        }
        
        # Check for actual executable name (from CMakeLists.txt project name)
        $execNames = @("BasicCppProject", "CalculatorCppProject", "JsonParserCppProject")
        if ($IsWindows) { $execNames = $execNames | ForEach-Object { "$_.exe" } }
        
        $foundExec = $null
        foreach ($name in $execNames) {
            if (Test-Path "build/bin/$name") {
                $foundExec = $name
                break
            }
        }
        
        Test-Item "Executable Generated" { $foundExec -ne $null }
        
        Test-Item "Application Runs" {
            if ($foundExec) {
                # Use CI-friendly flags for applications that support them
                $args = @()
                if ($foundExec -match "JsonParserCppProject") {
                    $args += "--ci"
                }
                
                if ($args.Count -gt 0) {
                    & "./build/bin/$foundExec" $args 2>&1 | Out-Null
                } else {
                    & "./build/bin/$foundExec" 2>&1 | Out-Null
                }
                $LASTEXITCODE -eq 0
            } else { $false }
        }
    } finally {
        Pop-Location
    }
}

# Generate Report
$successRate = if ($totalTests -gt 0) { [math]::Round(($passedTests / $totalTests) * 100, 2) } else { 0 }

$report = @"
VSCode Tasks Validation Report
==============================
Generated: $(Get-Date)
Project: $TestProject
OS: $([System.Environment]::OSVersion.VersionString)

Summary:
Total Tests: $totalTests
Passed: $passedTests
Failed: $($totalTests - $passedTests)
Success Rate: $successRate%

Results:
$($results -join "`n")
"@

$report | Out-File -FilePath $reportFile -Encoding UTF8

Write-Log "Validation completed. Report saved to: $reportFile"
Write-Log "Total: $totalTests, Passed: $passedTests, Success Rate: $successRate%"

if ($passedTests -eq $totalTests) {
    Write-Log "All tests passed!"
    exit 0
} else {
    Write-Log "Some tests failed."
    exit 1
}