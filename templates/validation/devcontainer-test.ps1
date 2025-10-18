# Dev Container Test Script
param(
    [string]$ProjectName = "basic-cpp",
    [string]$OutputDir = "templates/validation/test-results"
)

$ErrorActionPreference = "Continue"

if (!(Test-Path $OutputDir)) { New-Item -ItemType Directory -Path $OutputDir -Force | Out-Null }

$logFile = Join-Path $OutputDir "devcontainer-test.log"
$reportFile = Join-Path $OutputDir "devcontainer-test-report.txt"

function Write-Log {
    param([string]$Message, [string]$Level = "INFO")
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logMessage = "[$timestamp] [$Level] $Message"
    Write-Host $logMessage
    Add-Content -Path $logFile -Value $logMessage
}

Write-Log "=== Dev Container Test Started ===" "INFO"
Write-Log "Project: $ProjectName" "INFO"

$testResults = @{
    TotalTests = 0
    PassedTests = 0
    FailedTests = 0
    Results = @()
}

function Test-DevContainer {
    param([string]$Project)
    
    $projectPath = "templates/$Project"
    if (!(Test-Path $projectPath)) {
        Write-Log "Project directory not found: $projectPath" "ERROR"
        return $false
    }
    
    $devcontainerPath = "$projectPath/.devcontainer"
    if (!(Test-Path $devcontainerPath)) {
        Write-Log "Dev container configuration not found: $devcontainerPath" "ERROR"
        return $false
    }
    
    Write-Log "Testing Dev Container configuration for: $Project" "INFO"
    
    # Check devcontainer.json
    $testResults.TotalTests++
    $devcontainerJson = "$devcontainerPath/devcontainer.json"
    if (Test-Path $devcontainerJson) {
        Write-Log "✅ PASS: devcontainer.json exists" "PASS"
        $testResults.PassedTests++
        $testResults.Results += "$Project devcontainer.json - PASS"
        
        # Validate JSON syntax
        try {
            $config = Get-Content $devcontainerJson | ConvertFrom-Json
            Write-Log "✅ PASS: devcontainer.json is valid JSON" "PASS"
            $testResults.PassedTests++
            $testResults.Results += "$Project JSON syntax - PASS"
            
            # Check required properties
            $testResults.TotalTests++
            if ($config.name) {
                Write-Log "✅ PASS: Container name defined: $($config.name)" "PASS"
                $testResults.PassedTests++
                $testResults.Results += "$Project container name - PASS"
            } else {
                Write-Log "❌ FAIL: Container name not defined" "FAIL"
                $testResults.FailedTests++
                $testResults.Results += "$Project container name - FAIL"
            }
            
        } catch {
            Write-Log "❌ FAIL: devcontainer.json syntax error: $($_.Exception.Message)" "FAIL"
            $testResults.FailedTests++
            $testResults.Results += "$Project JSON syntax - FAIL: $($_.Exception.Message)"
        }
        $testResults.TotalTests++
    } else {
        Write-Log "❌ FAIL: devcontainer.json not found" "FAIL"
        $testResults.FailedTests++
        $testResults.Results += "$Project devcontainer.json - FAIL"
    }
    
    # Check Dockerfile
    $testResults.TotalTests++
    $dockerfile = "$devcontainerPath/Dockerfile"
    if (Test-Path $dockerfile) {
        Write-Log "✅ PASS: Dockerfile exists" "PASS"
        $testResults.PassedTests++
        $testResults.Results += "$Project Dockerfile - PASS"
        
        # Check Dockerfile content
        $dockerfileContent = Get-Content $dockerfile -Raw
        if ($dockerfileContent -match "FROM.*ubuntu") {
            Write-Log "✅ PASS: Dockerfile uses Ubuntu base image" "PASS"
        } elseif ($dockerfileContent -match "FROM") {
            Write-Log "⚠️ INFO: Dockerfile uses non-Ubuntu base image" "INFO"
        } else {
            Write-Log "❌ FAIL: Dockerfile missing FROM instruction" "FAIL"
        }
        
    } else {
        Write-Log "❌ FAIL: Dockerfile not found" "FAIL"
        $testResults.FailedTests++
        $testResults.Results += "$Project Dockerfile - FAIL"
    }
    
    # Test Docker build (if Docker is available)
    $testResults.TotalTests++
    try {
        $dockerVersion = docker --version 2>$null
        if ($LASTEXITCODE -eq 0) {
            Write-Log "Docker available: $dockerVersion" "INFO"
            
            # Test Docker build
            Push-Location $projectPath
            try {
                Write-Log "Testing Docker build for $Project..." "INFO"
                $buildOutput = docker build -f .devcontainer/Dockerfile -t "test-$Project" . 2>&1
                if ($LASTEXITCODE -eq 0) {
                    Write-Log "✅ PASS: Docker build successful" "PASS"
                    $testResults.PassedTests++
                    $testResults.Results += "$Project Docker build - PASS"
                    
                    # Clean up test image
                    docker rmi "test-$Project" 2>$null | Out-Null
                } else {
                    Write-Log "❌ FAIL: Docker build failed" "FAIL"
                    Write-Log "Build output: $buildOutput" "ERROR"
                    $testResults.FailedTests++
                    $testResults.Results += "$Project Docker build - FAIL"
                }
            } finally {
                Pop-Location
            }
        } else {
            Write-Log "⚠️ SKIP: Docker not available, skipping build test" "SKIP"
            $testResults.Results += "$Project Docker build - SKIP: Docker not available"
        }
    } catch {
        Write-Log "⚠️ SKIP: Docker test failed: $($_.Exception.Message)" "SKIP"
        $testResults.Results += "$Project Docker build - SKIP: $($_.Exception.Message)"
    }
    
    return $true
}

# Test all projects with dev containers
$projects = @("basic-cpp", "calculator-cpp", "json-parser-cpp")

foreach ($project in $projects) {
    Write-Log "=== Testing $project ===" "INFO"
    Test-DevContainer $project
}

# Generate report
$successRate = if ($testResults.TotalTests -gt 0) { 
    [math]::Round(($testResults.PassedTests / $testResults.TotalTests) * 100, 2) 
} else { 0 }

$report = @"
Dev Container Test Report
=========================
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
Docker: $(try { docker --version } catch { "Not available" })
"@

$report | Out-File -FilePath $reportFile -Encoding UTF8

Write-Log "=== Dev Container Test Completed ===" "INFO"
Write-Log "Total: $($testResults.TotalTests), Passed: $($testResults.PassedTests), Failed: $($testResults.FailedTests)" "INFO"
Write-Log "Success Rate: $successRate%" "INFO"
Write-Log "Report saved to: $reportFile" "INFO"

if ($testResults.FailedTests -eq 0) {
    Write-Log "✅ All Dev Container tests passed!" "SUCCESS"
    exit 0
} else {
    Write-Log "❌ Some Dev Container tests failed!" "ERROR"
    exit 1
}