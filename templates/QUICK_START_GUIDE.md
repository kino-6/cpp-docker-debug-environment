# C++/Docker デバッグ環境 - クイックスタートガイド

## 🚀 概要

このプロジェクトは、C++開発から組み込み開発まで対応した包括的な開発環境です。Docker + VSCode + Dev Containerを使用して、一貫性のある高性能な開発体験を提供します。

## 📋 対応環境

### ✅ 完全対応済み
- **基本C++開発**: Hello World、Calculator、JSON Parser
- **ARM組み込み開発**: STM32F407VG、QEMU、リアルタイムシステム
- **テストフレームワーク**: Google Test、Unity/CMock
- **デバッグ環境**: GDB、VSCode統合、リモートデバッグ

### 🔄 開発中
- **複数アーキテクチャ**: RISC-V、AVR、ESP32
- **Autosar開発**: Classic/Adaptive Platform

## 🎯 5分で始める

### 1. 前提条件
```bash
# 必要なソフトウェア
- VSCode + Dev Containers拡張機能
- Docker Desktop
- Git
```

### 2. プロジェクト選択
```bash
# 基本C++開発
cd templates/basic-cpp

# 組み込み開発（推奨）
cd templates/embedded-arm

# 計算機ライブラリ
cd templates/calculator-cpp

# JSON処理
cd templates/json-parser-cpp
```

### 3. Dev Container起動
```bash
# VSCodeでフォルダを開く
code .

# コマンドパレット (Ctrl+Shift+P)
> Dev Containers: Reopen in Container
```

### 4. ビルド・実行
```bash
# VSCodeタスク (Ctrl+Shift+P)
> Tasks: Run Task > ARM: Fresh Configure & Build

# または直接実行
cmake -B build -S . -G Ninja
cmake --build build
```

## 🎯 プロジェクトタイプ別ガイド

### 基本C++開発
**対象**: C++学習、アルゴリズム開発、ライブラリ作成

```bash
cd templates/basic-cpp
code .
# Dev Container起動後
# F5でデバッグ実行
```

**特徴**:
- 高速ビルド（3秒以下）
- GDBデバッグ統合
- インタラクティブ入力対応

### ARM組み込み開発 ⭐ **推奨**
**対象**: 組み込みシステム、IoT、リアルタイム制御

```bash
cd templates/embedded-arm
code .
# Dev Container起動後
# Ctrl+Shift+P > Tasks: Run Task > System: Practical Test
```

**特徴**:
- ARM Cortex-M4対応
- QEMU実行環境
- リアルタイム割り込み
- UART/GPIO/Timer制御
- 状態機械実装

## 🔧 主要機能

### ビルドシステム
- **Ninja**: 最高速並列ビルド
- **CMake**: クロスプラットフォーム対応
- **自動最適化**: CPU数自動検出

### デバッグ環境
- **GDB統合**: ソースレベルデバッグ
- **VSCode統合**: ブレークポイント、変数監視
- **リモートデバッグ**: QEMU + GDB

### テスト環境
- **Google Test**: C++単体テスト
- **Unity**: C言語軽量テスト
- **モック**: HAL抽象化テスト

## 📊 パフォーマンス

| プロジェクト | ビルド時間 | 最適化率 |
|-------------|-----------|----------|
| Basic C++ | 3.04秒 | 83%高速化 |
| Calculator | 3.05秒 | 85%高速化 |
| JSON Parser | 10.15秒 | 88%高速化 |
| ARM Embedded | 5.2秒 | 90%高速化 |

## 🎯 使用例

### 1. LED制御（組み込み）
```c
// ARM Cortex-M4でのLED制御
led_init();
led_set(LED_GREEN | LED_BLUE);
delay(1000000);
```

### 2. リアルタイム状態機械
```c
// 5状態の状態機械
typedef enum {
    STATE_INIT,
    STATE_RUNNING,
    STATE_MONITORING,
    STATE_ERROR,
    STATE_SHUTDOWN
} system_state_t;
```

### 3. UART通信
```c
// フォーマット済みUART出力
uart_printf("System Status: %s, Uptime: %lu ms\n", 
           state_names[current_state], system_tick_ms);
```

## 🚨 トラブルシューティング

### よくある問題

#### 1. Dev Container起動失敗
```bash
# Docker Desktop起動確認
docker --version

# WSL2設定確認（Windows）
wsl --list --verbose
```

#### 2. ビルドエラー
```bash
# クリーンビルド
rm -rf build
cmake -B build -S . -G Ninja
```

#### 3. ARM実行エラー
```bash
# QEMU確認
qemu-system-arm --version

# 権限確認
ls -la /dev/kvm  # Linux
```

### サポートされる環境
- ✅ Windows 10/11 + WSL2
- ✅ macOS (Intel/Apple Silicon)
- ✅ Linux (Ubuntu 20.04+)

## 📚 詳細ドキュメント

- [ARM組み込み開発ガイド](templates/embedded-arm/README.md)
- [テストフレームワーク使用方法](templates/embedded-arm/tests/README.md)
- [VSCodeタスク設定](templates/VSCODE_TASKS.md)
- [パフォーマンス最適化](templates/PERFORMANCE.md)
- [Docker設定詳細](templates/DEVCONTAINER.md)

## 🎉 次のステップ

1. **基本習得**: `basic-cpp`で環境確認
2. **組み込み体験**: `embedded-arm`でリアルタイムシステム
3. **実用開発**: 独自プロジェクトの作成
4. **高度な機能**: 複数アーキテクチャ対応

---

**🚀 プロダクションレベルの開発環境で、効率的な開発を始めましょう！**