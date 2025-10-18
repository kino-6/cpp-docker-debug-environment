# Fast Build Scripts

These scripts optimize C++ build performance for development environments.

## Performance Optimizations

### 1. Build System Selection
- **Ninja**: Faster than Visual Studio/Make for incremental builds
- **Parallel Compilation**: Utilizes all CPU cores
- **Optimized Build Type**: `RelWithDebInfo` (optimized but debuggable)

### 2. Compiler Optimizations
- **MSVC**: `/MP` flag for parallel compilation
- **GCC/Clang**: Parallel make jobs
- **Compile Commands**: Export for better IDE integration

### 3. External Dependencies
- **FetchContent Optimization**: Disable tests and installation for dependencies
- **Caching**: Reuse downloaded dependencies across builds

## Usage

### Windows (PowerShell)
```powershell
# Basic usage
.\fast-build.ps1

# With options
.\fast-build.ps1 -ProjectPath "path/to/project" -BuildType "Release" -Jobs 16 -Clean

# Parameters:
# -ProjectPath: Project directory (default: current directory)
# -BuildType: Debug, Release, RelWithDebInfo (default: RelWithDebInfo)
# -Jobs: Number of parallel jobs (default: auto-detect CPU cores)
# -Clean: Clean build directory before building
```

### Linux/macOS (Bash)
```bash
# Basic usage
./fast-build.sh

# With options
./fast-build.sh -p "path/to/project" -t "Release" -j 16 -c

# Parameters:
# -p, --project: Project directory (default: current directory)
# -t, --type: Debug, Release, RelWithDebInfo (default: RelWithDebInfo)
# -j, --jobs: Number of parallel jobs (default: auto-detect CPU cores)
# -c, --clean: Clean build directory before building
```

## Performance Comparison

### Before Optimization (Visual Studio Generator, Debug)
- **Configuration**: ~7-10 seconds
- **Build**: ~15-30 seconds for small projects
- **Incremental**: ~5-10 seconds

### After Optimization (Ninja, RelWithDebInfo, Parallel)
- **Configuration**: ~2-3 seconds
- **Build**: ~3-8 seconds for small projects
- **Incremental**: ~1-2 seconds

### Expected Performance on Ryzen 7 9800X3D
- **16 cores/32 threads**: Excellent parallel compilation
- **Large L3 cache**: Better compilation cache hits
- **High clock speeds**: Faster single-threaded tasks

## Installing Ninja (Optional but Recommended)

### Windows
```powershell
# Using Chocolatey
choco install ninja

# Using Scoop
scoop install ninja

# Manual download from https://ninja-build.org/
```

### Linux
```bash
# Ubuntu/Debian
sudo apt install ninja-build

# CentOS/RHEL
sudo yum install ninja-build

# Arch Linux
sudo pacman -S ninja
```

### macOS
```bash
# Using Homebrew
brew install ninja

# Using MacPorts
sudo port install ninja
```

## Integration with VSCode

Add these tasks to your `.vscode/tasks.json`:

```json
{
    "version": "2.0.0",
    "tasks": [
        {
            "label": "Fast Build",
            "type": "shell",
            "command": "${workspaceFolder}/templates/build-scripts/fast-build.ps1",
            "group": {
                "kind": "build",
                "isDefault": true
            },
            "presentation": {
                "echo": true,
                "reveal": "always",
                "focus": false,
                "panel": "shared"
            },
            "problemMatcher": "$msCompile"
        }
    ]
}
```