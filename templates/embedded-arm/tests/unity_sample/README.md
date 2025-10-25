# Unity/CMock Sample - 学習用テストフレームワーク

## 🎯 **概要**

このディレクトリは、組み込み開発でよく使用されるUnity/CMockテストフレームワークの学習用サンプルです。

## 📋 **Unity vs Google Test比較**

| 特徴 | Unity + Manual Mock | Google Test |
|------|---------------------|-------------|
| **言語** | C言語特化 | C/C++対応 |
| **サイズ** | 軽量 | 中程度 |
| **学習コスト** | 低い | 中程度 |
| **機能** | シンプル | 豊富 |
| **モック** | 手動実装 | 自動生成 |
| **組み込み業界** | 標準的 | 一般的 |

## 🚀 **使用方法**

### ビルドと実行

```bash
# Unity/CMockサンプルのビルド（推奨）
cd tests/unity_sample
./test_build.sh

# または手動で
mkdir -p build
cmake -B build -S . -G Ninja
cmake --build build
./build/bin/UnityTestRunner
```

### 期待される出力

```
Unity Test Framework
--------------------
test_led_init:PASS
test_led_set_on:PASS
test_led_set_off:PASS
test_led_toggle:PASS

-----------------------
4 Tests 0 Failures 0 Ignored 
OK
```

## 📚 **学習ポイント**

1. **シンプルなテスト記述**: Unityのマクロベーステスト
2. **手動モック**: シンプルで理解しやすいモック実装
3. **軽量実装**: 最小限のリソースでテスト実行
4. **組み込み特化**: ハードウェア依存部分のテスト手法
5. **依存関係最小**: 複雑なツールチェーン不要

## 🎯 **実用性**

- **学習用**: Unity + 手動モックの基本概念理解
- **比較検討**: Google Testとの違いを体験
- **選択肢提供**: プロジェクトに応じたフレームワーク選択
- **シンプル**: 複雑な依存関係なしで即座に使用可能

## 📈 **メインテスト環境**

実際の開発では、`../`のGoogle Test環境を使用することを推奨します：
- より豊富な機能
- VSCode統合
- C/C++両対応
- 完全なモック実装済み