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

## 🎯 ARM組み込み開発環境 ⭐ **NEW!**

### 4. ARM Embedded Project (`embedded-arm/`) ⭐ **推奨**
- **Difficulty**: Intermediate-Advanced
- **Description**: 本格的なARM Cortex-M4組み込み開発環境
- **Features**:
  - ARM Cortex-M4 (STM32F407VG) 対応
  - QEMU実行環境 + GDBデバッグ
  - リアルタイム割り込みシステム
  - UART/GPIO/Timer制御
  - Google Test + Unity テストフレームワーク
  - 状態機械実装
  - セミホスティング出力

**プロダクションレベルの組み込み開発が可能です！**

## 📚 詳細ドキュメント

- **[🚀 クイックスタートガイド](QUICK_START_GUIDE.md)** - 5分で始める開発環境
- **[🔧 ARM組み込み開発ガイド](embedded-arm/EMBEDDED_DEVELOPMENT_GUIDE.md)** - 組み込み開発の詳細
- **[📋 ベストプラクティス](BEST_PRACTICES.md)** - 効率的な開発手法
- **[🚨 トラブルシューティング](TROUBLESHOOTING.md)** - 問題解決ガイド
- **[🧪 テストフレームワーク](embedded-arm/tests/README.md)** - テスト環境の使用方法

## 🎯 対応環境

### ✅ 完全対応済み
- **基本C++開発**: Hello World、Calculator、JSON Parser
- **ARM組み込み開発**: STM32F407VG、QEMU、リアルタイムシステム
- **テストフレームワーク**: Google Test、Unity/CMock
- **デバッグ環境**: GDB、VSCode統合、リモートデバッグ
- **クロスプラットフォーム**: Windows/Linux/macOS

### 🔄 開発中
- **複数アーキテクチャ**: RISC-V、AVR、ESP32
- **Autosar開発**: Classic/Adaptive Platform

## Next Steps

✅ **完了済み**:
- Dev Container configurations
- Docker environment setup  
- VSCode task configurations
- Debug configurations
- ARM embedded development environment
- Test frameworks integration
- Comprehensive documentation