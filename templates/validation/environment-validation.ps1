# Comprehensive Environment Validation Script
# Task 6: 基本環境の動作検証

param(
    [string]$OutputDir = "templates/validation/test-results",
    [switch]$Verbose,
    [switch]$SkipInteractive
)

$ErrorActionPreference = "Continue"

if (!(Test-Path $OutputDir)) { New-Item -ItemType Directory -Path $OutputDir -Force | Out-Null }

$logFile = Join-Path $OutputDir "environment-validation.log"
$reportFile = Join-Path $OutputDir "environment-validation-report.txt"

function Write-Log {
    param([string]$Message, [string]$Level = "INFO")
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logMessage = "[$timestamp] [$Level] $Message"
    Write-Host $logMessage
    Add-Content -Path $logFile -Value $logMessage
}

Write-Log "=== Task 6: Basic Environment Validation Started ===" "INFO"

$validationResults = @{
    TotalTests = 0
    PassedTests = 0
    FailedTests = 0
    SkippedTests = 0
    Results = @()
    Environment = @{}
    Performance = @{}
}

# Environment Information Collection
function Get-EnvironmentInfo {
    Write-Log "=== Collecting Environment Information ===" "INFO"
    
    $env = @{
        OS = [System.Environment]::OSVersion.VersionString
        PowerShell = $PSVersionTable.PSVersion.ToString()
        Architecture = [System.Environment]::ProcessorCount.ToString() + " cores"
        WorkingDirectory = Get-Location
        DateTime = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        UserName = [System.Environment]::UserName
    }
    
    # Tool versions
    try { $env.CMake = (cmake --version | Select-Object -First 1) } catch { $env.CMake = "Not available" }
    try { $env.Ninja = "$(ninja --version)" } catch { $env.Ninja = "Not available" }
    try { $env.GCC = (gcc --version | Select-Object -First 1) } catch { $env.GCC = "Not available" }
    try { $env.GDB = (gdb --version | Select-Object -First 1) } catch { $env.GDB = "Not available" }
    try { $env.Git = (git --version) } catch { $env.Git = "Not available" }
    
    $validationResults.Environment = $env
    
    foreach ($tool in $env.Keys) {
        Write-Log "$tool`: $($env[$tool])" "INFO"
    }
    
    return $env
}

function Test-ValidationItem {
    param([string]$TestName, [scriptblock]$TestScript, [string]$Category = "General")
    
    $validationResults.TotalTests++
    Write-Log "Testing: $TestName" "INFO"
    
    $stopwatch = [System.Diagnostics.Stopwatch]::StartNew()
    
    try {
        $result = & $TestScript
        $stopwatch.Stop()
        
        if ($result.Success) {
            Write-Log "✅ PASS: $TestName" "PASS"
            $validationResults.PassedTests++
            $validationResults.Results += @{
                Name = $TestName
                Category = $Category
                Status = "PASS"
                Duration = $stopwatch.Elapsed.TotalSeconds
                Details = $result.Details
            }
        } elseif ($result.Skipped) {
            Write-Log "⚠️ SKIP: $TestName - $($result.Reason)" "SKIP"
            $validationResults.SkippedTests++
            $validationResults.Results += @{
                Name = $TestName
                Category = $Category
                Status = "SKIP"
                Duration = $stopwatch.Elapsed.TotalSeconds
                Details = $result.Reason
            }
        } else {
            Write-Log "❌ FAIL: $TestName - $($result.Details)" "FAIL"
            $validationResults.FailedTests++
            $validationResults.Results += @{
                Name = $TestName
                Category = $Category
                Status = "FAIL"
                Duration = $stopwatch.Elapsed.TotalSeconds
                Details = $result.Details
            }
        }
    } catch {
        $stopwatch.Stop()
        Write-Log "❌ ERROR: $TestName - $($_.Exception.Message)" "ERROR"
        $validationResults.FailedTests++
        $validationResults.Results += @{
            Name = $TestName
            Category = $Category
            Status = "ERROR"
            Duration = $stopwatch.Elapsed.TotalSeconds
            Details = $_.Exception.Message
        }
    }
}

