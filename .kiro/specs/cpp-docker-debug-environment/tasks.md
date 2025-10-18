# Implementation Plan

## フェーズ1: 基本C/C++開発環境（MVP）

**期間**: 1-2週間 | **規模**: 小規模 | **目標**: 最小限の動作環境構築

- [x] 1. 基本C/C++プロジェクトテンプレートの作成

  - シンプルなC/C++開発用のディレクトリ構造作成
  - Hello World レベルのサンプルコード作成
  - 基本的なCMakeLists.txtテンプレート作成
  - _Requirements: 3.1, 3.4_

- [x] 2. 基本Dev Container設定の作成

  - GCC/Clang、CMake、GDBを含む最小限の開発環境設定

  - VSCode C/C++拡張機能の自動インストール設定
  - 基本的なボリュームマウント設定
  - _Requirements: 1.1, 3.1, 3.2_

- [x] 3. 基本Dockerfileの作成

  - Ubuntu LTSベースのシンプルな開発環境イメージ
  - GCC、CMake、GDB等の基本開発ツールのみ
  - 軽量で高速起動を重視した構成
  - _Requirements: 1.1, 1.2_

- [x] 4. 基本VSCodeタスク設定の作成

  - CMakeビルド用の基本タスク定義
  - ビルド、クリーンタスクの設定
  - エラー出力の解析設定とProblemパネル連携
  - _Requirements: 1.2, 1.3_

- [x] 5. 基本デバッグ設定の作成


  - GDBデバッガ設定の定義
  - ローカルデバッグ設定の最適化
  - デバッグシンボル設定とソースマッピング
  - VSCodeブレークポイント機能の検証と設定
  - _Requirements: 2.1, 2.2, 2.3_

- [x] 6. 基本環境の動作検証

  - Hello Worldプロジェクトでのビルド・実行テスト
  - デバッグ機能の動作確認
  - IntelliSense機能の動作検証（コード補完、エラー検出、定義ジャンプ）
  - VSCodeブレークポイントでのデバッグ実行検証
  - Windows/Linux/macOS環境での動作検証
  - _Requirements: 3.4, 5.1, 5.2_

- [x] 6.1 既存プロジェクトImport機能の作成

  - 既存C/C++プロジェクトに設定を適用するスクリプト作成
  - 環境検出機能（Native/Container自動判別）
  - 設定ファイルの安全なバックアップ・復元機能
  - インタラクティブな設定選択UI
  - _Requirements: 3.2, 6.1_

- [x] 6.2 他テンプレートでの動作検証

  - calculator-cppテンプレートでのデバッグ環境検証
  - json-parser-cppテンプレートでのデバッグ環境検証
  - 複雑なプロジェクト構造での設定適用確認
  - 外部ライブラリ依存プロジェクトでの動作確認
  - _Requirements: 3.4, 5.1, 5.2_

## フェーズ2: 組み込み開発対応 ✅ **完了**

**期間**: 2-3週間 | **規模**: 中規模 | **目標**: ARM向け組み込み開発環境構築

- [x] 7. 組み込み開発用プロジェクトテンプレートの作成
  - ARM Cortex-M4向けの基本テンプレート作成（STM32F407VG対応）
  - LEDブリンクサンプルコード作成（4LED制御、デバッグポイント付き）
  - クロスコンパイル用CMakeLists.txtテンプレート作成（ARM GCC、リンカースクリプト統合）
  - プロジェクト構造：src/hal/, src/drivers/, include/, linker/, scripts/
  - _Requirements: 3.1, 3.4_

- [x] 8. 組み込み開発用Dev Container設定の作成
  - ARM GCCクロスコンパイラ環境設定（gcc-arm-none-eabi, gdb-multiarch）
  - QEMUシミュレータの統合（qemu-system-arm）
  - 組み込み開発用VSCode拡張機能設定（C/C++, CMake Tools）
  - Ubuntu 22.04ベースの軽量コンテナ構成
  - _Requirements: 1.1, 3.1_

- [x] 9. 組み込み開発用Dockerfileの作成
  - ARM GCCツールチェーンの統合（binutils-arm-none-eabi, libnewlib-arm-none-eabi）
  - QEMUシミュレータとデバッグツールの統合（openocd, pyocd）
  - 軽量化を重視した構成（不要パッケージ削除、レイヤー最適化）
  - Python開発ツール統合（intelhex）
  - _Requirements: 1.1, 1.2_

