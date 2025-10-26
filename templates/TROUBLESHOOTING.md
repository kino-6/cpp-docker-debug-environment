# トラブルシューティングガイド

## 🎯 概要

C++/Docker デバッグ環境でよく発生する問題と解決方法をまとめたガイドです。問題の種類別に整理し、段階的な解決手順を提供します。

## 🚨 緊急時の対処法

### 🔥 システム全体が動作しない場合

#### 1. 基本確認（30秒で実行）
```bash
# Docker確認
docker --version
docker ps

# VSCode確認
code --version

# 権限確認（Linux/macOS）
ls -la /var/run/docker.sock
```

#### 2. 緊急復旧手順（2分で実行）
```bash
# Docker再起動
# Windows: Docker Desktop再起動
# Linux/macOS:
sudo systemctl restart docker

# VSCode完全再起動
# すべてのVSCodeウィンドウを閉じて再起動

# Dev Container強制再構築
# Ctrl+Shift+P > Dev Containers: Rebuild Container
```

## 🔧 環境セットアップ問題

### Dev Container起動失敗

#### 症状
```
Failed to start container
Cannot connect to the Docker daemon
```

#### 解決手順
```bash
# 1. Docker Desktop確認
# Windows: タスクトレイのDockerアイコン確認
# macOS: メニューバーのDockerアイコン確認

# 2. Docker動作確認
docker run hello-world

# 3. WSL2確認（Windows）
wsl --list --verbose
# Ubuntu-20.04 または Ubuntu-22.04 が Running であることを確認

# 4. メモリ・ディスク容量確認
docker system df
docker system prune  # 不要なイメージ削除
```

#### Windows特有の問題
```powershell
# WSL2有効化
dism.exe /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /norestart
dism.exe /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart

# WSL2をデフォルトに設定
wsl --set-default-version 2

# Hyper-V確認
Get-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V
```

### 権限エラー

#### 症状
```
Permission denied
Cannot create directory
Access denied
```

#### 解決手順
```bash
# Linux/macOS
# Dockerグループ追加
sudo usermod -aG docker $USER
newgrp docker

# ディレクトリ権限修正
sudo chown -R $USER:$USER /path/to/project

# Windows（WSL2）
# ファイルシステム権限確認
ls -la /mnt/c/path/to/project
# 必要に応じてWSL内にプロジェクトコピー
```

## 🔨 ビルド問題

### CMakeエラー

#### 症状1: CMake not found
```
cmake: command not found
```

#### 解決手順
```bash
# Dev Container内で実行
which cmake
cmake --version

# CMakeが見つからない場合
apt update && apt install cmake

# または Dev Container再構築
# Ctrl+Shift+P > Dev Containers: Rebuild Container
```

#### 症状2: Generator not found
```
CMake Error: Could not find CMAKE_MAKE_PROGRAM (ninja)
```

#### 解決手順
```bash
# Ninja確認
which ninja
ninja --version

# Ninjaインストール
apt update && apt install ninja-build

# または Make使用
cmake -B build -S . -G "Unix Makefiles"
make -C build -j$(nproc)
```

### コンパイルエラー

#### 症状1: ARM toolchain not found
```
arm-none-eabi-gcc: command not found
```

#### 解決手順
```bash
# ARM toolchain確認
which arm-none-eabi-gcc
arm-none-eabi-gcc --version

# パス確認
echo $PATH | grep arm

# Dev Container再構築（推奨）
# Ctrl+Shift+P > Dev Containers: Rebuild Container
```

#### 症状2: リンカーエラー
```
undefined reference to 'printf'
undefined reference to 'malloc'
```

#### 解決手順
```bash
# 組み込み環境の場合（-nostdlib使用）
# printf → debug_write() に置換
# malloc → 静的配列使用

# 例：修正前
printf("Hello %d\n", value);

# 例：修正後
debug_write("Hello ");
debug_write_int(value);
debug_write("\n");
```

#### 症状3: ヘッダーファイル not found
```
fatal error: 'nlohmann/json.hpp' file not found
```