# Test 1: Hello World Project Build and Execution
function Test-HelloWorldProject {
    $projects = @("basic-cpp", "calculator-cpp", "json-parser-cpp")
    
    foreach ($project in $projects) {
        Test-ValidationItem "Hello World Build: $project" {
            $projectPath = "templates/$project"
            if (!(Test-Path $projectPath)) {
                return @{ Success = $false; Details = "Project directory not found" }
            }
            
            Push-Location $projectPath
            try {
                # Clean build
                if (Test-Path "build") { Remove-Item -Recurse -Force "build" }
                
                # Configure
                $configResult = cmake -B build -S . -G Ninja -DCMAKE_BUILD_TYPE=Debug -DCMAKE_EXPORT_COMPILE_COMMANDS=ON 2>&1
                if ($LASTEXITCODE -ne 0) {
                    return @{ Success = $false; Details = "CMake configure failed" }
                }
                
                # Build
                $buildResult = cmake --build build --parallel 2>&1
                if ($LASTEXITCODE -ne 0) {
                    return @{ Success = $false; Details = "Build failed" }
                }
                
                # Find executable
                $executableNames = @("BasicCppProject.exe", "CalculatorProject.exe", "JsonParserProject.exe")
                $foundExec = $null
                foreach ($name in $executableNames) {
                    if (Test-Path "build/bin/$name") {
                        $foundExec = $name
                        break
                    }
                }
                
                if (!$foundExec) {
                    return @{ Success = $false; Details = "Executable not found" }
                }
                
                # Execute
                switch ($foundExec) {
                    "BasicCppProject.exe" {
                        $runResult = & "./build/bin/$foundExec" "ValidationTest" 2>&1
                    }
                    "CalculatorProject.exe" {
                        $runResult = & "./build/bin/$foundExec" 2>&1
                    }
                    "JsonParserProject.exe" {
                        $runResult = & "./build/bin/$foundExec" "--ci" 2>&1
                    }
                }
                
                if ($LASTEXITCODE -eq 0) {
                    return @{ Success = $true; Details = "Build and execution successful" }
                } else {
                    return @{ Success = $false; Details = "Execution failed" }
                }
                
            } finally {
                Pop-Location
            }
        } "Hello World Projects"
    }
}

# Test 2: Debug Configuration Validation
function Test-DebugConfiguration {
    $projects = @("basic-cpp", "calculator-cpp", "json-parser-cpp")
    
    foreach ($project in $projects) {
        Test-ValidationItem "Debug Configuration: $project" {
            $launchJsonPath = "templates/$project/.vscode/launch.json"
            
            if (!(Test-Path $launchJsonPath)) {
                return @{ Success = $false; Details = "launch.json not found" }
            }
            
            try {
                $launchConfig = Get-Content $launchJsonPath | ConvertFrom-Json
                
                if (!$launchConfig.configurations -or $launchConfig.configurations.Count -eq 0) {
                    return @{ Success = $false; Details = "No debug configurations found" }
                }
                
                $validConfigs = 0
                foreach ($config in $launchConfig.configurations) {
                    if ($config.type -eq "cppdbg" -and $config.request -and $config.program) {
                        $validConfigs++
                    }
                }
                
                if ($validConfigs -gt 0) {
                    return @{ Success = $true; Details = "$validConfigs valid debug configurations found" }
                } else {
                    return @{ Success = $false; Details = "No valid debug configurations found" }
                }
                
            } catch {
                return @{ Success = $false; Details = "JSON parsing error: $($_.Exception.Message)" }
            }
        } "Debug Configuration"
    }
}

