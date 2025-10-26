# テストフレームワーク使用ガイド

## 🎯 概要

ARM組み込み開発環境では、2つの主要なテストフレームワークを提供しています：
- **Google Test**: C++向け高機能テストフレームワーク
- **Unity**: C言語向け軽量テストフレームワーク

## 🚀 クイックスタート

### Google Test（推奨）
```bash
# ネイティブテスト実行
# Ctrl+Shift+P > Tasks: Run Task > Test: Run Native Unit Tests

# 期待される結果
[==========] Running 20 tests from 4 test suites.
[  PASSED  ] 20 tests.
```

### Unity学習サンプル
```bash
# Unity軽量テスト実行
cd tests/unity_sample
./scripts/test-unity-sample.sh

# 期待される結果
Unity Test Summary: 6 Tests 0 Failures 0 Ignored
```

## 📁 テスト構造

```
tests/
├── unit/                   # Google Test ユニットテスト
│   ├── test_led.cpp       # LED制御テスト
│   ├── test_gpio.cpp      # GPIO制御テスト
│   ├── test_uart.cpp      # UART通信テスト
│   └── test_system.cpp    # システム制御テスト
├── integration/            # QEMU統合テスト
│   ├── practical_embedded_system.c
│   ├── simple_led_test.c
│   └── debug_test_program.c
├── mocks/                  # HALモック実装
│   ├── mock_gpio.c/h      # GPIOモック
│   ├── mock_uart.c/h      # UARTモック
│   ├── mock_timer.c/h     # Timerモック
│   └── mock_system.c/h    # システムモック
└── unity_sample/           # Unity学習サンプル
    ├── src/               # Unityテストソース
    ├── mocks/             # 手動モック実装
    └── scripts/           # 実行スクリプト
```

## 🧪 Google Test詳細

### 基本的なテスト作成

#### テストファイル例（test_led.cpp）
```cpp
#include <gtest/gtest.h>
#include "led.h"
#include "mock_gpio.h"

class LedTest : public ::testing::Test {
protected:
    void SetUp() override {
        mock_gpio_reset();
    }
    
    void TearDown() override {
        // クリーンアップ処理
    }
};

TEST_F(LedTest, InitializesGpioCorrectly) {
    led_init();
    
    EXPECT_EQ(1, mock_gpio_init_called);
    EXPECT_EQ(GPIO_MODE_OUTPUT, mock_gpio_last_mode);
    EXPECT_EQ(GPIOD_BASE, mock_gpio_last_base);
}

TEST_F(LedTest, SetLedControlsPins) {
    led_init();
    led_set(LED_GREEN | LED_RED);
    
    EXPECT_EQ(LED_GREEN | LED_RED, mock_gpio_last_value);
    EXPECT_EQ(1, mock_gpio_set_called);
}

TEST_F(LedTest, ToggleLedChangesState) {
    led_init();
    led_set(LED_GREEN);
    
    // 初期状態確認
    EXPECT_EQ(LED_GREEN, mock_gpio_last_value);
    
    // トグル実行
    led_toggle(LED_GREEN);
    EXPECT_EQ(0, mock_gpio_last_value);  // OFF
    
    led_toggle(LED_GREEN);
    EXPECT_EQ(LED_GREEN, mock_gpio_last_value);  // ON
}
```

### アサーション一覧

#### 基本アサーション
```cpp
// 等価性
EXPECT_EQ(expected, actual);      // ==
EXPECT_NE(val1, val2);           // !=
EXPECT_LT(val1, val2);           // <
EXPECT_LE(val1, val2);           // <=
EXPECT_GT(val1, val2);           // >
EXPECT_GE(val1, val2);           // >=

// 真偽値
EXPECT_TRUE(condition);
EXPECT_FALSE(condition);

// 浮動小数点
EXPECT_FLOAT_EQ(expected, actual);
EXPECT_DOUBLE_EQ(expected, actual);
EXPECT_NEAR(val1, val2, abs_error);
```