#### 解決手順
```bash
# 依存関係確認
cat CMakeLists.txt | grep -i json

# FetchContent確認
cmake -B build -S . --debug-output | grep -i fetch

# 手動依存関係解決
cd build
cmake .. --debug-find-pkg=nlohmann_json
```

## 🐛 実行時問題

### QEMU実行エラー

#### 症状1: QEMU not found
```
qemu-system-arm: command not found
```

#### 解決手順
```bash
# QEMU確認
which qemu-system-arm
qemu-system-arm --version

# QEMUインストール確認
apt list --installed | grep qemu

# Dev Container再構築
# Ctrl+Shift+P > Dev Containers: Rebuild Container
```

#### 症状2: セミホスティング出力なし
```
QEMU実行するが出力が表示されない
```

#### 解決手順
```bash
# セミホスティング有効化確認
qemu-system-arm -M netduinoplus2 -cpu cortex-m4 \
  -kernel build/bin/test.elf \
  -nographic \
  -semihosting-config enable=on,target=native

# 代替出力方法テスト
# LED制御テスト
# Ctrl+Shift+P > Tasks: Run Task > LED: Visual Test

# UART出力テスト
# Ctrl+Shift+P > Tasks: Run Task > UART: Output Test
```

#### 症状3: GDBデバッグ接続失敗
```
Connection refused
Remote connection closed
```

#### 解決手順
```bash
# QEMUのGDBサーバー確認
qemu-system-arm -M netduinoplus2 -cpu cortex-m4 \
  -kernel build/bin/test.elf \
  -nographic -gdb tcp::1234 -S &

# ポート確認
netstat -an | grep 1234
lsof -i :1234

# GDB接続テスト
gdb-multiarch build/bin/test.elf
(gdb) target remote localhost:1234
(gdb) info registers
```

### テスト実行エラー

#### 症状1: Google Test実行失敗
```
./UnitTestRunner: No such file or directory
```

#### 解決手順
```bash
# テストバイナリ確認
ls -la build/bin/
ls -la build/tests/

# テストビルド確認
cmake --build build --target UnitTestRunner

# 実行権限確認
chmod +x build/bin/UnitTestRunner
```

#### 症状2: Unity テスト失敗
```
Unity test framework not found
```

#### 解決手順
```bash
# Unity環境確認
cd tests/unity_sample
ls -la src/

# Unity実行
./scripts/test-unity-sample.sh

# 手動実行
cd tests/unity_sample
cmake -B build -S .
cmake --build build
./build/bin/UnityTestRunner
```

## 📊 パフォーマンス問題

### ビルド速度が遅い

#### 症状
```
ビルドに10秒以上かかる
```

#### 解決手順
```bash
# 並列ビルド確認
nproc  # CPU数確認
cmake --build build --parallel $(nproc)

# Ninja使用確認
cmake -B build -S . -G Ninja

# キャッシュクリア
rm -rf build
cmake -B build -S . -G Ninja
```

### メモリ使用量過多

#### 症状
```
組み込みプログラムのメモリ使用量が多い
```

#### 解決手順
```bash
# メモリ使用量確認
arm-none-eabi-size build/bin/*.elf

# セクション別確認
arm-none-eabi-objdump -h build/bin/*.elf

# 最適化レベル確認・変更
# CMakeLists.txt
set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -Os")  # サイズ最適化
```

## 🔍 デバッグ問題

### ブレークポイントが効かない

#### 症状
```
VSCodeでブレークポイントを設定しても停止しない
```

#### 解決手順
```bash
# デバッグシンボル確認
file build/bin/*.elf | grep "not stripped"

# コンパイルフラグ確認
cmake -B build -S . -DCMAKE_BUILD_TYPE=Debug

# GDBデバッグ情報確認
gdb-multiarch build/bin/*.elf
(gdb) info sources
(gdb) list main
```

### 変数が監視できない

#### 症状
```
変数の値が<optimized out>と表示される
```