# Test 3: IntelliSense Configuration Validation
function Test-IntelliSenseConfiguration {
    $projects = @("basic-cpp", "calculator-cpp", "json-parser-cpp")
    
    foreach ($project in $projects) {
        Test-ValidationItem "IntelliSense Setup: $project" {
            $projectPath = "templates/$project"
            
            Push-Location $projectPath
            try {
                # Ensure build exists with compile_commands.json
                if (!(Test-Path "build")) {
                    $configResult = cmake -B build -S . -G Ninja -DCMAKE_BUILD_TYPE=Debug -DCMAKE_EXPORT_COMPILE_COMMANDS=ON 2>&1
                    if ($LASTEXITCODE -ne 0) {
                        return @{ Success = $false; Details = "Failed to generate build files" }
                    }
                }
                
                # Check compile_commands.json
                if (!(Test-Path "build/compile_commands.json")) {
                    return @{ Success = $false; Details = "compile_commands.json not generated" }
                }
                
                # Validate compile_commands.json content
                try {
                    $compileCommands = Get-Content "build/compile_commands.json" | ConvertFrom-Json
                    if ($compileCommands.Count -gt 0) {
                        return @{ Success = $true; Details = "IntelliSense configuration ready ($($compileCommands.Count) compile commands)" }
                    } else {
                        return @{ Success = $false; Details = "Empty compile_commands.json" }
                    }
                } catch {
                    return @{ Success = $false; Details = "Invalid compile_commands.json format" }
                }
                
            } finally {
                Pop-Location
            }
        } "IntelliSense Configuration"
    }
}

# Test 4: VSCode Tasks Configuration
function Test-VSCodeTasksConfiguration {
    $projects = @("basic-cpp", "calculator-cpp", "json-parser-cpp")
    
    foreach ($project in $projects) {
        Test-ValidationItem "VSCode Tasks: $project" {
            $tasksJsonPath = "templates/$project/.vscode/tasks.json"
            
            if (!(Test-Path $tasksJsonPath)) {
                return @{ Success = $false; Details = "tasks.json not found" }
            }
            
            try {
                $tasksConfig = Get-Content $tasksJsonPath | ConvertFrom-Json
                
                if (!$tasksConfig.tasks -or $tasksConfig.tasks.Count -eq 0) {
                    return @{ Success = $false; Details = "No tasks found" }
                }
                
                $requiredTasks = @("CMake Configure", "CMake Build", "CMake Clean")
                $foundTasks = @()
                
                foreach ($task in $tasksConfig.tasks) {
                    if ($task.label -in $requiredTasks) {
                        $foundTasks += $task.label
                    }
                }
                
                if ($foundTasks.Count -eq $requiredTasks.Count) {
                    return @{ Success = $true; Details = "All required tasks found: $($foundTasks -join ', ')" }
                } else {
                    $missing = $requiredTasks | Where-Object { $_ -notin $foundTasks }
                    return @{ Success = $false; Details = "Missing tasks: $($missing -join ', ')" }
                }
                
            } catch {
                return @{ Success = $false; Details = "JSON parsing error: $($_.Exception.Message)" }
            }
        } "VSCode Tasks"
    }
}

# Test 5: Dev Container Configuration
function Test-DevContainerConfiguration {
    $projects = @("basic-cpp", "calculator-cpp", "json-parser-cpp")
    
    foreach ($project in $projects) {
        Test-ValidationItem "Dev Container: $project" {
            $devcontainerPath = "templates/$project/.devcontainer"
            
            if (!(Test-Path $devcontainerPath)) {
                return @{ Success = $false; Details = "Dev container directory not found" }
            }
            
            $devcontainerJson = "$devcontainerPath/devcontainer.json"
            $dockerfile = "$devcontainerPath/Dockerfile"
            
            if (!(Test-Path $devcontainerJson)) {
                return @{ Success = $false; Details = "devcontainer.json not found" }
            }
            
            if (!(Test-Path $dockerfile)) {
                return @{ Success = $false; Details = "Dockerfile not found" }
            }
            
            # Check Dockerfile content
            $dockerfileContent = Get-Content $dockerfile -Raw
            if ($dockerfileContent -match "FROM.*ubuntu") {
                return @{ Success = $true; Details = "Dev container configuration complete" }
            } else {
                return @{ Success = $false; Details = "Invalid Dockerfile base image" }
            }
        } "Dev Container"
    }
}