- [x] 10. 組み込み開発用ビルド・デバッグ設定
  - クロスコンパイル用のビルドタスク設定（CMake + Ninja、並列ビルド対応）
  - QEMUシミュレータデバッグ設定（GDB remote debugging, localhost:1234）
  - VSCode launch.json設定（ARM architecture, gdb-multiarch）
  - メモリ使用量表示、HEX/BINファイル生成
  - _Requirements: 1.2, 1.3, 2.1, 2.2_

- [x] 11. 組み込み環境の動作検証
  - ARM向けLEDブリンクプロジェクトでのビルド・実行テスト（✅ 成功）
  - メモリ使用量確認（RAM: 1.2%, FLASH: 0.1%、適切な範囲）
  - ELF/HEX/BINファイル生成確認（✅ 正常生成）
  - GitBash統合によるWindows環境対応
  - QEMUシミュレータでの実行テスト設定完了
  - _Requirements: 5.1, 5.2_

## フェーズ3: テストフレームワーク統合 🔄 **進行中**

**期間**: 1-2週間 | **規模**: 小-中規模 | **目標**: 自動テスト環境の構築

- [ ] 12. Google Test環境設定
  - Google TestとGMockのCMake統合設定
  - 基本的なテストディレクトリ構造とテンプレート作成
  - VSCode Test Explorer連携設定
  - _Requirements: 3.1_

- [ ] 13. 組み込み向けテスト環境設定
  - Unity/CMockフレームワーク統合
  - ハードウェア抽象化レイヤーのモック設定
  - PC上でのハードウェア依存部分テスト設定
  - _Requirements: 3.1_

- [ ] 14. テストカバレッジ機能
  - gcovによるカバレッジ測定設定
  - VSCode内でのカバレッジ表示設定
  - カバレッジレポートの自動生成設定
  - _Requirements: 5.1, 5.2_

- [ ] 15. テスト環境の動作検証
  - 単体テストの実行とデバッグ動作確認
  - テストカバレッジ測定の動作確認
  - 組み込み向けモックテストの動作確認
  - _Requirements: 5.1, 5.2_

## フェーズ4: 拡張機能とオプション対応

**期間**: 2-4週間 | **規模**: 中-大規模 | **目標**: 複数アーキテクチャ対応と自動化

- [ ] 16. 複数アーキテクチャ対応の拡張
  - RISC-V、AVR、ESP32等の追加アーキテクチャ対応
  - アーキテクチャ別のテンプレート作成
  - 複数ターゲット対応のビルドシステム拡張
  - _Requirements: 1.1, 1.2_

- [ ] 17. Autosar開発サンプル実装（オプション）
  - Autosar開発ツールチェーン統合
  - Autosar Classic/Adaptive Platform対応設定
  - 組み込み開発環境をベースとした追加設定
  - _Requirements: 1.1, 3.1, 3.3_

- [ ] 18. プロジェクト初期化スクリプトの作成
  - 対話式プロジェクト設定選択機能
  - テンプレートファイルの自動コピーと設定
  - 初期ディレクトリ構造の自動生成
  - _Requirements: 3.1, 3.2_

- [ ] 19. 環境検証と自動修復機能
  - Docker環境の動作確認機能
  - 必要な依存関係の確認と警告表示
  - VSCode拡張機能の推奨インストール機能
  - _Requirements: 3.2, 3.4_

## フェーズ5: ドキュメントと最終調整

**期間**: 1週間 | **規模**: 小規模 | **目標**: ドキュメント整備と品質保証

- [ ] 20. クイックスタートガイド作成
  - 基本的な使用方法の説明文書
  - 各プロジェクトタイプの導入手順
  - トラブルシューティングガイド
  - _Requirements: 6.3_

- [ ] 21. サンプルプロジェクト作成
  - 基本C/C++開発のサンプルプロジェクト
  - 組み込み開発のサンプルプロジェクト
  - Autosar開発のサンプルプロジェクト（オプション）
  - _Requirements: 3.1, 6.3_

