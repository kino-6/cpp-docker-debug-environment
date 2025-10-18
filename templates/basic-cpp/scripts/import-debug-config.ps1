# C++ Debug Configuration Import Script (PowerShell)
# このスクリプトは既存のC++プロジェクトにデバッグ設定をインポートします

param(
    [string]$Environment = "auto"
)

# Colors for output
$Red = "`e[31m"
$Green = "`e[32m"
$Yellow = "`e[33m"
$Blue = "`e[34m"
$Reset = "`e[0m"

function Write-ColorOutput {
    param([string]$Color, [string]$Message)
    Write-Host "$Color$Message$Reset"
}

Write-ColorOutput $Blue "🚀 C++ Debug Configuration Import Tool"
Write-Host "=================================================="

# Get script directory
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$TemplateDir = Split-Path -Parent $ScriptDir

# Check if we're in a valid project directory
if (-not (Test-Path "CMakeLists.txt") -and -not (Test-Path "Makefile") -and -not (Test-Path "src")) {
    Write-ColorOutput $Red "❌ Error: This doesn't appear to be a C++ project directory"
    Write-Host "   Please run this script from your C++ project root directory"
    Write-Host "   (should contain CMakeLists.txt, Makefile, or src/ directory)"
    exit 1
}

Write-ColorOutput $Green "✅ C++ project detected"

# Create .vscode directory if it doesn't exist
if (-not (Test-Path ".vscode")) {
    Write-ColorOutput $Yellow "📁 Creating .vscode directory..."
    New-Item -ItemType Directory -Path ".vscode" | Out-Null
}

# Backup existing configuration
$BackupDir = ".vscode/backup-$(Get-Date -Format 'yyyyMMdd-HHmmss')"
$HasExistingConfig = (Test-Path ".vscode/launch.json") -or (Test-Path ".vscode/tasks.json")

if ($HasExistingConfig) {
    Write-ColorOutput $Yellow "💾 Backing up existing configuration to $BackupDir"
    New-Item -ItemType Directory -Path $BackupDir -Force | Out-Null
    
    if (Test-Path ".vscode/launch.json") { Copy-Item ".vscode/launch.json" $BackupDir }
    if (Test-Path ".vscode/tasks.json") { Copy-Item ".vscode/tasks.json" $BackupDir }
    if (Test-Path ".vscode/settings.json") { Copy-Item ".vscode/settings.json" $BackupDir }
}

# Recommend Dev Container approach
Write-ColorOutput $Blue "🐳 This configuration is optimized for Dev Container development"
Write-ColorOutput $Green "✅ Recommended: Use Dev Container for consistent cross-platform experience"
Write-Host ""
Write-Host "Choose your development approach:"
Write-Host "1) 🐳 Dev Container (Recommended) - Consistent, cross-platform"
Write-Host "2) 🖥️  Native Development - Local tools required"
Write-Host "3) 🤖 Auto-detect environment"

$Choice = Read-Host "Enter choice (1-3)"
switch ($Choice) {
    "1" { 
        $Environment = "container"
        Write-ColorOutput $Green "🐳 Dev Container selected"
    }
    "2" { 
        $Environment = "native"
        Write-ColorOutput $Yellow "🖥️  Native development selected"
        Write-ColorOutput $Yellow "⚠️  Note: Requires local GDB, CMake, and compiler installation"
    }
    "3" {
        # Auto-detection logic
        if (Test-Path ".devcontainer/devcontainer.json") {
            $Environment = "container"
            Write-ColorOutput $Green "🐳 Dev Container environment detected"
        } elseif ($env:OS -eq "Windows_NT") {
            $Environment = "native"
            Write-ColorOutput $Green "🖥️  Windows environment detected"
        } else {
            $Environment = "container"
            Write-ColorOutput $Green "🐳 Defaulting to Dev Container (recommended)"
        }
    }
    default { 
        Write-ColorOutput $Red "Invalid choice, defaulting to Dev Container"
        $Environment = "container"
    }
}

# Copy appropriate configuration files
Write-ColorOutput $Blue "📋 Installing debug configuration for $Environment environment..."

