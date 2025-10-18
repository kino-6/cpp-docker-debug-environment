# Debug Configuration Guide

このドキュメントでは、C/C++開発環境でのデバッグ設定について説明します。

## 📋 デバッグ設定概要

各テンプレートプロジェクトには包括的なデバッグ設定が含まれています：

### 🔧 実装されたデバッグ機能
- **GDBデバッガ統合**: VSCodeとGDBの完全連携
- **ブレークポイント**: ソースコード上でのブレークポイント設定
- **変数監視**: ローカル変数とグローバル変数の監視
- **コールスタック**: 関数呼び出し履歴の表示
- **ステップ実行**: ステップイン、ステップオーバー、ステップアウト
- **デバッグシンボル**: 最適化されたデバッグ情報生成

## 🚀 デバッグ設定の使用方法

### 1. VSCodeでのデバッグ開始

#### 基本的な手順
1. VSCodeでプロジェクトを開く
2. ソースコードにブレークポイントを設定（行番号の左をクリック）
3. `F5`キーを押すか、「実行とデバッグ」パネルから設定を選択
4. デバッグが開始され、ブレークポイントで停止

#### ショートカットキー
- `F5`: デバッグ開始/続行
- `F9`: ブレークポイントの設定/解除
- `F10`: ステップオーバー（次の行へ）
- `F11`: ステップイン（関数内部へ）
- `Shift+F11`: ステップアウト（関数から出る）
- `Shift+F5`: デバッグ停止

### 2. 利用可能なデバッグ設定

#### Basic C++ Project
```json
"Debug Basic C++ Project"           // 標準デバッグ設定
"Debug Basic C++ Project (Container)" // Dev Container内デバッグ
"Attach to Process"                 // 実行中プロセスにアタッチ
```

#### Calculator C++ Project
```json
"Debug Calculator Project"          // 標準デバッグ設定
"Debug Calculator Project (Container)" // Dev Container内デバッグ
"Debug Calculator with Breakpoint Test" // ブレークポイントテスト用
```

#### JSON Parser C++ Project
```json
"Debug JSON Parser Project"         // CI/CDモードでデバッグ
"Debug JSON Parser (Interactive Mode)" // 対話モードでデバッグ
"Debug JSON Parser (Container)"     // Dev Container内デバッグ
"Debug JSON Parser with Breakpoints" // ブレークポイントテスト用
```

## 🔍 デバッグシンボル設定

### CMakeでの最適化されたデバッグ設定

```cmake
# Enhanced debug symbols for GCC/Clang
if(CMAKE_BUILD_TYPE STREQUAL "Debug")
    add_compile_options(-g3 -O0 -fno-omit-frame-pointer)
    # Additional debug information
    add_compile_options(-ggdb -gdwarf-4)
    # Disable optimizations that interfere with debugging
    add_compile_options(-fno-inline -fno-eliminate-unused-debug-types)
endif()
```

### デバッグフラグの説明
- `-g3`: 最大レベルのデバッグ情報（マクロ定義含む）
- `-O0`: 最適化を無効化（デバッグしやすくする）
- `-fno-omit-frame-pointer`: フレームポインタを保持（スタックトレース用）
- `-ggdb`: GDB専用の拡張デバッグ情報
- `-gdwarf-4`: DWARF-4形式のデバッグ情報
- `-fno-inline`: インライン展開を無効化
- `-fno-eliminate-unused-debug-types`: 未使用型の情報も保持

## 🐳 Dev Container環境でのデバッグ

### Container内デバッグの特徴
- **完全分離**: ホスト環境に影響されない一貫したデバッグ環境
- **権限設定**: `SYS_PTRACE`権限により完全なデバッグ機能
- **パス自動マッピング**: `/workspace`とローカルパスの自動変換

### Container専用設定
```json
{
    "name": "Debug Project (Container)",
    "program": "/workspace/build/bin/ProjectName",
    "cwd": "/workspace",
    "miDebuggerPath": "/usr/bin/gdb"
}
```

## 🔧 GDBデバッガ設定

### Pretty Printing有効化
```json
{
    "description": "Enable pretty-printing for gdb",
    "text": "-enable-pretty-printing",
    "ignoreFailures": true
}
```

### Intel形式逆アセンブリ
```json
{
    "description": "Set Disassembly Flavor to Intel",
    "text": "-gdb-set disassembly-flavor intel",
    "ignoreFailures": true
}
```

### 自動ブレークポイント設定
```json
{
    "description": "Set breakpoint at main",
    "text": "-break-insert main",
    "ignoreFailures": false
}
```

## 📊 デバッグ機能の詳細

### 1. ブレークポイント機能
- **行ブレークポイント**: 特定の行で実行を停止
- **条件付きブレークポイント**: 条件が満たされた時のみ停止
- **関数ブレークポイント**: 関数の開始時に停止
- **例外ブレークポイント**: 例外発生時に停止

