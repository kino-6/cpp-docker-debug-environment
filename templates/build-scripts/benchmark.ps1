# Build Performance Benchmark Script
# Compares different build configurations and generators

param(
    [string]$ProjectPath = ".",
    [int]$Runs = 3
)

Write-Host "🏁 Build Performance Benchmark" -ForegroundColor Cyan
Write-Host "=" * 60 -ForegroundColor Cyan

# System information
$cpu = Get-WmiObject -Class Win32_Processor | Select-Object -First 1
$jobs = (Get-WmiObject -Class Win32_ComputerSystem).NumberOfLogicalProcessors
Write-Host "CPU: $($cpu.Name.Trim())"
Write-Host "Cores: $($cpu.NumberOfCores) cores, $($jobs) threads"
Write-Host "Runs per configuration: $Runs"
Write-Host ""

# Test configurations
$configurations = @(
    @{
        Name = "Visual Studio (Debug)"
        Generator = "Visual Studio 17 2022"
        BuildType = "Debug"
        UseNinja = $false
    },
    @{
        Name = "Visual Studio (RelWithDebInfo)"
        Generator = "Visual Studio 17 2022"
        BuildType = "RelWithDebInfo"
        UseNinja = $false
    },
    @{
        Name = "Ninja (Debug)"
        Generator = "Ninja"
        BuildType = "Debug"
        UseNinja = $true
    },
    @{
        Name = "Ninja (RelWithDebInfo)"
        Generator = "Ninja"
        BuildType = "RelWithDebInfo"
        UseNinja = $true
    }
)

# Check if Ninja is available
$ninjaAvailable = $false
try {
    ninja --version | Out-Null
    $ninjaAvailable = $true
} catch {
    Write-Host "⚠ Ninja not available, skipping Ninja tests" -ForegroundColor Yellow
    $configurations = $configurations | Where-Object { -not $_.UseNinja }
}

$results = @()

foreach ($config in $configurations) {
    Write-Host "🧪 Testing: $($config.Name)" -ForegroundColor Green
    
    $configTimes = @()
    $buildTimes = @()
    
    for ($run = 1; $run -le $Runs; $run++) {
        Write-Host "  Run $run/$Runs..." -NoNewline
        
        # Clean build directory
        $buildDir = Join-Path $ProjectPath "build-benchmark"
        if (Test-Path $buildDir) {
            Remove-Item -Recurse -Force $buildDir -ErrorAction SilentlyContinue
        }
        
        # Configure
        $configStart = Get-Date
        $configureArgs = @(
            "-S", $ProjectPath
            "-B", $buildDir
            "-DCMAKE_BUILD_TYPE=$($config.BuildType)"
            "-G", $config.Generator
        )
        
        $configureProcess = Start-Process -FilePath "cmake" -ArgumentList $configureArgs -Wait -PassThru -NoNewWindow -WindowStyle Hidden
        $configEnd = Get-Date
        $configTime = ($configEnd - $configStart).TotalSeconds
        
        if ($configureProcess.ExitCode -ne 0) {
            Write-Host " ❌ Configure failed" -ForegroundColor Red
            continue
        }
        
        # Build
        $buildStart = Get-Date
        $buildArgs = @(
            "--build", $buildDir
            "--config", $config.BuildType
            "--parallel", $jobs
        )
        
        $buildProcess = Start-Process -FilePath "cmake" -ArgumentList $buildArgs -Wait -PassThru -NoNewWindow -WindowStyle Hidden
        $buildEnd = Get-Date
        $buildTime = ($buildEnd - $buildStart).TotalSeconds
        
        if ($buildProcess.ExitCode -ne 0) {
            Write-Host " ❌ Build failed" -ForegroundColor Red
            continue
        }
        
        $configTimes += $configTime
        $buildTimes += $buildTime
        
        Write-Host " ✅ Config: $($configTime.ToString('F2'))s, Build: $($buildTime.ToString('F2'))s" -ForegroundColor Gray
    }
    
    if ($configTimes.Count -gt 0) {
        $avgConfigTime = ($configTimes | Measure-Object -Average).Average
        $avgBuildTime = ($buildTimes | Measure-Object -Average).Average
        $totalTime = $avgConfigTime + $avgBuildTime
        
        $results += [PSCustomObject]@{
            Configuration = $config.Name
            ConfigTime = $avgConfigTime
            BuildTime = $avgBuildTime
            TotalTime = $totalTime
        }
    }
    
    Write-Host ""
}

# Clean up benchmark build directory
$buildDir = Join-Path $ProjectPath "build-benchmark"
if (Test-Path $buildDir) {
    Remove-Item -Recurse -Force $buildDir -ErrorAction SilentlyContinue
}

# Display results
Write-Host "📊 Benchmark Results (Average of $Runs runs):" -ForegroundColor Cyan
Write-Host "=" * 80 -ForegroundColor Cyan

$results | Sort-Object TotalTime | Format-Table -Property @(
    @{Label="Configuration"; Expression={$_.Configuration}; Width=25},
    @{Label="Configure (s)"; Expression={$_.ConfigTime.ToString("F2")}; Width=15; Alignment="Right"},
    @{Label="Build (s)"; Expression={$_.BuildTime.ToString("F2")}; Width=12; Alignment="Right"},
    @{Label="Total (s)"; Expression={$_.TotalTime.ToString("F2")}; Width=12; Alignment="Right"},
    @{Label="Speedup"; Expression={
        $baseline = ($results | Sort-Object TotalTime -Descending | Select-Object -First 1).TotalTime
        if ($_.TotalTime -gt 0) { ($baseline / $_.TotalTime).ToString("F2") + "x" } else { "N/A" }
    }; Width=10; Alignment="Right"}
) -AutoSize

# Recommendations
$fastest = $results | Sort-Object TotalTime | Select-Object -First 1
if ($fastest) {
    Write-Host "🏆 Fastest Configuration: $($fastest.Configuration)" -ForegroundColor Green
    Write-Host "💡 Recommendation: Use this configuration for development builds" -ForegroundColor Yellow
}