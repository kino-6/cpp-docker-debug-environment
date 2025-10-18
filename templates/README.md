# C++ Project Templates

This directory contains project templates for C++ development with VSCode and Docker.

## Available Templates

### 1. Basic C++ Project (`basic-cpp/`)
- **Difficulty**: Beginner
- **Description**: Simple Hello World application
- **Features**:
  - Basic CMake configuration
  - GDB debugging support
  - Interactive console input

### 2. Calculator C++ Project (`calculator-cpp/`)
- **Difficulty**: Beginner
- **Description**: Calculator library with proper C++ project structure
- **Features**:
  - Header/source file separation
  - Static library creation
  - Error handling with exceptions
  - Interactive menu-driven interface

### 3. JSON Parser C++ Project (`json-parser-cpp/`)
- **Difficulty**: Intermediate
- **Description**: JSON parser demonstrating external library integration
- **Features**:
  - nlohmann/json library integration
  - CMake FetchContent for dependency management
  - File I/O operations
  - Interactive JSON parsing

## Template Structure

Each template contains:
- `README.md` - Template-specific documentation
- `src/` - Source code files
- `include/` - Header files (if applicable)
- `CMakeLists.txt` - CMake build configuration
- `data/` - Sample data files (if applicable)

## Usage

1. Copy the desired template to your project directory
2. Add the appropriate `.devcontainer/` and `.vscode/` configurations
3. Open in VSCode with Dev Containers extension
4. Start developing!

## Performance Benchmarks

Our templates are optimized for maximum build performance:

| Template | Build Time | Optimization |
|----------|------------|--------------|
| **Basic C++** | 3.04s | 83% faster than typical setup |
| **Calculator C++** | 3.05s | 85% faster than typical setup |
| **JSON Parser C++** | 10.15s | 88% faster than typical setup |

**Key Features**:
- 🚀 **Ninja build system** for maximum parallel efficiency
- 🧠 **Intelligent thread detection** (optimal for your CPU)
- ⚡ **RelWithDebInfo** builds (fast + debuggable)
- 📊 **Automatic performance logging**

*Benchmarked on AMD Ryzen 7 9800X3D. See [PERFORMANCE.md](PERFORMANCE.md) for detailed analysis.*

## Fast Build Usage

Use our optimized build scripts for maximum performance:

```powershell
# Windows PowerShell
./build-scripts/fast-build.ps1 -Clean -SaveLog

# Linux/macOS
./build-scripts/fast-build.sh --clean --jobs 0
```

## Next Steps

These templates will be enhanced with:
- Dev Container configurations (Phase 1, Task 2)
- Docker environment setup (Phase 1, Task 3)
- VSCode task configurations (Phase 1, Task 4)
- Debug configurations (Phase 1, Task 5)