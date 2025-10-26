# ESP32 WiFi開発環境 - セットアップガイド

## 🎯 **概要**

ESP32 WiFi LED Controllerの完全セットアップガイドです。初心者から上級者まで、段階的に環境構築できます。

## 📋 **前提条件**

### **必須要件**
- **Docker Desktop**: 最新版
- **VSCode**: 最新版
- **Dev Containers拡張**: VSCode拡張機能
- **Git**: バージョン管理用

### **推奨要件**
- **ESP32開発ボード**: ESP32-DevKitC V4推奨
- **USBケーブル**: データ転送対応（充電専用不可）
- **WiFiネットワーク**: 2.4GHz帯対応

### **システム要件**
- **OS**: Windows 10/11, macOS 10.15+, Ubuntu 18.04+
- **RAM**: 8GB以上推奨
- **ストレージ**: 5GB以上の空き容量

## 🚀 **クイックスタート（5分）**

### **1. プロジェクト取得**
```bash
# プロジェクトをクローン
git clone <repository-url>
cd CppDebugEnv/templates/embedded-esp32

# VSCodeで開く
code .
```

### **2. Dev Container起動**
```bash
# VSCodeコマンドパレット (Ctrl+Shift+P)
> Dev Containers: Reopen in Container

# または左下の緑ボタンクリック
# "Reopen in Container" を選択
```

### **3. WiFi設定**
```cpp
// src/main.cpp の設定を変更
const char* ssid = "YourWiFiName";        // あなたのWiFi名
const char* password = "YourWiFiPassword"; // あなたのWiFiパスワード
```

### **4. ビルド確認**
```bash
# ターミナルで実行
pio run

# 成功メッセージ確認
# "SUCCESS: Build completed successfully"
```

### **5. 動作確認（実機なし）**
```bash
# ビルド成功 = 環境構築完了
# 実機接続時は以下で動作確認
# pio run -t upload -t monitor
```

## 🔧 **詳細セットアップ**

### **Step 1: 開発環境準備**

#### **Docker Desktop インストール**
```bash
# Windows
# https://desktop.docker.com/win/main/amd64/Docker%20Desktop%20Installer.exe

# macOS
# https://desktop.docker.com/mac/main/amd64/Docker.dmg

# Linux (Ubuntu)
sudo apt update
sudo apt install docker.io docker-compose
sudo usermod -aG docker $USER
```

#### **VSCode + 拡張機能**
```bash
# VSCode インストール
# https://code.visualstudio.com/

# 必須拡張機能
# - Dev Containers (ms-vscode-remote.remote-containers)
# - PlatformIO IDE (platformio.platformio-ide)
```

### **Step 2: プロジェクト設定**

#### **WiFi設定（セキュア版）**
```bash
# 1. 設定ファイル作成
cp config/wifi_config.ini.example config/wifi_config_local.ini

# 2. 認証情報設定
# config/wifi_config_local.ini を編集
[wifi]
ssid = "YourWiFiName"
password = "YourWiFiPassword"
```

#### **platformio.ini 設定**
```ini
[env:esp32dev]
platform = espressif32
board = esp32dev
framework = arduino
monitor_speed = 115200

# セキュア設定（推奨）
build_flags = 
    -Os
    -DCORE_DEBUG_LEVEL=1
    -DWIFI_ENABLED=1
    -DWEBSERVER_ENABLED=1
    -DUSE_CONFIG_FILE  # 設定ファイル使用

# 開発用設定（簡単）
# build_flags = 
#     -DWIFI_SSID='"YourWiFiName"'
#     -DWIFI_PASSWORD='"YourWiFiPassword"'
```

### **Step 3: ビルド・テスト**

#### **ビルド確認**
```bash
# クリーンビルド
pio run -t clean
pio run

# 成功時の出力例
Processing esp32dev (platform: espressif32; board: esp32dev; framework: arduino)
...
RAM:   [=         ]  13.8% (used 45104 bytes from 327680 bytes)
Flash: [======    ]  59.6% (used 780869 bytes from 1310720 bytes)
========================= [SUCCESS] Took 11.07 seconds =========================
```

#### **依存関係確認**
```bash
# ライブラリ確認
pio lib list

# プラットフォーム確認
pio platform list

# デバイス確認（実機接続時）
pio device list
```

### **Step 4: 実機接続（オプション）**

#### **ESP32接続**
```bash
# 1. ESP32をUSBで接続
# 2. ポート確認
pio device list

# 3. フラッシュ
pio run -t upload

# 4. シリアルモニタ
pio device monitor
```

#### **動作確認**
```bash
# シリアル出力例
🚀 ESP32 WiFi LED Controller Starting...
📡 Connecting to WiFi: YourWiFiName
✅ WiFi Connected Successfully!
📍 IP Address: 192.168.1.100
🌐 Web Server Started!
🔗 Access your ESP32 at: http://192.168.1.100
```

