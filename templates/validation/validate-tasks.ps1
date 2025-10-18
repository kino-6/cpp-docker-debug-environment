# VSCodeタスク設定検証スクリプト
# PowerShell版 - Windows環境用

param(
    [string]$TestProject = "basic-cpp",
    [string]$OutputDir = "test-results"
)

# 検証結果を格納する変数
$TestResults = @{
    Environment = @{}
    BasicTasks = @{}
    ErrorAnalysis = @{}
    FileGeneration = @{}
    Summary = @{
        TotalTests = 0
        PassedTests = 0
        FailedTests = 0
        Errors = @()
    }
}

# ログ関数
function Write-TestLog {
    param([string]$Message, [string]$Level = "INFO")
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logMessage = "[$timestamp] [$Level] $Message"
    Write-Host $logMessage
    $logPath = Join-Path $OutputDir "validation.log"
    Add-Content -Path $logPath -Value $logMessage
}

function Test-Command {
    param([string]$Command, [string]$TestName)
    $TestResults.Summary.TotalTests++
    
    try {
        Write-TestLog "Testing: $TestName"
        $result = Invoke-Expression $Command 2>&1
        $exitCode = $LASTEXITCODE
        
        if ($exitCode -eq 0) {
            Write-TestLog "✅ PASS: $TestName" "PASS"
            $TestResults.Summary.PassedTests++
            return @{ Status = "PASS"; Output = $result; ExitCode = $exitCode }
        } else {
            Write-TestLog "❌ FAIL: $TestName (Exit Code: $exitCode)" "FAIL"
            $TestResults.Summary.FailedTests++
            $TestResults.Summary.Errors += "$TestName failed with exit code $exitCode"
            return @{ Status = "FAIL"; Output = $result; ExitCode = $exitCode }
        }
    } catch {
        Write-TestLog "❌ ERROR: $TestName - $($_.Exception.Message)" "ERROR"
        $TestResults.Summary.FailedTests++
        $TestResults.Summary.Errors += "$TestName threw exception`: $($_.Exception.Message)"
        return @{ Status = "ERROR"; Output = $_.Exception.Message; ExitCode = -1 }
    }
}

function Test-FileExists {
    param([string]$FilePath, [string]$TestName)
    $TestResults.Summary.TotalTests++
    
    if (Test-Path $FilePath) {
        Write-TestLog "✅ PASS: $TestName - File exists: $FilePath" "PASS"
        $TestResults.Summary.PassedTests++
        return @{ Status = "PASS"; Path = $FilePath; Exists = $true }
    } else {
        Write-TestLog "❌ FAIL: $TestName - File not found: $FilePath" "FAIL"
        $TestResults.Summary.FailedTests++
        $TestResults.Summary.Errors += "$TestName`: File not found - $FilePath"
        return @{ Status = "FAIL"; Path = $FilePath; Exists = $false }
    }
}

# 出力ディレクトリの作成（絶対パスで作成）
$OutputDir = Join-Path (Get-Location) $OutputDir
if (!(Test-Path $OutputDir)) {
    New-Item -ItemType Directory -Path $OutputDir -Force | Out-Null
}

Write-TestLog "=== VSCode Tasks Validation Started ===" "INFO"
Write-TestLog "Test Project: $TestProject" "INFO"
Write-TestLog "Output Directory: $OutputDir" "INFO"

# 環境情報の収集
Write-TestLog "=== Environment Information ===" "INFO"
$TestResults.Environment.OS = (Get-WmiObject -Class Win32_OperatingSystem).Caption
$TestResults.Environment.PowerShellVersion = $PSVersionTable.PSVersion.ToString()
$TestResults.Environment.WorkingDirectory = Get-Location
$TestResults.Environment.DateTime = Get-Date -Format "yyyy-MM-dd HH:mm:ss"

# CMakeの確認
$cmakeResult = Test-Command "cmake --version" "CMake Installation"
$TestResults.Environment.CMake = $cmakeResult

# Ninjaの確認
$ninjaResult = Test-Command "ninja --version" "Ninja Installation"
$TestResults.Environment.Ninja = $ninjaResult

# GCCの確認
$gccResult = Test-Command "gcc --version" "GCC Installation"
$TestResults.Environment.GCC = $gccResult

