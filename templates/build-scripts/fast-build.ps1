# Fast Build Script for C++ Templates
# This script optimizes build performance using Ninja and parallel compilation

param(
    [string]$ProjectPath = ".",
    [string]$BuildType = "RelWithDebInfo",
    [switch]$Clean = $false,
    [int]$Jobs = 0,
    [switch]$Benchmark = $false,
    [switch]$SaveLog = $false
)

# Performance measurement
$script:timings = @{}
$script:logEntries = @()

# Logging function
function Write-LogHost($message, $color = "White") {
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logEntry = "[$timestamp] $message"
    $script:logEntries += $logEntry
    Write-Host $message -ForegroundColor $color
}

# Performance measurement functions
function Start-Timer($name) {
    $script:timings[$name] = [System.Diagnostics.Stopwatch]::StartNew()
}

function Stop-Timer($name) {
    if ($script:timings.ContainsKey($name)) {
        $script:timings[$name].Stop()
        return $script:timings[$name].Elapsed
    }
    return $null
}

function Show-Timings {
    Write-LogHost "`n[PERF] Performance Report:" "Cyan"
    Write-LogHost ("=" * 50) "Cyan"
    
    $totalTime = [TimeSpan]::Zero
    foreach ($key in $script:timings.Keys | Sort-Object) {
        $elapsed = $script:timings[$key].Elapsed
        $totalTime = $totalTime.Add($elapsed)
        Write-LogHost "  $key`: $($elapsed.TotalSeconds.ToString('F2'))s" "Yellow"
    }
    Write-LogHost "  Total Time: $($totalTime.TotalSeconds.ToString('F2'))s" "Green"
    Write-LogHost ("=" * 50) "Cyan"
}

function Save-BuildLog {
    if ($SaveLog) {
        $logFileName = "build-log-$(Get-Date -Format 'yyyyMMdd-HHmmss').txt"
        $logPath = Join-Path $ProjectPath $logFileName
        
        $script:logEntries | Out-File -FilePath $logPath -Encoding UTF8
        Write-LogHost "[LOG] Build log saved to: $logFileName" "Green"
    }
}

# System information
# Set console encoding to UTF-8 to handle emojis properly
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8

Write-Host "[SYSTEM] System Information:" -ForegroundColor Cyan
$cpu = Get-WmiObject -Class Win32_Processor | Select-Object -First 1
Write-Host "  CPU: $($cpu.Name.Trim())"
Write-Host "  Cores: $($cpu.NumberOfCores) cores, $($cpu.NumberOfLogicalProcessors) threads"

# Detect optimal number of CPU cores if not specified
if ($Jobs -eq 0) {
    $physicalCores = (Get-WmiObject -Class Win32_Processor | Measure-Object -Property NumberOfCores -Sum).Sum
    $logicalCores = (Get-WmiObject -Class Win32_ComputerSystem).NumberOfLogicalProcessors
    $totalMemoryGB = [math]::Round((Get-WmiObject -Class Win32_ComputerSystem).TotalPhysicalMemory / 1GB, 1)
    
    # Optimal thread calculation based on CPU architecture and available memory
    # For compilation, physical cores + some hyperthreading is usually optimal
    # But we need to consider memory constraints (roughly 1GB per thread for C++)
    $memoryLimitedThreads = [math]::Floor($totalMemoryGB / 1.5)  # Conservative estimate
    $cpuOptimalThreads = [math]::Min($logicalCores, $physicalCores + [math]::Ceiling($physicalCores * 0.5))
    
    $Jobs = [math]::Min($memoryLimitedThreads, $cpuOptimalThreads)
    $Jobs = [math]::Max($Jobs, 1)  # Ensure at least 1 thread
    
    Write-Host "  Physical Cores: $physicalCores, Logical: $logicalCores"
    Write-Host "  Memory: $totalMemoryGB GB (limits to $memoryLimitedThreads threads)"
    Write-Host "  CPU optimal: $cpuOptimalThreads threads"
    Write-Host "  Selected: $Jobs parallel jobs" -ForegroundColor Green
}

# Check if Ninja is available
$ninjaAvailable = $false
try {
    ninja --version | Out-Null
    $ninjaAvailable = $true
    Write-LogHost "[OK] Ninja build system detected" "Green"
} catch {
    Write-LogHost "[WARN] Ninja not found, falling back to default generator" "Yellow"
}

# Set build directory
$buildDir = Join-Path $ProjectPath "build"

# Clean build if requested
if ($Clean -and (Test-Path $buildDir)) {
    Write-LogHost "[CLEAN] Cleaning build directory..." "Yellow"
    Start-Timer "Clean"
    Remove-Item -Recurse -Force $buildDir
    Stop-Timer "Clean" | Out-Null
}

# Create build directory
if (!(Test-Path $buildDir)) {
    New-Item -ItemType Directory -Path $buildDir | Out-Null
}

# Configure with optimal settings
Write-LogHost "[CONFIG] Configuring project..." "Cyan"
Start-Timer "Configure"

$configureArgs = @(
    "-S", $ProjectPath
    "-B", $buildDir
    "-DCMAKE_BUILD_TYPE=$BuildType"
    "-DCMAKE_EXPORT_COMPILE_COMMANDS=ON"
)

if ($ninjaAvailable) {
    $configureArgs += "-G", "Ninja"
    Write-Host "  Using Ninja generator"
} else {
    Write-Host "  Using default generator (Visual Studio)"
}

$configureProcess = Start-Process -FilePath "cmake" -ArgumentList $configureArgs -Wait -PassThru -NoNewWindow
Stop-Timer "Configure" | Out-Null

if ($configureProcess.ExitCode -ne 0) {
    Write-LogHost "[ERROR] Configuration failed with exit code: $($configureProcess.ExitCode)" "Red"
    Write-LogHost "[HINT] Check CMakeLists.txt syntax and dependencies" "Yellow"
    Save-BuildLog
    exit 1
}

# Build with parallel jobs
Write-LogHost "[BUILD] Building project with $Jobs parallel jobs..." "Cyan"
Start-Timer "Build"

$buildArgs = @(
    "--build", $buildDir
    "--config", $BuildType
    "--parallel", $Jobs
)

$buildProcess = Start-Process -FilePath "cmake" -ArgumentList $buildArgs -Wait -PassThru -NoNewWindow
Stop-Timer "Build" | Out-Null

if ($buildProcess.ExitCode -ne 0) {
    Write-LogHost "[ERROR] Build failed with exit code: $($buildProcess.ExitCode)" "Red"
    Write-LogHost "[HINT] Check compiler errors and source code syntax" "Yellow"
    Save-BuildLog
    exit 1
}

Write-LogHost "[SUCCESS] Build completed successfully!" "Green"

# Show build artifacts
$binDir = Join-Path $buildDir "bin"
if (Test-Path $binDir) {
    Write-LogHost "[ARTIFACTS] Build artifacts:" "Cyan"
    Get-ChildItem $binDir -File | ForEach-Object { Write-LogHost "  - $($_.Name)" "White" }
}

# Show performance report
Show-Timings

# Save log if requested
Save-BuildLog