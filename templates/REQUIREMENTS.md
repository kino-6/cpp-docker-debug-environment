# System Requirements

## Minimum Requirements

### Software Dependencies

- **CMake**: 3.16 or higher
- **C++ Compiler**: One of the following:
  - GCC 9.0+ (Linux/Windows MinGW)
  - Clang 10.0+ (Linux/macOS/Windows)
  - MSVC 2019+ (Windows)
- **Build System**: One of the following:
  - Ninja (recommended for performance)
  - Make (Linux/macOS)
  - MSBuild (Windows with Visual Studio)

### Hardware Requirements

- **CPU**: Any modern x86_64 processor
- **Memory**: 4GB RAM minimum, 8GB+ recommended
- **Storage**: 1GB free space for build artifacts

## Recommended Setup

### For Optimal Performance

- **CPU**: 8+ cores (e.g., AMD Ryzen 7/9, Intel Core i7/i9)
- **Memory**: 16GB+ RAM
- **Storage**: NVMe SSD
- **Build System**: Ninja

### Operating System Support

- ✅ **Windows 10/11** (tested)
- ✅ **Linux** (Ubuntu 20.04+, CentOS 8+)
- ✅ **macOS** (10.15+)

## Installation Instructions

### Windows

#### Option 1: Using Chocolatey (Recommended)
```powershell
# Install Chocolatey if not already installed
Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))

# Install development tools
choco install cmake ninja llvm mingw

# Refresh environment variables
refreshenv
```

#### Option 2: Using winget
```powershell
# Install CMake
winget install Kitware.CMake

# Install Ninja (optional but recommended)
winget install Ninja-build.Ninja

# Install LLVM/Clang (recommended for best performance)
winget install LLVM.LLVM

# Install MinGW-w64 (alternative to MSVC)
winget install mingw-w64
```

### Linux (Ubuntu/Debian)

```bash
# Install build essentials
sudo apt update
sudo apt install build-essential cmake ninja-build

# For GCC latest
sudo apt install gcc-11 g++-11
```

### macOS

```bash
# Install Xcode Command Line Tools
xcode-select --install

# Install CMake and Ninja via Homebrew
brew install cmake ninja
```

## Template-Specific Requirements

### Basic C++ Template

- **Dependencies**: None (standard library only)
- **Build Time**: ~3 seconds
- **Memory Usage**: ~500MB during build

### Calculator C++ Template

- **Dependencies**: None (standard library only)
- **Build Time**: ~3 seconds
- **Memory Usage**: ~600MB during build

### JSON Parser C++ Template

- **Dependencies**: nlohmann/json (auto-downloaded)
- **Build Time**: ~10 seconds (first build), ~2 seconds (incremental)
- **Memory Usage**: ~1.5GB during build
- **Network**: Required for initial dependency download

## Troubleshooting

### Common Issues

#### CMake Not Found

```
Error: cmake: command not found
```

**Solution**: Install CMake and ensure it's in your PATH

#### Compiler Not Found

```
Error: No CMAKE_CXX_COMPILER could be found
```

**Solution**: Install a C++ compiler (GCC, Clang, or MSVC)

#### Ninja Not Found

```
Warning: Ninja not found, falling back to default generator
```

**Solution**: Install Ninja or use default generator (builds will be slower)

#### Memory Issues

```
Error: virtual memory exhausted
```

**Solution**: Reduce parallel jobs with `-Jobs 4` or add more RAM/swap

#### Network Issues (JSON Parser Template)

```
Error: Failed to download nlohmann/json
```

**Solution**: Check internet connection or use pre-installed nlohmann/json

### Performance Issues

#### Slow Build Times

1. **Install Ninja**: 60-70% faster than Make/MSBuild
2. **Use SSD**: Significantly faster I/O operations
3. **Increase RAM**: Reduce swapping during compilation
4. **Optimize Thread Count**: Use our auto-detection or manual tuning

#### High Memory Usage

1. **Reduce Parallel Jobs**: Use `-Jobs 4` instead of auto-detection
2. **Use Debug Build**: Less memory-intensive than Release builds
3. **Close Other Applications**: Free up system memory

## Verification

### Quick Test

```bash
# Test basic functionality
cd templates/basic-cpp
../build-scripts/fast-build.sh --clean
./build/bin/BasicCppProject
```

### Full Verification

```bash
# Test all templates
for template in basic-cpp calculator-cpp json-parser-cpp; do
    echo "Testing $template..."
    cd templates/$template
    ../build-scripts/fast-build.sh --clean
    cd ../..
done
```

## Support Matrix

| OS | Compiler | Build System | Status |
|----|----------|--------------|--------|
| Windows 11 | MinGW GCC 15.2 | Ninja | ✅ Tested |
| Windows 11 | MSVC 2022 | MSBuild | ✅ Tested |
| Windows 11 | Clang 21.1.0 | Ninja | ✅ Tested |
| Ubuntu 22.04 | GCC 11 | Ninja | ⚠️ Should work |
| macOS 13+ | Clang 14 | Ninja | ⚠️ Should work |

**Legend**:

- ✅ Fully tested and verified
- ⚠️ Expected to work but not tested
- ❌ Known issues or not supported