# テストプロジェクトディレクトリに移動
$projectPath = "templates/$TestProject"
if (!(Test-Path $projectPath)) {
    Write-TestLog "❌ ERROR: Test project not found: $projectPath" "ERROR"
    exit 1
}

Push-Location $projectPath

try {
    # 1. VSCodeタスク設定ファイルの存在確認
    Write-TestLog "=== File Existence Tests ===" "INFO"
    $TestResults.FileGeneration.TasksJson = Test-FileExists ".vscode/tasks.json" "VSCode Tasks Configuration"
    
    # 2. CMake Configure テスト
    Write-TestLog "=== CMake Configure Test ===" "INFO"
    
    # 既存のbuildディレクトリをクリーンアップ
    if (Test-Path "build") {
        Remove-Item -Recurse -Force "build"
        Write-TestLog "Cleaned existing build directory" "INFO"
    }
    
    $configureResult = Test-Command "cmake -B build -S . -G Ninja -DCMAKE_BUILD_TYPE=Debug -DCMAKE_EXPORT_COMPILE_COMMANDS=ON" "CMake Configure"
    $TestResults.BasicTasks.CMakeConfigure = $configureResult
    
    # compile_commands.jsonの生成確認
    $TestResults.FileGeneration.CompileCommands = Test-FileExists "build/compile_commands.json" "compile_commands.json Generation"
    
    # CMakeCache.txtの生成確認
    $TestResults.FileGeneration.CMakeCache = Test-FileExists "build/CMakeCache.txt" "CMakeCache.txt Generation"
    
    # 3. CMake Build テスト
    Write-TestLog "=== CMake Build Test ===" "INFO"
    $buildResult = Test-Command "cmake --build build --config Debug --parallel" "CMake Build"
    $TestResults.BasicTasks.CMakeBuild = $buildResult
    
    # 実行ファイルの生成確認
    $executableName = "$TestProject"
    if ($IsWindows) { $executableName += ".exe" }
    $TestResults.FileGeneration.Executable = Test-FileExists "build/bin/$executableName" "Executable Generation"
    
    # 4. アプリケーション実行テスト
    Write-TestLog "=== Application Run Test ===" "INFO"
    if ($TestResults.FileGeneration.Executable.Status -eq "PASS") {
        $runResult = Test-Command "./build/bin/$executableName" "Application Execution"
        $TestResults.BasicTasks.ApplicationRun = $runResult
    } else {
        Write-TestLog "⚠️ SKIP: Application execution test (executable not found)" "SKIP"
        $TestResults.BasicTasks.ApplicationRun = @{ Status = "SKIP"; Output = "Executable not found"; ExitCode = -1 }
    }
    
    # 5. エラー解析テスト用のファイル準備
    Write-TestLog "=== Error Analysis Test Setup ===" "INFO"
    
    # エラーテストファイルをコピー
    $errorTestSource = "../../validation/error-test.cpp"
    $errorTestDest = "src/error-test.cpp"
    
    if (Test-Path $errorTestSource) {
        Copy-Item $errorTestSource $errorTestDest -Force
        Write-TestLog "Copied error test file to project" "INFO"
        
        # CMakeLists.txtにエラーテスト用のターゲットを追加
        $cmakeContent = Get-Content "CMakeLists.txt"
        $errorTargetLine = "add_executable(error-test src/error-test.cpp)"
        
        if ($cmakeContent -notcontains $errorTargetLine) {
            Add-Content "CMakeLists.txt" "`n# Error test target`n$errorTargetLine"
            Write-TestLog "Added error test target to CMakeLists.txt" "INFO"
        }
        
        # エラービルドテスト（失敗することを期待）
        Write-TestLog "=== Error Build Test (Expected to Fail) ===" "INFO"
        $errorBuildResult = Test-Command "cmake --build build --target error-test" "Error Build Test"
        
        # このテストは失敗することを期待するので、結果を反転
        if ($errorBuildResult.Status -eq "FAIL") {
            Write-TestLog "✅ PASS: Error build test correctly failed (as expected)" "PASS"
            $TestResults.ErrorAnalysis.ErrorDetection = @{ Status = "PASS"; Output = $errorBuildResult.Output }
            $TestResults.Summary.PassedTests++
            $TestResults.Summary.FailedTests--
        } else {
            Write-TestLog "❌ FAIL: Error build test should have failed but passed" "FAIL"
            $TestResults.ErrorAnalysis.ErrorDetection = @{ Status = "FAIL"; Output = "Build should have failed but passed" }
        }
        
        # エラー出力の解析
        $errorOutput = $errorBuildResult.Output -join "`n"
        $TestResults.ErrorAnalysis.ErrorOutput = $errorOutput
        
        # 特定のエラーパターンの検出
        $expectedErrors = @(
            "non_existent_header.h",
            "undefined_variable",
            "non_existent_function"
        )
        
        $detectedErrors = @()
        foreach ($error in $expectedErrors) {
            if ($errorOutput -match $error) {
                $detectedErrors += $error
                Write-TestLog "✅ Detected expected error: $error" "PASS"
            } else {
                Write-TestLog "❌ Expected error not detected: $error" "FAIL"
            }
        }
        
        $TestResults.ErrorAnalysis.DetectedErrors = $detectedErrors
        $TestResults.ErrorAnalysis.ExpectedErrors = $expectedErrors
        
    } else {
        Write-TestLog "⚠️ SKIP: Error analysis test (error-test.cpp not found)" "SKIP"
        $TestResults.ErrorAnalysis.ErrorDetection = @{ Status = "SKIP"; Output = "Error test file not found" }
    }
    
    # 6. Clean テスト
    Write-TestLog "=== CMake Clean Test ===" "INFO"
    $cleanResult = Test-Command "cmake --build build --target clean" "CMake Clean"
    $TestResults.BasicTasks.CMakeClean = $cleanResult
    
} finally {
    Pop-Location
}