- [ ] 22. 統合テストとパフォーマンス検証
  - 全ワークフローの自動テスト実装
  - 複数OS環境での動作検証テスト
  - パフォーマンステストの実装
  - _Requirements: 5.1, 5.2, 5.3_

## 📊 全体スケジュール概要

- **総期間**: 7-12週間
- **MVP完成**: ✅ フェーズ1完了時点（1-2週間）
- **実用レベル**: ✅ フェーズ2完了時点（4週間） - **現在ここ**
- **テスト統合**: 🔄 フェーズ3進行中（5-7週間）
- **フル機能**: フェーズ5完了時点（7-12週間）

## 各フェーズの成果物

- **✅ フェーズ1**: 基本的なC/C++開発が可能な環境（basic-cpp, calculator-cpp, json-parser-cpp）
- **✅ フェーズ2**: 組み込み開発（ARM Cortex-M4）が可能な環境（embedded-arm）
- **🔄 フェーズ3**: テスト駆動開発が可能な環境
- **⏳ フェーズ4**: 複数アーキテクチャ対応の完全な開発環境
- **⏳ フェーズ5**: 本格運用可能な完成品

## 🎯 現在の状況（2025年1月）

**完了済み**:
- ✅ 基本C/C++開発環境（3つのテンプレート）
- ✅ ARM組み込み開発環境（embedded-arm）
- ✅ Dev Container統合
- ✅ VSCodeタスク・デバッグ設定
- ✅ クロスプラットフォーム対応（Windows/Linux）

**進行中**:
- 🔄 QEMUシミュレーション実行環境の最終調整
- 🔄 テストフレームワーク統合準備

**次のステップ**:
- Google Test統合
- 組み込み向けUnity/CMockフレームワーク
- テストカバレッジ機能##
各フェーズのサンプルプロジェクト

### フェーズ1: 基本C/C++開発環境

**サンプルプロジェクト**:

- **Hello World**: 基本的なコンソール出力
- **Calculator**: 簡単な四則演算ライブラリ（関数分割、ヘッダファイル使用）
- **JSON Parser**: nlohmann/jsonを使用した軽量なJSONパーサー（外部ライブラリ依存の検証）

### フェーズ2: 組み込み開発対応

**サンプルプロジェクト**:

- **LED Blink**: ARM Cortex-M向けの基本的なLEDブリンク（GPIO制御）
- **UART Echo**: シリアル通信のエコーバック（ペリフェラル使用例）
- **FreeRTOS Task**: FreeRTOSを使用したマルチタスク処理（RTOS統合例）

### フェーズ3: テストフレームワーク統合

**サンプルプロジェクト**:

- **Calculator with Tests**: フェーズ1のCalculatorに単体テスト追加
- **Embedded HAL Mock**: 組み込みHAL層のモックテスト実装
- **Coverage Demo**: テストカバレッジ測定のデモンストレーション

### フェーズ4: 拡張機能とオプション対応

**サンプルプロジェクト**:

- **Multi-Architecture Build**: 同一コードのARM/RISC-V/x86ビルド
- **ESP32 IoT Device**: ESP32向けのWiFi接続デバイス（実用的な組み込み例）
- **Autosar Basic Software**: Autosar BSWの最小実装例（オプション）

### フェーズ5: ドキュメントと最終調整

**サンプルプロジェクト**:

- **Complete Embedded Project**: 実際の組み込み製品を模したサンプル
- **CI/CD Integration**: GitHub Actionsとの統合例
- **Best Practices Showcase**: 各種ベストプラクティスを含む総合例

## 推奨オープンソースプロジェクト

参考・ベースとして活用できるオープンソースプロジェクト：

### 基本C/C++

- **nlohmann/json**: モダンなC++ JSON ライブラリ
- **fmt**: C++フォーマットライブラリ
- **spdlog**: 高速C++ログライブラリ

### 組み込み開発

- **FreeRTOS**: リアルタイムOS（MIT License）
- **STM32CubeF4**: STMicroelectronics HAL（BSD License）
- **Zephyr Project**: Linux Foundation組み込みRTOS

### テストフレームワーク

- **Google Test**: C++単体テストフレームワーク
- **Unity**: C言語向け軽量テストフレームワーク
- **CMock**: Cモックフレームワーク