#### 文字列アサーション
```cpp
EXPECT_STREQ("expected", actual_c_string);
EXPECT_STRNE("not_expected", actual_c_string);
EXPECT_STRCASEEQ("Expected", actual_c_string);  // 大文字小文字無視
```

#### 例外アサーション
```cpp
EXPECT_THROW(statement, exception_type);
EXPECT_NO_THROW(statement);
EXPECT_ANY_THROW(statement);
```

### パラメータ化テスト

```cpp
class LedParameterizedTest : public ::testing::TestWithParam<uint32_t> {
protected:
    void SetUp() override {
        mock_gpio_reset();
        led_init();
    }
};

TEST_P(LedParameterizedTest, SetIndividualLeds) {
    uint32_t led_pin = GetParam();
    
    led_set(led_pin);
    EXPECT_EQ(led_pin, mock_gpio_last_value);
}

INSTANTIATE_TEST_SUITE_P(
    IndividualLeds,
    LedParameterizedTest,
    ::testing::Values(LED_GREEN, LED_ORANGE, LED_RED, LED_BLUE)
);
```

## 🔧 Unity詳細

### 基本的なテスト作成

#### テストファイル例（test_led_unity.c）
```c
#include "unity.h"
#include "led.h"
#include "mock_gpio.h"

void setUp(void) {
    mock_gpio_reset();
}

void tearDown(void) {
    // クリーンアップ処理
}

void test_led_init_configures_gpio(void) {
    led_init();
    
    TEST_ASSERT_EQUAL_INT(1, mock_gpio_init_called);
    TEST_ASSERT_EQUAL_INT(GPIO_MODE_OUTPUT, mock_gpio_last_mode);
    TEST_ASSERT_EQUAL_HEX32(GPIOD_BASE, mock_gpio_last_base);
}

void test_led_set_controls_pins(void) {
    led_init();
    led_set(LED_GREEN | LED_RED);
    
    TEST_ASSERT_EQUAL_HEX32(LED_GREEN | LED_RED, mock_gpio_last_value);
    TEST_ASSERT_EQUAL_INT(1, mock_gpio_set_called);
}

void test_led_toggle_changes_state(void) {
    led_init();
    led_set(LED_GREEN);
    
    // 初期状態確認
    TEST_ASSERT_EQUAL_HEX32(LED_GREEN, mock_gpio_last_value);
    
    // トグル実行
    led_toggle(LED_GREEN);
    TEST_ASSERT_EQUAL_HEX32(0, mock_gpio_last_value);
    
    led_toggle(LED_GREEN);
    TEST_ASSERT_EQUAL_HEX32(LED_GREEN, mock_gpio_last_value);
}
```

### Unityアサーション一覧

#### 基本アサーション
```c
// 真偽値
TEST_ASSERT_TRUE(condition);
TEST_ASSERT_FALSE(condition);
TEST_ASSERT(condition);  // TRUE と同じ

// NULL チェック
TEST_ASSERT_NULL(pointer);
TEST_ASSERT_NOT_NULL(pointer);

// 等価性
TEST_ASSERT_EQUAL_INT(expected, actual);
TEST_ASSERT_EQUAL_HEX32(expected, actual);
TEST_ASSERT_EQUAL_UINT32(expected, actual);
TEST_ASSERT_EQUAL_FLOAT(expected, actual);
```

#### 配列・メモリアサーション
```c
// 配列比較
TEST_ASSERT_EQUAL_INT_ARRAY(expected, actual, num_elements);
TEST_ASSERT_EQUAL_HEX8_ARRAY(expected, actual, num_elements);

// メモリ比較
TEST_ASSERT_EQUAL_MEMORY(expected, actual, len);

// 文字列比較
TEST_ASSERT_EQUAL_STRING(expected, actual);
TEST_ASSERT_EQUAL_STRING_LEN(expected, actual, len);
```

