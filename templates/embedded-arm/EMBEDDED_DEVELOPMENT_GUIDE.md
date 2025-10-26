# ARM組み込み開発ガイド

## 🎯 概要

このガイドでは、ARM Cortex-M4を対象とした本格的な組み込み開発環境の使用方法を説明します。STM32F407VGをターゲットとし、QEMU上でリアルタイムシステムの開発・デバッグが可能です。

## 🚀 環境構成

### ハードウェア仕様
- **CPU**: ARM Cortex-M4 (STM32F407VG)
- **RAM**: 192KB (0x20000000-0x2002FFFF)
- **Flash**: 1MB (0x08000000-0x080FFFFF)
- **FPU**: 単精度浮動小数点演算ユニット

### 開発ツール
- **コンパイラ**: arm-none-eabi-gcc
- **デバッガ**: gdb-multiarch + QEMU
- **シミュレータ**: QEMU (netduinoplus2)
- **ビルドシステム**: CMake + Ninja

## 📁 プロジェクト構造

```
templates/embedded-arm/
├── src/                        # メインソースコード
│   ├── main.c                  # アプリケーションエントリポイント
│   ├── hal/                    # ハードウェア抽象化レイヤー
│   │   ├── gpio.c/h           # GPIO制御
│   │   ├── uart.c/h           # UART通信
│   │   └── timer.c/h          # タイマー制御
│   ├── drivers/                # デバイスドライバー
│   │   ├── led.c/h            # LED制御ドライバー
│   │   └── system.c/h         # システム制御
│   └── startup/                # スタートアップコード
│       └── startup_stm32f407vg.s
├── tests/                      # テスト環境
│   ├── unit/                   # ユニットテスト (Google Test)
│   ├── integration/            # 統合テスト (QEMU)
│   ├── mocks/                  # HALモック実装
│   └── unity_sample/           # Unity学習サンプル
├── include/                    # ヘッダーファイル
├── linker/                     # リンカースクリプト
├── scripts/                    # 実行スクリプト
└── .vscode/                    # VSCode設定
```

## 🎯 開発ワークフロー

### 1. 環境セットアップ
```bash
# プロジェクトを開く
cd templates/embedded-arm
code .

# Dev Container起動
# Ctrl+Shift+P > Dev Containers: Reopen in Container
```

### 2. ビルド
```bash
# VSCodeタスク使用（推奨）
# Ctrl+Shift+P > Tasks: Run Task > ARM: Fresh Configure & Build

# または手動実行
cmake -B build -S . -G Ninja -DCMAKE_BUILD_TYPE=Debug
cmake --build build --parallel
```

### 3. 実行・テスト
```bash
# 実用的システムテスト
# Ctrl+Shift+P > Tasks: Run Task > System: Practical Test

# LED視覚テスト
# Ctrl+Shift+P > Tasks: Run Task > LED: Visual Test

# GDBデバッグテスト
# Ctrl+Shift+P > Tasks: Run Task > GDB: Debug Test
```

## 🔧 主要機能

### リアルタイムシステム
```c
// SysTick割り込み（1ms精度）
void SysTick_Handler(void)
{
    system_tick_ms++;
    interrupt_count++;
    
    // 状態機械更新
    if (system_tick_ms % 5000 == 0) {
        state_machine_update();
    }
}
```

### GPIO制御
```c
// LED制御
void led_init(void);
void led_set(uint32_t leds);
void led_toggle(uint32_t leds);

// 使用例
led_init();
led_set(LED_GREEN | LED_BLUE);
delay(1000000);
led_set(LED_RED | LED_ORANGE);
```

### UART通信
```c
// フォーマット済み出力
void uart_printf(const char* format, ...);

// 使用例
uart_printf("System Status: %s\n", state_names[current_state]);
uart_printf("Uptime: %lu ms\n", system_tick_ms);
uart_printf("Interrupts: %lu\n", interrupt_count);
```

### 状態機械
```c
typedef enum {
    STATE_INIT,
    STATE_RUNNING,
    STATE_MONITORING,
    STATE_ERROR,
    STATE_SHUTDOWN
} system_state_t;

void state_machine_update(void)
{
    switch (current_state) {
        case STATE_INIT:
            // 初期化処理
            break;
        case STATE_RUNNING:
            // 通常動作
            break;
        // ...
    }
}
```

## 🧪 テスト環境

### ユニットテスト (Google Test)
```bash
# ネイティブテスト実行
# Ctrl+Shift+P > Tasks: Run Task > Test: Run Native Unit Tests

# 期待される結果
[==========] Running 20 tests from 4 test suites.
[  PASSED  ] 20 tests.
```