#### 解決手順
```bash
# 最適化無効化
# CMakeLists.txt
set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -O0 -g3")

# volatile修飾子追加
volatile int debug_variable = 42;

# デバッガで確認
(gdb) print debug_variable
(gdb) print /x debug_variable  # 16進表示
```

## 🌐 ネットワーク問題

### 外部ライブラリダウンロード失敗

#### 症状
```
Failed to download nlohmann/json
Connection timeout
```

#### 解決手順
```bash
# ネットワーク確認
ping github.com
curl -I https://github.com

# プロキシ設定確認
echo $HTTP_PROXY
echo $HTTPS_PROXY

# Git設定確認
git config --global http.proxy
git config --global https.proxy

# 手動ダウンロード
wget https://github.com/nlohmann/json/releases/download/v3.11.2/json.hpp
```

## 📱 プラットフォーム固有問題

### Windows (WSL2)

#### 症状: ファイルシステム性能低下
```bash
# 解決方法：WSL2内でプロジェクト作業
# /mnt/c/ ではなく ~/projects/ を使用
cp -r /mnt/c/path/to/project ~/projects/
cd ~/projects/project
```

#### 症状: Docker Desktop起動失敗
```powershell
# Windows機能確認
Get-WindowsOptionalFeature -Online -FeatureName containers
Enable-WindowsOptionalFeature -Online -FeatureName containers -All

# Hyper-V確認
Get-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V-All
Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V -All
```

### macOS

#### 症状: Docker Desktop起動遅い
```bash
# Rosetta 2確認（Apple Silicon）
softwareupdate --install-rosetta

# Docker設定確認
# Docker Desktop > Preferences > Resources
# CPU: 4コア以上
# Memory: 4GB以上
```

### Linux

#### 症状: Docker権限問題
```bash
# Dockerグループ確認
groups $USER | grep docker

# グループ追加
sudo usermod -aG docker $USER
newgrp docker

# サービス確認
sudo systemctl status docker
sudo systemctl start docker
```

## 🔧 高度なトラブルシューティング

### ログ収集

#### システム情報収集
```bash
# 環境情報
uname -a
docker --version
cmake --version
arm-none-eabi-gcc --version

# ビルドログ
cmake --build build --verbose > build.log 2>&1

# 実行ログ
./scripts/test-practical-system.sh > test.log 2>&1
```

#### デバッグ情報収集
```bash
# GDBバックトレース
gdb-multiarch build/bin/*.elf
(gdb) run
(gdb) bt
(gdb) info registers
(gdb) disassemble

# QEMUデバッグ
qemu-system-arm -d cpu,exec,int -D qemu.log \
  -M netduinoplus2 -cpu cortex-m4 \
  -kernel build/bin/*.elf -nographic
```

## 📞 サポート情報

### 自己診断チェックリスト

#### ✅ 基本環境
- [ ] Docker Desktop起動済み
- [ ] VSCode + Dev Containers拡張機能インストール済み
- [ ] プロジェクトをDev Containerで開いている
- [ ] 最新のコンテナイメージを使用している

#### ✅ ビルド環境
- [ ] CMakeが正常に動作する
- [ ] Ninjaが利用可能
- [ ] ARM toolchainが正常に動作する
- [ ] 必要な依存関係がインストール済み

#### ✅ 実行環境
- [ ] QEMUが正常に動作する
- [ ] GDBが正常に動作する
- [ ] テストが実行できる
- [ ] デバッグが可能

### エラー報告時の情報

問題報告時は以下の情報を含めてください：

```bash
# 1. 環境情報
uname -a
docker --version
code --version

# 2. エラーメッセージ
# 完全なエラーメッセージをコピー

# 3. 再現手順
# 問題が発生する具体的な手順

# 4. 期待される動作
# 本来どのような動作を期待していたか

# 5. ログファイル
# build.log, test.log, qemu.log など
```

---

**🚀 問題が解決しない場合は、上記の情報を整理してサポートに連絡してください！**