#### 範囲アサーション
```c
// 範囲チェック
TEST_ASSERT_INT_WITHIN(delta, expected, actual);
TEST_ASSERT_FLOAT_WITHIN(delta, expected, actual);

// 大小比較
TEST_ASSERT_GREATER_THAN(threshold, actual);
TEST_ASSERT_LESS_THAN(threshold, actual);
TEST_ASSERT_GREATER_OR_EQUAL(threshold, actual);
TEST_ASSERT_LESS_OR_EQUAL(threshold, actual);
```

## 🎭 モック実装

### HALモック設計原則

#### GPIO モック例（mock_gpio.c）
```c
#include "mock_gpio.h"

// モック状態変数
int mock_gpio_init_called = 0;
int mock_gpio_set_called = 0;
uint32_t mock_gpio_last_base = 0;
uint32_t mock_gpio_last_mode = 0;
uint32_t mock_gpio_last_value = 0;

void mock_gpio_reset(void) {
    mock_gpio_init_called = 0;
    mock_gpio_set_called = 0;
    mock_gpio_last_base = 0;
    mock_gpio_last_mode = 0;
    mock_gpio_last_value = 0;
}

// 実際のHAL関数をモック
void gpio_init(uint32_t gpio_base, uint32_t mode) {
    mock_gpio_init_called++;
    mock_gpio_last_base = gpio_base;
    mock_gpio_last_mode = mode;
}

void gpio_set(uint32_t gpio_base, uint32_t value) {
    mock_gpio_set_called++;
    mock_gpio_last_base = gpio_base;
    mock_gpio_last_value = value;
}
```

### 高度なモック機能

#### 戻り値制御
```c
// モック設定
static int mock_uart_send_return_value = 0;
static int mock_uart_send_call_count = 0;

void mock_uart_set_send_return_value(int return_value) {
    mock_uart_send_return_value = return_value;
}

int uart_send(const char* data, size_t len) {
    mock_uart_send_call_count++;
    // 実際の処理をシミュレート
    return mock_uart_send_return_value;
}
```

#### コールバック機能
```c
// コールバック型定義
typedef void (*mock_timer_callback_t)(void);
static mock_timer_callback_t mock_timer_callback = NULL;

void mock_timer_set_callback(mock_timer_callback_t callback) {
    mock_timer_callback = callback;
}

void mock_timer_trigger_interrupt(void) {
    if (mock_timer_callback) {
        mock_timer_callback();
    }
}
```

## 🎯 テスト戦略

### テストピラミッド

#### 1. ユニットテスト（70%）
- **対象**: 個別関数・モジュール
- **実行環境**: ネイティブ（x86_64）
- **特徴**: 高速、詳細、モック使用

```c
// 例：LED制御ロジックのテスト
void test_led_blink_pattern(void) {
    led_init();
    
    // Knight Riderパターンテスト
    for (int i = 0; i < 6; i++) {
        led_update_knight_rider();
        // 期待されるパターンを検証
    }
}
```

#### 2. 統合テスト（20%）
- **対象**: モジュール間連携
- **実行環境**: QEMU（ARM Cortex-M4）
- **特徴**: 実環境に近い、実際のハードウェア動作

```c
// 例：UART + LED連携テスト
void integration_test_uart_led_control(void) {
    system_init();
    
    // UARTコマンド送信
    uart_send_command("LED_ON GREEN");
    
    // LED状態確認（実際のGPIO制御）
    // QEMUで視覚的に確認可能
}
```

#### 3. システムテスト（10%）
- **対象**: システム全体
- **実行環境**: QEMU + 実機
- **特徴**: エンドツーエンド、実用シナリオ

```bash
# 例：実用的組み込みシステムテスト
./scripts/test-practical-system.sh

# 確認項目
# - リアルタイム割り込み動作
# - 状態機械遷移
# - UART通信
# - LED制御パターン
```

