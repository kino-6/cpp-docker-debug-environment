# 開発ベストプラクティス

## 🎯 概要

このドキュメントでは、C++/Docker デバッグ環境を使用した効率的な開発のためのベストプラクティスを説明します。

## 🚀 開発ワークフロー

### 1. プロジェクト開始時

#### ✅ 推奨手順
```bash
# 1. 適切なテンプレート選択
basic-cpp/      # C++学習・アルゴリズム開発
calculator-cpp/ # ライブラリ開発
json-parser-cpp/# 外部ライブラリ統合
embedded-arm/   # 組み込み・IoT開発 ⭐推奨

# 2. Dev Container起動
code templates/embedded-arm
# Ctrl+Shift+P > Dev Containers: Reopen in Container

# 3. 環境確認
# Ctrl+Shift+P > Tasks: Run Task > System: Practical Test
```

#### ❌ 避けるべき行動
- ❌ ローカル環境での直接開発（環境差異の原因）
- ❌ 複数テンプレートの混在使用
- ❌ Dev Container外でのビルド実行

### 2. 日常的な開発

#### ✅ 効率的な開発サイクル
```bash
# 1. 高速ビルド（3-5秒）
# Ctrl+Shift+P > Tasks: Run Task > ARM: Fresh Configure & Build

# 2. 即座にテスト
# F5でデバッグ実行
# または Ctrl+Shift+P > Tasks: Run Task > Test: Run Native Unit Tests

# 3. 継続的確認
# 変更後は必ずビルド・テスト実行
```

#### ✅ デバッグ効率化
```bash
# VSCode統合デバッグ（推奨）
F5                    # デバッグ開始
F9                    # ブレークポイント設定
F10                   # ステップオーバー
F11                   # ステップイン
Shift+F11            # ステップアウト

# QEMU + GDB（高度な用途）
# Ctrl+Shift+P > Tasks: Run Task > GDB: Debug Test
```

## 🔧 コーディング規約

### C++開発

#### ✅ 推奨スタイル
```cpp
// ヘッダーファイル (.h)
#pragma once
#include <vector>
#include <string>

namespace calculator {
    class Calculator {
    public:
        double add(double a, double b);
        double subtract(double a, double b);
        
    private:
        std::vector<double> history_;
    };
}

// 実装ファイル (.cpp)
#include "calculator.h"
#include <stdexcept>

namespace calculator {
    double Calculator::add(double a, double b) {
        double result = a + b;
        history_.push_back(result);
        return result;
    }
}
```

#### ❌ 避けるべきパターン
```cpp
// ❌ using namespace std; (ヘッダーファイル内)
// ❌ マクロの多用
// ❌ 例外処理の省略
// ❌ メモリリークの可能性
```

### 組み込み開発

#### ✅ 推奨スタイル
```c
// ハードウェア抽象化
typedef struct {
    volatile uint32_t* base_addr;
    uint32_t pin_mask;
    gpio_mode_t mode;
} gpio_config_t;

// 関数命名規則
void gpio_init(gpio_config_t* config);
void gpio_set_pin(gpio_config_t* config, uint32_t pin);
void gpio_clear_pin(gpio_config_t* config, uint32_t pin);

// エラーハンドリング
typedef enum {
    GPIO_OK = 0,
    GPIO_ERROR_INVALID_PIN,
    GPIO_ERROR_INVALID_MODE
} gpio_status_t;
```

#### ✅ リアルタイム考慮
```c
// 割り込みハンドラー（短時間実行）
void SysTick_Handler(void) {
    system_tick_ms++;
    // 最小限の処理のみ
}

// メインループ（協調的マルチタスク）
int main(void) {
    system_init();
    
    while (1) {
        state_machine_update();
        uart_process_buffer();
        led_update_pattern();
        
        __WFI();  // 省電力待機
    }
}
```

## 🧪 テスト戦略

### ユニットテスト

#### ✅ Google Test（C++）
```cpp
#include <gtest/gtest.h>
#include "calculator.h"

class CalculatorTest : public ::testing::Test {
protected:
    void SetUp() override {
        calc = std::make_unique<Calculator>();
    }
    
    std::unique_ptr<Calculator> calc;
};

TEST_F(CalculatorTest, AdditionWorks) {
    EXPECT_DOUBLE_EQ(calc->add(2.0, 3.0), 5.0);
}

TEST_F(CalculatorTest, DivisionByZeroThrows) {
    EXPECT_THROW(calc->divide(1.0, 0.0), std::invalid_argument);
}
```

#### ✅ Unity（C言語）
```c
#include "unity.h"
#include "led.h"
#include "mock_gpio.h"

void setUp(void) {
    mock_gpio_reset();
}

void test_led_init_configures_gpio(void) {
    led_init();
    
    TEST_ASSERT_EQUAL(1, mock_gpio_init_called);
    TEST_ASSERT_EQUAL(GPIO_MODE_OUTPUT, mock_gpio_last_mode);
}

void test_led_set_controls_pins(void) {
    led_set(LED_GREEN | LED_RED);
    
    TEST_ASSERT_EQUAL(LED_GREEN | LED_RED, mock_gpio_last_value);
}
```

### 統合テスト

#### ✅ QEMU実行テスト
```bash
# 実用的システムテスト
./scripts/test-practical-system.sh

# 期待される結果
✅ SUCCESS: Practical system ran continuously as expected
✅ SysTick timer interrupts (1ms precision timing)
✅ Multi-state finite state machine
✅ UART communication with formatted output
```

## 📊 パフォーマンス最適化