if ($Environment -eq "container") {
    # Copy container configuration (default)
    Copy-Item "$TemplateDir/.vscode/launch.json" ".vscode/"
    Copy-Item "$TemplateDir/.vscode/tasks.json" ".vscode/"
    Write-ColorOutput $Green "✅ Dev Container debug configuration installed"
    Write-ColorOutput $Blue "📝 Usage:"
    Write-Host "   1. Reopen in Dev Container (Ctrl+Shift+P → 'Dev Containers: Reopen in Container')"
    Write-Host "   2. Run task: 'Fresh Configure & Build'"
    Write-Host "   3. Press F5 → Select 'Quick Debug (No Build)'"
} else {
    # Copy native configuration
    Copy-Item "$TemplateDir/.vscode/native/launch.json" ".vscode/"
    Copy-Item "$TemplateDir/.vscode/native/tasks.json" ".vscode/"
    Write-ColorOutput $Green "✅ Native debug configuration installed"
    Write-ColorOutput $Yellow "⚠️  Requirements: GDB, CMake, Ninja, C++ compiler"
    Write-ColorOutput $Blue "📝 Usage:"
    Write-Host "   1. Press Ctrl+Shift+B → Select 'CMake Build'"
    Write-Host "   2. Press F5 → Select 'Quick Debug (No Build)'"
}

# Copy devcontainer configuration if it doesn't exist
if ($Environment -eq "container" -and -not (Test-Path ".devcontainer")) {
    Write-ColorOutput $Yellow "🐳 Installing Dev Container configuration..."
    Copy-Item "$TemplateDir/.devcontainer" "./" -Recurse
    Write-ColorOutput $Green "✅ Dev Container configuration installed"
}

# Install README
Copy-Item "$TemplateDir/.vscode/README.md" ".vscode/"

# Project-specific adjustments
Write-ColorOutput $Blue "🔧 Adjusting configuration for your project..."

# Detect project name from directory or CMakeLists.txt
$ProjectName = Split-Path -Leaf (Get-Location)
if (Test-Path "CMakeLists.txt") {
    $CMakeContent = Get-Content "CMakeLists.txt"
    $ProjectLine = $CMakeContent | Where-Object { $_ -match "project\s*\(" } | Select-Object -First 1
    if ($ProjectLine) {
        $CMakeProject = ($ProjectLine -replace ".*project\s*\(\s*([^)]*)\s*\).*", '$1').Trim()
        if ($CMakeProject) {
            $ProjectName = $CMakeProject
        }
    }
}

Write-ColorOutput $Blue "📦 Detected project name: $ProjectName"

# Update configuration files with project name
(Get-Content ".vscode/launch.json") -replace "BasicCppProject", $ProjectName | Set-Content ".vscode/launch.json"
(Get-Content ".vscode/tasks.json") -replace "BasicCppProject", $ProjectName | Set-Content ".vscode/tasks.json"

Write-ColorOutput $Green "🎉 Debug configuration import completed!"
Write-Host ""
Write-ColorOutput $Blue "📋 Next Steps:"
if ($Environment -eq "container") {
    Write-Host "   1. 🐳 Reopen in Dev Container (Ctrl+Shift+P → 'Dev Containers: Reopen in Container')"
    Write-Host "   2. 🔧 Run 'Fresh Configure & Build' task"
    Write-Host "   3. 🎯 Set breakpoints and press F5 → 'Quick Debug (No Build)'"
    Write-Host ""
    Write-ColorOutput $Green "🎉 Enjoy consistent, cross-platform C++ debugging!"
} else {
    Write-Host "   1. 🔧 Install requirements: GDB, CMake, Ninja, C++ compiler"
    Write-Host "   2. 🏗️  Build project (Ctrl+Shift+B → 'CMake Build')"
    Write-Host "   3. 🎯 Set breakpoints and press F5 → 'Quick Debug (No Build)'"
    Write-Host ""
    Write-ColorOutput $Yellow "💡 Consider switching to Dev Container for easier setup!"
}
Write-Host ""
Write-ColorOutput $Yellow "💡 Tip: Check .vscode/README.md for detailed usage instructions"

if ($HasExistingConfig) {
    Write-ColorOutput $Blue "🔄 Restore backup: Copy-Item $BackupDir/* .vscode/"
}