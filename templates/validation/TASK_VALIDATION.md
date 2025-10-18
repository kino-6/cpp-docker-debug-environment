# VSCodeタスク設定検証手順

このドキュメントでは、VSCodeタスク設定とエラー出力解析機能の動作検証手順を説明します。

## 🎯 検証目標

- CMakeビルドタスクの動作確認
- エラー出力解析機能の動作確認
- Problemパネル連携の動作確認
- IntelliSense設定の動作確認

## 📋 検証手順

### 1. 基本タスク動作検証

#### 1.1 プロジェクトを開く
```bash
# 任意のテンプレートプロジェクトを開く
code templates/basic-cpp
```

#### 1.2 CMake Configureタスクの実行
1. `Ctrl+Shift+P` → "Tasks: Run Task"
2. "CMake Configure"を選択
3. **期待結果**: 
   - ターミナルにCMake設定ログが表示される
   - `build/`ディレクトリが作成される
   - `build/compile_commands.json`が生成される

#### 1.3 CMake Buildタスクの実行
1. `Ctrl+Shift+B` (デフォルトビルドタスク)
2. **期待結果**:
   - ビルドが正常に完了する
   - `build/bin/`に実行ファイルが生成される
   - Problemパネルにエラーが表示されない

#### 1.4 Run Applicationタスクの実行
1. `Ctrl+Shift+P` → "Tasks: Run Task"
2. "Run Application"を選択
3. **期待結果**:
   - アプリケーションが実行される
   - 期待される出力が表示される

### 2. エラー出力解析機能検証

#### 2.1 エラーテストファイルの準備
```bash
# エラーテストファイルをプロジェクトにコピー
cp templates/validation/error-test.cpp templates/basic-cpp/src/
```

#### 2.2 CMakeLists.txtの更新
`templates/basic-cpp/CMakeLists.txt`に以下を追加：
```cmake
# エラーテスト用の実行ファイル
add_executable(error-test src/error-test.cpp)
```

#### 2.3 エラービルドの実行
1. `Ctrl+Shift+B`でビルド実行
2. **期待結果**:
   - ビルドが失敗する
   - Problemパネル (`Ctrl+Shift+M`) にエラーが表示される
   - エラーをクリックして該当箇所にジャンプできる

#### 2.4 エラータイプ別検証

**コンパイルエラーの検証**:
- [ ] 未定義変数エラーが検出される
- [ ] 型不一致エラーが検出される
- [ ] 構文エラー（セミコロン忘れ）が検出される
- [ ] 存在しないヘッダファイルエラーが検出される

**警告の検証**:
- [ ] 未使用変数警告が検出される

**リンクエラーの検証**:
- [ ] 未定義関数エラーが検出される
- [ ] 重複定義エラーが検出される

### 3. Problem Matcher動作検証

#### 3.1 GCC Problem Matcherの検証
```bash
# GCCでビルドしてエラー形式を確認
export CC=gcc
export CXX=g++
```

#### 3.2 Clang Problem Matcherの検証
```bash
# Clangでビルドしてエラー形式を確認
export CC=clang
export CXX=clang++
```

#### 3.3 Problem Matcherの精度確認
各エラーについて以下を確認：
- [ ] ファイル名が正確に解析される
- [ ] 行番号が正確に解析される
- [ ] 列番号が正確に解析される
- [ ] エラーメッセージが正確に表示される
- [ ] エラーの重要度（error/warning）が正確に分類される

### 4. IntelliSense連携検証

#### 4.1 compile_commands.json生成確認
1. CMake Configureタスクを実行
2. `build/compile_commands.json`の存在を確認
3. **期待結果**: ファイルが存在し、適切なコンパイルコマンドが記録されている

#### 4.2 IntelliSense機能確認
1. C++ファイルを開く
2. 以下の機能を確認：
   - [ ] **コード補完**: `std::`入力時に候補が表示される
   - [ ] **エラー検出**: 赤い波線でエラーが表示される
   - [ ] **定義ジャンプ**: `F12`で関数定義にジャンプできる
   - [ ] **参照検索**: `Shift+F12`で参照箇所が表示される
   - [ ] **ホバー情報**: 変数や関数にマウスオーバーで情報表示

### 5. Dev Container環境での検証

#### 5.1 Dev Containerでプロジェクトを開く
1. VSCodeでプロジェクトを開く
2. "Reopen in Container"を選択
3. コンテナの起動を待つ

#### 5.2 コンテナ内でのタスク実行
1. 上記の検証手順1-4をコンテナ内で実行
2. **期待結果**: ローカル環境と同様に動作する

### 6. 複数コンパイラでの検証

#### 6.1 GCCでの検証
```bash
# .devcontainer/devcontainer.jsonでGCCを指定
"containerEnv": {
    "CC": "gcc",
    "CXX": "g++"
}
```

#### 6.2 Clangでの検証
```bash
# .devcontainer/devcontainer.jsonでClangを指定
"containerEnv": {
    "CC": "clang",
    "CXX": "clang++"
}
```

## 📊 検証結果記録

### 検証環境
- [ ] Windows + WSL2
- [ ] Windows + Docker Desktop
- [ ] Linux Native
- [ ] macOS

### 検証結果チェックリスト

#### 基本機能
- [ ] CMake Configureタスクが正常動作
- [ ] CMake Buildタスクが正常動作
- [ ] CMake Cleanタスクが正常動作
- [ ] Run Applicationタスクが正常動作

#### エラー解析機能
- [ ] CMakeエラーが正確に解析される
- [ ] GCCエラーが正確に解析される
- [ ] Clangエラーが正確に解析される
- [ ] 警告が正確に解析される

#### Problemパネル連携
- [ ] エラーがProblemパネルに表示される
- [ ] エラークリックで該当箇所にジャンプ
- [ ] ファイル名、行番号が正確
- [ ] エラーの重要度が正確

#### IntelliSense連携
- [ ] compile_commands.jsonが生成される
- [ ] コード補完が動作する
- [ ] エラー検出が動作する
- [ ] 定義ジャンプが動作する
- [ ] 参照検索が動作する

## 🚨 既知の問題と対処法

### 問題1: Problem Matcherが動作しない
**症状**: エラーがProblemパネルに表示されない
**対処法**: 
1. タスクの出力パネルでエラー形式を確認
2. Problem Matcherの正規表現を調整

### 問題2: IntelliSenseが動作しない
**症状**: コード補完や定義ジャンプが動作しない
**対処法**:
1. `compile_commands.json`の存在を確認
2. C/C++拡張機能の設定を確認
3. CMake Configureタスクを再実行

### 問題3: Dev Container内でタスクが失敗
**症状**: コンテナ内でビルドタスクが失敗
**対処法**:
1. コンテナ内のツールチェーンを確認
2. パスの設定を確認
3. 権限の問題を確認

## 📝 検証レポートテンプレート

```markdown
# VSCodeタスク設定検証レポート

## 検証環境
- OS: 
- VSCodeバージョン: 
- C/C++拡張機能バージョン: 
- Dockerバージョン: 

## 検証結果
### 基本機能: ✅/❌
### エラー解析機能: ✅/❌
### Problemパネル連携: ✅/❌
### IntelliSense連携: ✅/❌

## 発見した問題
1. 
2. 
3. 

## 改善提案
1. 
2. 
3. 
```

この検証手順に従って、VSCodeタスク設定の動作を確認してください。