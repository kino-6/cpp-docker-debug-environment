# Test Runner - Quick Start Guide

## 🚀 One-Command Testing

### Windows (PowerShell)
```powershell
# Run all tests
.\run-tests.ps1

# Quick smoke test (30 seconds)
.\run-tests.ps1 -Quick

# Full regression test (2 minutes)
.\run-tests.ps1 -Regression

# Docker environment test
.\run-tests.ps1 -Docker

# Dev Container configuration test
.\run-tests.ps1 -DevContainer

# Verbose output
.\run-tests.ps1 -Verbose

# Show help
.\run-tests.ps1 -Help
```

### Linux/macOS (Bash)
```bash
# Run all tests
./run-tests.sh

# Quick smoke test (30 seconds)
./run-tests.sh --quick

# Full regression test (2 minutes)
./run-tests.sh --regression

# Docker environment test
./run-tests.sh --docker

# Verbose output
./run-tests.sh --verbose

# Show help
./run-tests.sh --help
```

## 📊 Test Types

| Test Type | Duration | Description |
|-----------|----------|-------------|
| **Quick** | ~30s | Basic project structure and build test |
| **Regression** | ~2min | Full functionality test (all projects) |
| **Docker** | ~1min | WSL2/Linux environment test |
| **DevContainer** | ~30s | Dev Container configuration validation |

## 📁 Output

All test results are saved to `test-results/` directory:
- `test-summary.txt` - Overall test summary
- `*-report.txt` - Detailed test reports
- `*.log` - Detailed execution logs

## ✅ Expected Results

### Successful Run
```
[2025-10-18 14:05:00] [SUCCESS] 🎉 All tests completed successfully!

Test Results:
  Quick Tests: ✅ PASS (15s)
  Regression Tests: ✅ PASS (45s)
  Docker Tests: ✅ PASS (30s)
  Dev Container Tests: ✅ PASS (10s)

Overall Result: ✅ SUCCESS
```

### Prerequisites Check
The test runner automatically checks for:
- ✅ CMake (required for builds)
- ✅ Ninja (build system)
- ✅ GCC (compiler)
- ⚠️ WSL (for Docker tests)
- ⚠️ Docker (for container tests)

## 🔧 Troubleshooting

### Common Issues

#### 1. CMake not found
```bash
# Windows (with Chocolatey)
choco install cmake

# Linux (Ubuntu/Debian)
sudo apt install cmake

# macOS (with Homebrew)
brew install cmake
```

#### 2. Ninja not found
```bash
# Windows (with Chocolatey)
choco install ninja

# Linux (Ubuntu/Debian)
sudo apt install ninja-build

# macOS (with Homebrew)
brew install ninja
```

#### 3. GCC not found
```bash
# Windows (MinGW-w64)
choco install mingw

# Linux (Ubuntu/Debian)
sudo apt install build-essential

# macOS (Xcode Command Line Tools)
xcode-select --install
```

#### 4. WSL not available (Windows only)
```powershell
# Enable WSL2
wsl --install
```

### Test Failures

If tests fail, check the detailed reports in `test-results/`:
1. Look at `test-summary.txt` for overview
2. Check specific `*-report.txt` files for details
3. Review `*.log` files for execution details

## 🎯 CI/CD Integration

### GitHub Actions
```yaml
name: Test C++ Environment
on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Run Tests
        run: ./run-tests.sh --regression
```

### Jenkins
```groovy
pipeline {
    agent any
    stages {
        stage('Test') {
            steps {
                sh './run-tests.sh --regression'
            }
        }
    }
}
```

## 📋 What Gets Tested

### Quick Tests
- ✅ Project structure validation
- ✅ VSCode tasks.json files
- ✅ Basic CMake build

### Regression Tests
- ✅ All project builds (basic-cpp, calculator-cpp, json-parser-cpp)
- ✅ Application execution (CI/CD mode)
- ✅ compile_commands.json generation
- ✅ Error handling

### Docker Tests
- ✅ WSL2/Linux environment
- ✅ Build tools availability
- ✅ Cross-platform compatibility

### Dev Container Tests
- ✅ devcontainer.json validation
- ✅ Dockerfile validation
- ✅ VSCode integration settings

## 🎉 Success Criteria

All tests pass when:
- ✅ Projects build successfully
- ✅ Applications run without input waiting
- ✅ VSCode integration files are present
- ✅ Docker environment works correctly
- ✅ No critical errors in any component

---

**Quick Start**: Just run `.\run-tests.ps1` (Windows) or `./run-tests.sh` (Linux/macOS) and you're done! 🚀