### ビルド最適化

#### ✅ 高速ビルド設定
```cmake
# CMakeLists.txt
set(CMAKE_BUILD_TYPE RelWithDebInfo)  # 最適化+デバッグ情報
set(CMAKE_GENERATOR Ninja)            # 並列ビルド

# CPU数自動検出
include(ProcessorCount)
ProcessorCount(N)
if(NOT N EQUAL 0)
    set(CMAKE_BUILD_PARALLEL_LEVEL ${N})
endif()
```

#### ✅ 依存関係管理
```cmake
# 外部ライブラリ（FetchContent使用）
include(FetchContent)
FetchContent_Declare(
    nlohmann_json
    GIT_REPOSITORY https://github.com/nlohmann/json.git
    GIT_TAG v3.11.2
)
FetchContent_MakeAvailable(nlohmann_json)
```

### 実行時最適化

#### ✅ 組み込み最適化
```c
// コンパイラ最適化ヒント
__attribute__((always_inline)) 
static inline void critical_section_enter(void) {
    __disable_irq();
}

// メモリ配置最適化
__attribute__((section(".fast_data")))
volatile uint32_t high_frequency_counter;

// 分岐予測最適化
if (__builtin_expect(error_condition, 0)) {
    handle_error();
}
```

## 🐛 デバッグ戦略

### 段階的デバッグ

#### 1. ビルドエラー
```bash
# 詳細エラー情報
cmake --build build --verbose

# 特定ファイルのみビルド
cmake --build build --target specific_target
```

#### 2. 実行時エラー
```bash
# VSCodeデバッグ（推奨）
F5 → ブレークポイント設定 → 変数監視

# GDBコマンドライン
(gdb) break main
(gdb) run
(gdb) print variable_name
(gdb) backtrace
```

#### 3. 組み込み特有の問題
```c
// セミホスティング出力
debug_write("Checkpoint reached\n");
debug_write_int(variable_value);
debug_write_hex(register_value);

// アサーション
#ifdef DEBUG
#define ASSERT(condition) \
    if (!(condition)) { \
        debug_write("ASSERT failed: " #condition "\n"); \
        while(1); \
    }
#else
#define ASSERT(condition)
#endif
```

## 📁 プロジェクト構成

### ✅ 推奨ディレクトリ構造
```
project/
├── src/                    # メインソースコード
│   ├── main.c/cpp         # エントリポイント
│   ├── core/              # コア機能
│   ├── drivers/           # ハードウェアドライバー
│   └── utils/             # ユーティリティ
├── include/               # パブリックヘッダー
├── tests/                 # テストコード
│   ├── unit/             # ユニットテスト
│   ├── integration/      # 統合テスト
│   └── mocks/            # モック実装
├── docs/                  # ドキュメント
├── scripts/               # ビルド・実行スクリプト
└── CMakeLists.txt        # ビルド設定
```

### ✅ ファイル命名規則
```bash
# ソースファイル
snake_case.c/cpp          # C/C++実装
snake_case.h/hpp          # ヘッダーファイル

# テストファイル
test_module_name.cpp      # Google Test
test_module_name.c        # Unity

# スクリプト
kebab-case.sh            # シェルスクリプト
kebab-case.ps1           # PowerShell
```

## 🔒 セキュリティ考慮事項

### ✅ 安全なコーディング
```c
// バッファオーバーフロー防止
char buffer[256];
strncpy(buffer, source, sizeof(buffer) - 1);
buffer[sizeof(buffer) - 1] = '\0';

// 整数オーバーフロー確認
if (a > UINT32_MAX - b) {
    // オーバーフロー処理
    return ERROR_OVERFLOW;
}

// ポインタ検証
if (ptr == NULL) {
    return ERROR_NULL_POINTER;
}
```

### ✅ 組み込みセキュリティ
```c
// スタックオーバーフロー検出
#ifdef DEBUG
static uint32_t stack_canary = 0xDEADBEEF;
void check_stack_integrity(void) {
    if (stack_canary != 0xDEADBEEF) {
        debug_write("Stack overflow detected!\n");
        system_reset();
    }
}
#endif

// ウォッチドッグタイマー
void watchdog_refresh(void) {
    IWDG->KR = 0xAAAA;  // キック
}
```

## 📈 継続的改善

### ✅ コード品質管理
```bash
# 静的解析
cppcheck src/ --enable=all

# フォーマット統一
clang-format -i src/*.cpp include/*.h

# メトリクス測定
arm-none-eabi-size build/bin/*.elf
```

### ✅ パフォーマンス監視
```bash
# ビルド時間測定
time cmake --build build

# メモリ使用量確認
arm-none-eabi-nm build/bin/*.elf | grep -E " [bBdD] "

# 実行時間プロファイル
gprof build/bin/program gmon.out
```

## 🎯 チーム開発

### ✅ 協調開発
```bash
# 環境統一
.devcontainer/    # 全員同じ開発環境
.vscode/         # 共通エディタ設定
CMakeLists.txt   # 統一ビルドシステム

# コード共有
git hooks/       # 自動フォーマット・テスト
README.md        # プロジェクト説明
CONTRIBUTING.md  # 貢献ガイドライン
```

### ✅ ドキュメント管理
```markdown
# プロジェクトREADME必須項目
- 概要・目的
- セットアップ手順
- ビルド・実行方法
- テスト実行方法
- トラブルシューティング
- 貢献方法
```

---

**🚀 これらのベストプラクティスに従って、効率的で品質の高い開発を実現しましょう！**