### 2. 変数監視
- **ローカル変数**: 現在のスコープの変数を自動表示
- **ウォッチ式**: 任意の式の値を監視
- **メモリビュー**: メモリの内容を直接確認
- **レジスタビュー**: CPUレジスタの状態を表示

### 3. コールスタック
- **関数呼び出し履歴**: 現在の実行位置までの関数呼び出し
- **フレーム切り替え**: 異なるスタックフレームの変数を確認
- **引数表示**: 各関数の引数値を表示

### 4. ステップ実行
- **ステップオーバー**: 関数呼び出しをスキップして次の行へ
- **ステップイン**: 関数内部に入って実行
- **ステップアウト**: 現在の関数から抜けるまで実行
- **実行継続**: 次のブレークポイントまで実行

## 🚨 トラブルシューティング

### よくある問題と解決方法

#### 1. ブレークポイントが効かない
**症状**: ブレークポイントを設定しても停止しない
**原因**: デバッグシンボルが不足、または最適化により削除
**解決方法**:
```bash
# デバッグビルドで再ビルド
cmake -B build -S . -DCMAKE_BUILD_TYPE=Debug
cmake --build build
```

#### 2. 変数の値が表示されない
**症状**: 変数の値が「optimized out」と表示される
**原因**: コンパイラの最適化により変数が削除
**解決方法**: `-O0`フラグでビルド（既に設定済み）

#### 3. ソースコードが表示されない
**症状**: デバッグ時にソースコードが表示されない
**原因**: ソースファイルのパスが正しくない
**解決方法**: `sourceFileMap`設定を確認

#### 4. Container内でデバッグできない
**症状**: Dev Container内でデバッグが開始できない
**原因**: `SYS_PTRACE`権限が不足
**解決方法**: devcontainer.jsonの`runArgs`を確認
```json
"runArgs": [
    "--cap-add=SYS_PTRACE",
    "--security-opt", "apparmor=unconfined"
]
```

#### 5. GDBが見つからない
**症状**: 「gdb not found」エラー
**原因**: GDBがインストールされていない
**解決方法**:
```bash
# Ubuntu/Debian
sudo apt install gdb

# Windows (MinGW)
# GDBは通常MinGWに含まれています
```

## 🎯 デバッグのベストプラクティス

### 1. 効果的なブレークポイント設定
- **戦略的配置**: 問題が発生する可能性の高い箇所に設定
- **条件付き使用**: ループ内では条件付きブレークポイントを活用
- **一時的設定**: 問題解決後は不要なブレークポイントを削除

### 2. 変数監視の活用
- **重要な変数**: 問題に関連する変数をウォッチリストに追加
- **式の評価**: 複雑な式の結果を監視
- **メモリ確認**: ポインタや配列の内容を直接確認

### 3. ログとデバッグの併用
- **デバッグログ**: `std::cout`や`printf`でのログ出力
- **条件付きログ**: デバッグビルド時のみのログ出力
- **構造化ログ**: 問題の特定に役立つ情報を含める

### 4. テスト駆動デバッグ
- **単体テスト**: 問題を再現する最小のテストケース作成
- **段階的確認**: 小さな単位での動作確認
- **回帰テスト**: 修正後の動作確認

## 📝 デバッグ設定のカスタマイズ

### launch.jsonの拡張
```json
{
    "name": "Custom Debug Configuration",
    "type": "cppdbg",
    "request": "launch",
    "program": "${workspaceFolder}/build/bin/YourProgram",
    "args": ["--custom-arg"],
    "stopAtEntry": false,
    "cwd": "${workspaceFolder}",
    "environment": [
        {
            "name": "DEBUG_LEVEL",
            "value": "verbose"
        }
    ],
    "setupCommands": [
        {
            "description": "Custom GDB command",
            "text": "-gdb-set print pretty on",
            "ignoreFailures": true
        }
    ]
}
```

### 環境変数の設定
```json
"environment": [
    {
        "name": "LD_LIBRARY_PATH",
        "value": "/custom/lib/path"
    },
    {
        "name": "DEBUG_MODE",
        "value": "1"
    }
]
```

## 🎉 まとめ

この設定により、以下のデバッグ機能が利用可能になります：

- ✅ **VSCodeブレークポイント**: ソースコード上での直感的なブレークポイント設定
- ✅ **完全なデバッグ情報**: 最適化されたデバッグシンボル生成
- ✅ **Container対応**: Dev Container環境での完全なデバッグ機能
- ✅ **クロスプラットフォーム**: Windows/Linux/macOS対応
- ✅ **GDB統合**: 高度なデバッグ機能の活用
- ✅ **自動化対応**: CI/CD環境でのデバッグビルド

効率的なC/C++開発とデバッグをお楽しみください！