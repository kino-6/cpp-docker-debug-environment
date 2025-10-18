# ARM組み込み開発での実行環境オプション

## 🎯 概要

GoogleTest統合とテスト実行のため、複数の実行環境を提供します。

## 🚀 実行環境オプション

### 1. QEMUシミュレーション（フル機能テスト）

**用途**: 実際のARM Cortex-M4コードの実行とデバッグ
**対象**: ハードウェア依存コードのテスト

```bash
# 基本実行
qemu-system-arm -M netduinoplus2 -cpu cortex-m4 -kernel build/bin/EmbeddedArmProject.elf -nographic

# デバッグモード
qemu-system-arm -M netduinoplus2 -cpu cortex-m4 -kernel build/bin/EmbeddedArmProject.elf -nographic -gdb tcp::1234 -S

# セミホスティング対応（printf出力）
qemu-system-arm -M netduinoplus2 -cpu cortex-m4 -kernel build/bin/EmbeddedArmProject.elf -semihosting-config enable=on,target=native
```

**利点**:
- ✅ 実際のARM命令実行
- ✅ ハードウェアレジスタアクセス
- ✅ 割り込み処理テスト
- ✅ リアルタイム動作確認

**制限**:
- ⚠️ 完全なハードウェア互換性は限定的
- ⚠️ 一部ペリフェラルは未対応

### 2. ネイティブテスト（高速ユニットテスト）

**用途**: ビジネスロジックとアルゴリズムのテスト
**対象**: HAL抽象化されたコード

```bash
# x86_64でのネイティブ実行
gcc -DUNIT_TEST -Iinclude -Isrc/hal -Isrc/drivers src/test/*.c -o test_runner
./test_runner
```

**利点**:
- ✅ 高速実行（秒単位）
- ✅ 豊富なデバッグツール
- ✅ メモリリーク検出
- ✅ カバレッジ測定

**制限**:
- ❌ ハードウェア依存コードは未対応
- ❌ ARM固有の動作は検証不可

### 3. セミホスティング（printf出力対応）

**用途**: QEMUでのprintf出力とファイルI/O
**対象**: デバッグ出力が必要なテスト

```bash
# セミホスティング有効
qemu-system-arm -M netduinoplus2 -cpu cortex-m4 -kernel build/bin/EmbeddedArmProject.elf -semihosting-config enable=on,target=native -nographic
```

**利点**:
- ✅ printf出力がホストに表示
- ✅ ファイル読み書き可能
- ✅ テスト結果の出力

## 🎯 GoogleTest統合戦略

### Phase 1: ネイティブテスト環境
```
tests/
├── unit/                   # ネイティブ実行テスト
│   ├── test_led_logic.cpp  # LED制御ロジック
│   ├── test_gpio_mock.cpp  # GPIO抽象化テスト
│   └── test_system.cpp     # システム初期化テスト
└── integration/            # QEMU実行テスト
    ├── test_hardware.cpp   # ハードウェア統合テスト
    └── test_realtime.cpp   # リアルタイム動作テスト
```

### Phase 2: QEMU統合テスト
```bash
# QEMUでのGoogleTest実行
qemu-system-arm -M netduinoplus2 -cpu cortex-m4 -kernel build/bin/TestRunner.elf -semihosting-config enable=on,target=native -nographic
```

## 🔧 実装アプローチ

### 1. HAL抽象化レイヤー
```c
// hal_interface.h
#ifdef UNIT_TEST
    // モック実装
    #define GPIO_WRITE(pin, value) mock_gpio_write(pin, value)
#else
    // 実際のハードウェア実装
    #define GPIO_WRITE(pin, value) HAL_GPIO_WritePin(pin, value)
#endif
```

### 2. テスト実行環境の自動選択
```cmake
# CMakeLists.txt
if(UNIT_TEST)
    # ネイティブテスト用設定
    set(CMAKE_C_COMPILER gcc)
    add_definitions(-DUNIT_TEST)
else()
    # ARM実機/QEMU用設定
    set(CMAKE_C_COMPILER arm-none-eabi-gcc)
endif()
```

### 3. 統合テストスクリプト
```bash
#!/bin/bash
# run_all_tests.sh

echo "=== Running Native Unit Tests ==="
mkdir -p build-native
cmake -B build-native -DUNIT_TEST=ON
cmake --build build-native
./build-native/bin/UnitTestRunner

echo "=== Running QEMU Integration Tests ==="
mkdir -p build-arm
cmake -B build-arm -DUNIT_TEST=OFF
cmake --build build-arm
timeout 30s qemu-system-arm -M netduinoplus2 -cpu cortex-m4 -kernel build-arm/bin/IntegrationTestRunner.elf -semihosting-config enable=on,target=native -nographic
```

## 📊 テスト実行時間比較

| テスト種類 | 実行環境 | 実行時間 | カバレッジ |
|-----------|---------|---------|-----------|
| ユニットテスト | ネイティブ | 1-5秒 | 90%+ |
| 統合テスト | QEMU | 10-30秒 | 70%+ |
| ハードウェアテスト | 実機 | 30-60秒 | 100% |

## 🎉 期待される結果

### ネイティブテスト
```
[==========] Running 25 tests from 5 test suites.
[----------] Global test environment set-up.
[----------] 5 tests from LEDControlTest
[ RUN      ] LEDControlTest.InitializationTest
[       OK ] LEDControlTest.InitializationTest (0 ms)
...
[==========] 25 tests from 5 test suites ran. (15 ms total)
[  PASSED  ] 25 tests.
```

### QEMUテスト
```
QEMU ARM Cortex-M4 Test Runner
==============================
Running hardware integration tests...
✅ GPIO initialization test: PASSED
✅ LED blink test: PASSED
✅ System clock test: PASSED
✅ Interrupt handling test: PASSED

Test Summary: 4/4 tests passed
```

この戦略により、高速なユニットテストと確実なハードウェア統合テストの両方を実現できます。