# VSCode Tasks Configuration

このドキュメントでは、C/C++開発環境で使用するVSCodeタスク設定について説明します。

## 📋 利用可能なタスク

各テンプレートプロジェクトには以下のタスクが設定されています：

### 1. CMake Configure
- **目的**: CMakeプロジェクトの設定とビルドファイル生成
- **実行内容**: 
  - Ninjaビルドシステムを使用
  - デバッグビルド設定
  - `compile_commands.json`の生成（IntelliSense用）
- **ショートカット**: `Ctrl+Shift+P` → "Tasks: Run Task" → "CMake Configure"

### 2. CMake Build (デフォルトビルドタスク)
- **目的**: プロジェクトのビルド実行
- **実行内容**: 
  - 並列ビルドでコンパイル時間短縮
  - エラー出力の解析とProblemパネル連携
  - 自動的にCMake Configureに依存
- **ショートカット**: `Ctrl+Shift+B` (デフォルトビルドタスク)

### 3. CMake Clean
- **目的**: ビルド成果物のクリーンアップ
- **実行内容**: ビルドディレクトリ内の生成ファイルを削除
- **ショートカット**: `Ctrl+Shift+P` → "Tasks: Run Task" → "CMake Clean"

### 4. Run Application
- **目的**: ビルドしたアプリケーションの実行
- **実行内容**: 
  - 自動的にビルドタスクに依存
  - ターミナルでアプリケーション実行
- **ショートカット**: `Ctrl+Shift+P` → "Tasks: Run Task" → "Run Application"

## 🔧 エラー出力解析機能

### Problem Matcher設定

各ビルドタスクには以下のエラー解析機能が組み込まれています：

#### 1. CMakeエラー解析
```json
{
    "owner": "cmake",
    "fileLocation": ["relative", "${workspaceFolder}"],
    "pattern": {
        "regexp": "^CMake Error at (.*):(\\d+)\\s+\\((.*)\\):$",
        "file": 1,
        "line": 2,
        "message": 3
    }
}
```

#### 2. GCCコンパイラエラー解析
```json
{
    "owner": "gcc",
    "fileLocation": ["relative", "${workspaceFolder}"],
    "pattern": [
        {
            "regexp": "^(.*):(\\d+):(\\d+):\\s+(warning|error):\\s+(.*)$",
            "file": 1,
            "line": 2,
            "column": 3,
            "severity": 4,
            "message": 5
        }
    ]
}
```

#### 3. Clangコンパイラエラー解析
```json
{
    "owner": "clang",
    "fileLocation": ["relative", "${workspaceFolder}"],
    "pattern": [
        {
            "regexp": "^(.*):(\\d+):(\\d+):\\s+(warning|error|note):\\s+(.*)$",
            "file": 1,
            "line": 2,
            "column": 3,
            "severity": 4,
            "message": 5
        }
    ]
}
```

## 📊 Problemパネル連携

### 自動エラー検出
- ビルド実行時に自動的にエラーと警告を検出
- VSCodeのProblemパネルに結果を表示
- ファイル名、行番号、列番号を正確に解析
- エラーをクリックして該当箇所にジャンプ可能

### サポートするエラータイプ
- **CMakeエラー**: 設定ファイルの構文エラーや依存関係エラー
- **コンパイルエラー**: C/C++の構文エラーや型エラー
- **リンクエラー**: 未定義シンボルや重複定義エラー
- **警告**: コンパイラ警告の表示

## 🚀 使用方法

### 基本的なワークフロー

1. **プロジェクトを開く**
   ```bash
   code templates/basic-cpp
   ```

2. **初回設定**
   - `Ctrl+Shift+P` → "Tasks: Run Task" → "CMake Configure"

3. **ビルド実行**
   - `Ctrl+Shift+B` (デフォルトビルドタスク)
   - または `Ctrl+Shift+P` → "Tasks: Run Task" → "CMake Build"

4. **エラー確認**
   - Problemパネル (`Ctrl+Shift+M`) でエラー一覧を確認
   - エラーをクリックして該当箇所にジャンプ

5. **アプリケーション実行**
   - `Ctrl+Shift+P` → "Tasks: Run Task" → "Run Application"

### Dev Container環境での使用

Dev Container内でも同様にタスクが動作します：

1. **コンテナを開く**
   - VSCodeでプロジェクトフォルダを開く
   - "Reopen in Container"を選択

2. **タスク実行**
   - 通常のVSCode環境と同じショートカットが使用可能
   - コンテナ内のツールチェーンを自動使用

## 🔍 トラブルシューティング

### よくある問題と解決方法

#### 1. CMake Configureが失敗する
```bash
# 解決方法: ビルドディレクトリをクリーンアップ
rm -rf build
# その後、CMake Configureを再実行
```

#### 2. Problemパネルにエラーが表示されない
- タスクの出力パネルでエラーメッセージを確認
- Problem Matcherの正規表現がエラー形式と一致しているか確認

#### 3. IntelliSenseが動作しない
- `compile_commands.json`が生成されているか確認
- CMake Configureタスクを実行して再生成

#### 4. 実行ファイルが見つからない
- ビルドが正常に完了しているか確認
- `build/bin/`ディレクトリに実行ファイルが存在するか確認

## 📝 カスタマイズ

### タスクの追加・変更

`.vscode/tasks.json`を編集してタスクをカスタマイズできます：

```json
{
    "label": "Custom Task",
    "type": "shell",
    "command": "your-command",
    "args": ["arg1", "arg2"],
    "group": "build",
    "problemMatcher": "$gcc"
}
```

### Problem Matcherのカスタマイズ

独自のコンパイラやツールに対応するため、Problem Matcherを追加できます：

```json
{
    "owner": "custom-tool",
    "fileLocation": ["relative", "${workspaceFolder}"],
    "pattern": {
        "regexp": "^Error in (.*):(\\d+): (.*)$",
        "file": 1,
        "line": 2,
        "message": 3
    }
}
```

## 🎯 ベストプラクティス

1. **並列ビルドの活用**: `--parallel`オプションでビルド時間を短縮
2. **依存関係の設定**: `dependsOn`でタスクの実行順序を制御
3. **エラー解析の活用**: Problem Matcherでエラーを効率的に特定
4. **ショートカットの活用**: `Ctrl+Shift+B`でクイックビルド
5. **出力パネルの活用**: 詳細なビルドログを確認

これらの設定により、VSCode内で効率的なC/C++開発が可能になります。