### 統合テスト (QEMU)
```bash
# 実用的システムテスト
./scripts/test-practical-system.sh

# 期待される結果
✅ SUCCESS: Practical system ran continuously as expected
Real-time embedded system is fully functional
```

### Unity学習サンプル
```bash
# Unity軽量テスト
cd tests/unity_sample
./scripts/test-unity-sample.sh

# 特徴
- C言語特化
- 軽量フレームワーク
- 手動モック実装
```

## 🐛 デバッグ

### VSCode統合デバッグ
```bash
# F5でデバッグ開始
# ブレークポイント設定
# 変数監視
# ステップ実行
```

### GDBコマンドライン
```bash
# QEMU + GDB
qemu-system-arm -M netduinoplus2 -cpu cortex-m4 \
  -kernel build/bin/EmbeddedArmProject.elf \
  -nographic -gdb tcp::1234 -S &

gdb-multiarch build/bin/EmbeddedArmProject.elf
(gdb) target remote localhost:1234
(gdb) break main
(gdb) continue
```

### セミホスティング出力
```c
// デバッグ出力
debug_write("System initialized\n");
debug_write_int(system_tick_ms);
debug_write_hex(register_value);
```

## 📊 パフォーマンス分析

### メモリ使用量
```bash
# メモリ使用量確認
arm-none-eabi-size build/bin/EmbeddedArmProject.elf

# 期待される結果
   text    data     bss     dec     hex filename
   2048     100    1024    3172     c64 EmbeddedArmProject.elf

# RAM使用率: 1.2% (1024/192KB)
# Flash使用率: 0.1% (2048/1MB)
```

### 実行時間分析
```c
// タイミング測定
uint32_t start_time = system_tick_ms;
critical_function();
uint32_t execution_time = system_tick_ms - start_time;
```

## 🎯 実用例

### 1. LEDブリンクパターン
```c
// Knight Riderパターン
const uint32_t pattern[] = {
    LED_GREEN, LED_ORANGE, LED_RED, LED_BLUE, LED_RED, LED_ORANGE
};

for (int i = 0; i < 6; i++) {
    led_set(pattern[i]);
    delay(500000);
}
```

### 2. 割り込み駆動UART
```c
void USART2_IRQHandler(void)
{
    if (USART2->SR & USART_SR_RXNE) {
        char received = USART2->DR;
        uart_buffer[uart_index++] = received;
    }
}
```

### 3. タイマー制御
```c
// 1ms精度タイマー
void timer_init(void)
{
    SysTick_Config(SystemCoreClock / 1000);  // 1ms
}

void delay_ms(uint32_t ms)
{
    uint32_t start = system_tick_ms;
    while ((system_tick_ms - start) < ms) {
        __WFI();  // 省電力待機
    }
}
```

## 🚨 トラブルシューティング

### よくある問題

#### 1. ビルドエラー
```bash
# リンカーエラー
undefined reference to 'printf'
→ セミホスティング関数を使用: debug_write()

# メモリ不足
region 'RAM' overflowed
→ 変数サイズ確認、スタックサイズ調整
```

#### 2. QEMU実行エラー
```bash
# QEMU起動失敗
qemu-system-arm: command not found
→ Dev Container再起動

# セミホスティング出力なし
→ -semihosting-config enable=on 追加
```

#### 3. デバッグ接続エラー
```bash
# GDB接続失敗
Connection refused
→ QEMUのGDBサーバー確認 (-gdb tcp::1234)

# ブレークポイント無効
→ デバッグシンボル確認 (-g3フラグ)
```

## 📚 参考資料

### ARM Cortex-M4
- [ARM Cortex-M4 Technical Reference Manual](https://developer.arm.com/documentation/100166/0001)
- [STM32F407VG Reference Manual](https://www.st.com/resource/en/reference_manual/dm00031020.pdf)

### 開発ツール
- [GNU Arm Embedded Toolchain](https://developer.arm.com/tools-and-software/open-source-software/developer-tools/gnu-toolchain/gnu-rm)
- [QEMU ARM System Emulation](https://qemu.readthedocs.io/en/latest/system/target-arm.html)

### テストフレームワーク
- [Google Test Documentation](https://google.github.io/googletest/)
- [Unity Test Framework](http://www.throwtheswitch.org/unity)

## 🎉 次のステップ

1. **基本機能習得**: LED制御、UART通信
2. **リアルタイム開発**: 割り込み、タイマー、状態機械
3. **高度な機能**: DMA、ADC、PWM制御
4. **実用プロジェクト**: IoTデバイス、制御システム

---

**🚀 本格的な組み込み開発を始めましょう！**