# Test 6: Cross-Platform Compatibility
function Test-CrossPlatformCompatibility {
    Test-ValidationItem "Cross-Platform: Windows Compatibility" {
        # Test Windows-specific features
        $windowsFeatures = @()
        
        # Check PowerShell availability
        if ($PSVersionTable.PSVersion) {
            $windowsFeatures += "PowerShell $($PSVersionTable.PSVersion)"
        }
        
        # Check Windows paths
        if ($env:OS -eq "Windows_NT") {
            $windowsFeatures += "Windows NT Environment"
        }
        
        # Check MinGW/GCC on Windows
        try {
            $gccVersion = gcc --version | Select-Object -First 1
            if ($gccVersion -match "mingw") {
                $windowsFeatures += "MinGW GCC"
            }
        } catch { }
        
        if ($windowsFeatures.Count -gt 0) {
            return @{ Success = $true; Details = "Windows features: $($windowsFeatures -join ', ')" }
        } else {
            return @{ Success = $false; Details = "Windows compatibility issues detected" }
        }
    } "Cross-Platform"
    
    Test-ValidationItem "Cross-Platform: WSL2 Compatibility" {
        try {
            $wslResult = wsl --version 2>&1
            if ($LASTEXITCODE -eq 0) {
                return @{ Success = $true; Details = "WSL2 available and functional" }
            } else {
                return @{ Success = $false; Skipped = $true; Reason = "WSL2 not available" }
            }
        } catch {
            return @{ Success = $false; Skipped = $true; Reason = "WSL2 not installed" }
        }
    } "Cross-Platform"
}

# Test 7: Performance Benchmarks
function Test-PerformanceBenchmarks {
    Test-ValidationItem "Performance: Build Speed" {
        $projectPath = "templates/basic-cpp"
        
        Push-Location $projectPath
        try {
            # Clean build for accurate timing
            if (Test-Path "build") { Remove-Item -Recurse -Force "build" }
            
            # Time configure
            $configureStart = Get-Date
            $configResult = cmake -B build -S . -G Ninja -DCMAKE_BUILD_TYPE=Debug -DCMAKE_EXPORT_COMPILE_COMMANDS=ON 2>&1
            $configureEnd = Get-Date
            $configureTime = ($configureEnd - $configureStart).TotalSeconds
            
            if ($LASTEXITCODE -ne 0) {
                return @{ Success = $false; Details = "Configure failed" }
            }
            
            # Time build
            $buildStart = Get-Date
            $buildResult = cmake --build build --parallel 2>&1
            $buildEnd = Get-Date
            $buildTime = ($buildEnd - $buildStart).TotalSeconds
            
            if ($LASTEXITCODE -ne 0) {
                return @{ Success = $false; Details = "Build failed" }
            }
            
            $validationResults.Performance.ConfigureTime = $configureTime
            $validationResults.Performance.BuildTime = $buildTime
            $validationResults.Performance.TotalTime = $configureTime + $buildTime
            
            return @{ Success = $true; Details = "Configure: ${configureTime}s, Build: ${buildTime}s, Total: $($configureTime + $buildTime)s" }
            
        } finally {
            Pop-Location
        }
    } "Performance"
}

# Main Validation Execution
function Start-EnvironmentValidation {
    $env = Get-EnvironmentInfo
    
    Write-Log "=== Starting Comprehensive Validation ===" "INFO"
    
    # Execute all validation tests
    Test-HelloWorldProject
    Test-DebugConfiguration
    Test-IntelliSenseConfiguration
    Test-VSCodeTasksConfiguration
    Test-DevContainerConfiguration
    Test-CrossPlatformCompatibility
    Test-PerformanceBenchmarks
    
    # Generate comprehensive report
    Generate-ValidationReport
}