# 結果の集計
$TestResults.Summary.SuccessRate = if ($TestResults.Summary.TotalTests -gt 0) { 
    [math]::Round(($TestResults.Summary.PassedTests / $TestResults.Summary.TotalTests) * 100, 2) 
} else { 0 }

# JSON形式でのレポート出力
$jsonReport = $TestResults | ConvertTo-Json -Depth 10
$jsonReport | Out-File -FilePath "$OutputDir/validation-report.json" -Encoding UTF8

# HTML形式でのレポート生成
$htmlReport = @"
<!DOCTYPE html>
<html>
<head>
    <title>VSCode Tasks Validation Report</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 20px; }
        .header { background-color: #f0f0f0; padding: 20px; border-radius: 5px; }
        .summary { background-color: #e8f5e8; padding: 15px; border-radius: 5px; margin: 20px 0; }
        .error { background-color: #ffe8e8; padding: 15px; border-radius: 5px; margin: 20px 0; }
        .test-section { margin: 20px 0; }
        .test-item { margin: 10px 0; padding: 10px; border-left: 4px solid #ccc; }
        .pass { border-left-color: #4CAF50; background-color: #f8fff8; }
        .fail { border-left-color: #f44336; background-color: #fff8f8; }
        .skip { border-left-color: #ff9800; background-color: #fffaf8; }
        table { border-collapse: collapse; width: 100%; }
        th, td { border: 1px solid #ddd; padding: 8px; text-align: left; }
        th { background-color: #f2f2f2; }
        pre { background-color: #f5f5f5; padding: 10px; border-radius: 3px; overflow-x: auto; }
    </style>
</head>
<body>
    <div class="header">
        <h1>VSCode Tasks Validation Report</h1>
        <p><strong>Generated:</strong> $($TestResults.Environment.DateTime)</p>
        <p><strong>Test Project:</strong> $TestProject</p>
        <p><strong>OS:</strong> $($TestResults.Environment.OS)</p>
    </div>
    
    <div class="summary">
        <h2>Summary</h2>
        <table>
            <tr><th>Total Tests</th><td>$($TestResults.Summary.TotalTests)</td></tr>
            <tr><th>Passed</th><td style="color: green;">$($TestResults.Summary.PassedTests)</td></tr>
            <tr><th>Failed</th><td style="color: red;">$($TestResults.Summary.FailedTests)</td></tr>
            <tr><th>Success Rate</th><td>$($TestResults.Summary.SuccessRate)%</td></tr>
        </table>
    </div>
    
    <div class="test-section">
        <h2>Environment Tests</h2>
        <div class="test-item $($TestResults.Environment.CMake.Status.ToLower())">
            <strong>CMake:</strong> $($TestResults.Environment.CMake.Status)
        </div>
        <div class="test-item $($TestResults.Environment.Ninja.Status.ToLower())">
            <strong>Ninja:</strong> $($TestResults.Environment.Ninja.Status)
        </div>
        <div class="test-item $($TestResults.Environment.GCC.Status.ToLower())">
            <strong>GCC:</strong> $($TestResults.Environment.GCC.Status)
        </div>
    </div>
    
    <div class="test-section">
        <h2>Basic Tasks Tests</h2>
        <div class="test-item $($TestResults.BasicTasks.CMakeConfigure.Status.ToLower())">
            <strong>CMake Configure:</strong> $($TestResults.BasicTasks.CMakeConfigure.Status)
        </div>
        <div class="test-item $($TestResults.BasicTasks.CMakeBuild.Status.ToLower())">
            <strong>CMake Build:</strong> $($TestResults.BasicTasks.CMakeBuild.Status)
        </div>
        <div class="test-item $($TestResults.BasicTasks.ApplicationRun.Status.ToLower())">
            <strong>Application Run:</strong> $($TestResults.BasicTasks.ApplicationRun.Status)
        </div>
        <div class="test-item $($TestResults.BasicTasks.CMakeClean.Status.ToLower())">
            <strong>CMake Clean:</strong> $($TestResults.BasicTasks.CMakeClean.Status)
        </div>
    </div>
    
    <div class="test-section">
        <h2>File Generation Tests</h2>
        <div class="test-item $($TestResults.FileGeneration.TasksJson.Status.ToLower())">
            <strong>tasks.json:</strong> $($TestResults.FileGeneration.TasksJson.Status)
        </div>
        <div class="test-item $($TestResults.FileGeneration.CompileCommands.Status.ToLower())">
            <strong>compile_commands.json:</strong> $($TestResults.FileGeneration.CompileCommands.Status)
        </div>
        <div class="test-item $($TestResults.FileGeneration.Executable.Status.ToLower())">
            <strong>Executable:</strong> $($TestResults.FileGeneration.Executable.Status)
        </div>
    </div>
    
    <div class="test-section">
        <h2>Error Analysis Tests</h2>
        <div class="test-item $($TestResults.ErrorAnalysis.ErrorDetection.Status.ToLower())">
            <strong>Error Detection:</strong> $($TestResults.ErrorAnalysis.ErrorDetection.Status)
        </div>
        <p><strong>Expected Errors:</strong> $($TestResults.ErrorAnalysis.ExpectedErrors -join ', ')</p>
        <p><strong>Detected Errors:</strong> $($TestResults.ErrorAnalysis.DetectedErrors -join ', ')</p>
    </div>
"@

if ($TestResults.Summary.Errors.Count -gt 0) {
    $htmlReport += @"
    <div class="error">
        <h2>Errors</h2>
        <ul>
"@
    foreach ($error in $TestResults.Summary.Errors) {
        $htmlReport += "            <li>$error</li>`n"
    }
    $htmlReport += @"
        </ul>
    </div>
"@
}

$htmlReport += @"
</body>
</html>
"@

$htmlReport | Out-File -FilePath "$OutputDir/validation-report.html" -Encoding UTF8

# コンソール出力での最終結果
Write-TestLog "=== Validation Completed ===" "INFO"
Write-TestLog "Total Tests: $($TestResults.Summary.TotalTests)" "INFO"
Write-TestLog "Passed: $($TestResults.Summary.PassedTests)" "INFO"
Write-TestLog "Failed: $($TestResults.Summary.FailedTests)" "INFO"
Write-TestLog "Success Rate: $($TestResults.Summary.SuccessRate)%" "INFO"
Write-TestLog "Reports generated in: $OutputDir" "INFO"

if ($TestResults.Summary.FailedTests -gt 0) {
    Write-TestLog "❌ Some tests failed. Check the detailed report." "ERROR"
    exit 1
} else {
    Write-TestLog "✅ All tests passed!" "SUCCESS"
    exit 0
}