### テストカバレッジ

#### カバレッジ測定（Google Test）
```bash
# カバレッジ付きビルド
cmake -B build -S . -DCMAKE_BUILD_TYPE=Debug -DENABLE_COVERAGE=ON
cmake --build build

# テスト実行
./build/bin/UnitTestRunner

# カバレッジレポート生成
gcov build/CMakeFiles/EmbeddedArmProject.dir/src/*.gcno
lcov --capture --directory build --output-file coverage.info
genhtml coverage.info --output-directory coverage_report
```

#### カバレッジ目標
- **関数カバレッジ**: 90%以上
- **行カバレッジ**: 80%以上
- **分岐カバレッジ**: 70%以上

## 🚀 実行方法

### VSCodeタスク（推奨）
```bash
# Google Test実行
# Ctrl+Shift+P > Tasks: Run Task > Test: Run Native Unit Tests

# Unity実行
# Ctrl+Shift+P > Tasks: Run Task > Unity: Run Sample Tests

# 統合テスト実行
# Ctrl+Shift+P > Tasks: Run Task > System: Practical Test
```

### コマンドライン実行
```bash
# Google Test
cd tests
cmake -B build -S .
cmake --build build
./build/bin/UnitTestRunner

# Unity
cd tests/unity_sample
cmake -B build -S .
cmake --build build
./build/bin/UnityTestRunner

# 統合テスト
cd tests/integration
cmake -B build -S .
cmake --build build
qemu-system-arm -M netduinoplus2 -cpu cortex-m4 \
  -kernel build/bin/PracticalEmbeddedSystem.elf -nographic
```

## 🔍 デバッグ

### テストデバッグ
```bash
# VSCodeデバッグ
# F5でテストをデバッグ実行
# ブレークポイント設定可能

# GDBデバッグ
gdb ./build/bin/UnitTestRunner
(gdb) break test_led_init_configures_gpio
(gdb) run
(gdb) print mock_gpio_init_called
```

### 統合テストデバッグ
```bash
# QEMU + GDB
qemu-system-arm -M netduinoplus2 -cpu cortex-m4 \
  -kernel build/bin/test.elf \
  -nographic -gdb tcp::1234 -S &

gdb-multiarch build/bin/test.elf
(gdb) target remote localhost:1234
(gdb) break main
(gdb) continue
```

## 📊 テスト結果の解釈

### 成功例
```
[==========] Running 20 tests from 4 test suites.
[----------] Global test environment set-up.
[----------] 5 tests from LedTest
[ RUN      ] LedTest.InitializesGpioCorrectly
[       OK ] LedTest.InitializesGpioCorrectly (0 ms)
...
[----------] 5 tests from LedTest (2 ms total)
[==========] 20 tests from 4 test suites ran. (15 ms total)
[  PASSED  ] 20 tests.
```

### 失敗例と対処
```
[ RUN      ] LedTest.SetLedControlsPins
test_led.cpp:45: Failure
Expected equality of these values:
  LED_GREEN | LED_RED
    Which is: 0x3000
  mock_gpio_last_value
    Which is: 0x1000

# 対処方法
# 1. 期待値の確認
# 2. モック実装の確認
# 3. 実際の関数実装の確認
```

## 🎯 ベストプラクティス

### テスト作成指針
1. **1テスト1機能**: 1つのテストで1つの機能のみテスト
2. **独立性**: テスト間の依存関係を避ける
3. **再現性**: 何度実行しても同じ結果
4. **高速実行**: ユニットテストは1秒以内
5. **明確な命名**: テスト名で内容が分かる

### モック設計指針
1. **最小限の実装**: 必要な機能のみ実装
2. **状態管理**: モック状態のリセット機能
3. **検証可能**: 呼び出し回数・引数の記録
4. **実装同期**: 実際のHALと同じインターフェース

---

**🚀 効果的なテストで品質の高い組み込みソフトウェアを開発しましょう！**