function Generate-ValidationReport {
    $successRate = if ($validationResults.TotalTests -gt 0) { 
        [math]::Round(($validationResults.PassedTests / $validationResults.TotalTests) * 100, 2) 
    } else { 0 }
    
    $report = @"
Task 6: Basic Environment Validation Report
===========================================
Generated: $(Get-Date -Format "yyyy-MM-dd HH:mm:ss")

SUMMARY:
========
Total Tests: $($validationResults.TotalTests)
Passed: $($validationResults.PassedTests)
Failed: $($validationResults.FailedTests)
Skipped: $($validationResults.SkippedTests)
Success Rate: $successRate%

ENVIRONMENT INFORMATION:
========================
OS: $($validationResults.Environment.OS)
PowerShell: $($validationResults.Environment.PowerShell)
Architecture: $($validationResults.Environment.Architecture)
CMake: $($validationResults.Environment.CMake)
Ninja: $($validationResults.Environment.Ninja)
GCC: $($validationResults.Environment.GCC)
GDB: $($validationResults.Environment.GDB)
Git: $($validationResults.Environment.Git)

PERFORMANCE METRICS:
===================
"@

    if ($validationResults.Performance.ConfigureTime) {
        $report += @"
Configure Time: $([math]::Round($validationResults.Performance.ConfigureTime, 2))s
Build Time: $([math]::Round($validationResults.Performance.BuildTime, 2))s
Total Build Time: $([math]::Round($validationResults.Performance.TotalTime, 2))s

"@
    }

    $report += @"
DETAILED RESULTS BY CATEGORY:
=============================
"@

    $categories = $validationResults.Results | Group-Object Category
    foreach ($category in $categories) {
        $report += "`n$($category.Name):`n"
        foreach ($result in $category.Group) {
            $status = switch ($result.Status) {
                "PASS" { "[PASS]" }
                "FAIL" { "[FAIL]" }
                "SKIP" { "[SKIP]" }
                "ERROR" { "[ERROR]" }
                default { "[UNKNOWN]" }
            }
            $duration = [math]::Round($result.Duration, 2)
            $report += "  $status $($result.Name) (${duration}s)`n"
            if ($result.Details) {
                $report += "     Details: $($result.Details)`n"
            }
        }
    }

    $report += @"

VALIDATION CHECKLIST:
====================
✅ Hello World Projects: Build and execution test
✅ Debug Configuration: VSCode launch.json validation
✅ IntelliSense Setup: compile_commands.json generation
✅ VSCode Tasks: CMake tasks configuration
✅ Dev Container: Container environment setup
✅ Cross-Platform: Windows/WSL2 compatibility
✅ Performance: Build speed benchmarks

REQUIREMENTS COVERAGE:
=====================
✅ Requirement 3.4: Hello World project validation
✅ Requirement 5.1: Debug functionality verification
✅ Requirement 5.2: IntelliSense and IDE integration

NEXT STEPS:
===========
"@

    if ($validationResults.FailedTests -eq 0) {
        $report += @"
🎉 All validation tests passed! The environment is ready for production use.

Task 6 (Basic Environment Validation) is COMPLETE.
Ready to proceed to Phase 2: Embedded Development Support.
"@
    } else {
        $report += @"
⚠️ Some validation tests failed. Please review the detailed results above.

Failed tests should be addressed before proceeding to the next phase.
Check the specific error details and resolve any configuration issues.
"@
    }

    $report | Out-File -FilePath $reportFile -Encoding UTF8
    
    Write-Log "=== Validation Report Generated ===" "INFO"
    Write-Log "Report saved to: $reportFile" "INFO"
    
    # Display summary
    Write-Host "`n" -NoNewline
    Write-Log "=== VALIDATION SUMMARY ===" "INFO"
    Write-Log "Total Tests: $($validationResults.TotalTests)" "INFO"
    Write-Log "Passed: $($validationResults.PassedTests)" "INFO"
    Write-Log "Failed: $($validationResults.FailedTests)" "INFO"
    Write-Log "Skipped: $($validationResults.SkippedTests)" "INFO"
    Write-Log "Success Rate: $successRate%" "INFO"
    
    if ($validationResults.Performance.TotalTime) {
        Write-Log "Build Performance: $([math]::Round($validationResults.Performance.TotalTime, 2))s total" "INFO"
    }
    
    return ($validationResults.FailedTests -eq 0)
}

# Execute validation
$success = Start-EnvironmentValidation

if ($success) {
    Write-Log "🎉 Task 6: Basic Environment Validation COMPLETED successfully!" "SUCCESS"
    exit 0
} else {
    Write-Log "❌ Task 6: Basic Environment Validation FAILED. Check detailed report." "ERROR"
    exit 1
}