#### **Web制御テスト**
```bash
# ブラウザでアクセス
http://192.168.1.100/

# API テスト
curl http://192.168.1.100/led/on
curl http://192.168.1.100/status
```

## 🛡️ **セキュリティ設定**

### **開発環境のセキュリティ**

#### **認証情報の保護**
```bash
# .gitignore 確認
config/wifi_config_local.ini
secrets.h
*.local.*

# 環境変数使用（推奨）
export WIFI_SSID="YourWiFiName"
export WIFI_PASSWORD="YourWiFiPassword"
```

#### **基本認証設定**
```cpp
// src/main.cpp に追加
const char* www_username = "admin";
const char* www_password = "yourpassword";

void handleRoot() {
    if (!server.authenticate(www_username, www_password)) {
        return server.requestAuthentication();
    }
    server.send(200, "text/html", htmlPage);
}
```

### **ネットワークセキュリティ**
```bash
# ファイアウォール設定（Windows）
# Windows Defender > 詳細設定 > 受信の規則
# ポート80を特定IPからのみ許可

# ファイアウォール設定（Linux）
sudo ufw allow from 192.168.1.0/24 to any port 80
sudo ufw enable
```

## 🚨 **トラブルシューティング**

### **よくある問題と解決法**

#### **1. Docker起動失敗**
```bash
# 症状: "Docker daemon is not running"
# 解決法:
# Windows: Docker Desktop を起動
# Linux: sudo systemctl start docker
# macOS: Docker Desktop を起動
```

#### **2. Dev Container起動失敗**
```bash
# 症状: "Failed to connect to the remote extension host server"
# 解決法:
1. VSCode再起動
2. Docker Desktop再起動
3. 拡張機能の再インストール
4. WSL2更新（Windows）
```

#### **3. ビルドエラー**
```bash
# 症状: "Platform 'espressif32' not found"
# 解決法:
pio platform install espressif32

# 症状: "Library not found"
# 解決法:
pio lib install "ESP32WebServer"
```

#### **4. WiFi接続失敗**
```bash
# 症状: "WiFi Connection Failed"
# 確認事項:
1. SSID/パスワードの正確性
2. 2.4GHz帯の使用（5GHz非対応）
3. WiFi信号強度
4. ファイアウォール設定
5. MACアドレスフィルタリング
```

#### **5. Web接続失敗**
```bash
# 症状: ブラウザでアクセスできない
# 確認事項:
1. IPアドレスの確認（シリアルモニタ）
2. 同一ネットワーク内からのアクセス
3. ファイアウォール設定
4. ESP32の再起動
5. ブラウザキャッシュクリア
```

### **デバッグ方法**

#### **シリアルデバッグ**
```cpp
// デバッグ出力追加
Serial.begin(115200);
Serial.println("Debug: WiFi connecting...");
Serial.print("Debug: IP = ");
Serial.println(WiFi.localIP());
```

#### **ネットワークデバッグ**
```bash
# ping テスト
ping 192.168.1.100

# ポートスキャン
nmap -p 80 192.168.1.100

# HTTP テスト
curl -v http://192.168.1.100/
```

## 📊 **パフォーマンス最適化**

### **ビルド最適化**
```ini
# platformio.ini
build_flags = 
    -Os                    # サイズ最適化
    -DCORE_DEBUG_LEVEL=0   # デバッグ無効
    -DARDUINO_LOOP_STACK_SIZE=8192  # スタックサイズ

# 並列ビルド
build_parallel = true
```

### **メモリ最適化**
```cpp
// 文字列をFLASHに配置
const char* htmlPage PROGMEM = R"rawliteral(
<!DOCTYPE html>
...
)rawliteral";

// 動的メモリ使用量監視
void checkMemory() {
    Serial.printf("Free heap: %d bytes\n", ESP.getFreeHeap());
    if (ESP.getFreeHeap() < 10000) {
        Serial.println("⚠️ Low memory warning");
    }
}
```

### **WiFi最適化**
```cpp
// WiFi省電力設定
WiFi.setSleep(false);  // 高性能モード
WiFi.setTxPower(WIFI_POWER_19_5dBm);  // 最大出力

// 接続最適化
WiFi.setAutoReconnect(true);
WiFi.persistent(false);
```

## 🎯 **次のステップ**

### **機能拡張**
1. **センサー統合**: 温度・湿度・光センサー
2. **MQTT通信**: クラウドサービス連携
3. **OTA更新**: WiFi経由ファームウェア更新
4. **スマートフォンアプリ**: 専用アプリ開発

### **学習リソース**
- [ESP32 Arduino Core](https://github.com/espressif/arduino-esp32)
- [PlatformIO Documentation](https://docs.platformio.org/)
- [ESP32 Technical Reference](https://www.espressif.com/sites/default/files/documentation/esp32_technical_reference_manual_en.pdf)

---

**🚀 ESP32 WiFi開発環境のセットアップ完了！IoT開発を始めましょう！**