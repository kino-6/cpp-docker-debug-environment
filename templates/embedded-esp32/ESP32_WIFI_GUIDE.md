# ESP32 WiFi開発ガイド

## 🎯 概要

ESP32のWiFi機能を活用したIoT開発環境です。PlatformIOベースで軽量・安定した開発が可能です。

## 🚀 クイックスタート

### 1. 環境起動
```bash
cd templates/embedded-esp32
code .
# Ctrl+Shift+P > Dev Containers: Reopen in Container
```

### 2. WiFi設定
```cpp
// src/main.cpp の以下を変更
const char* ssid = "YourWiFiSSID";        // あなたのWiFi名
const char* password = "YourWiFiPassword"; // あなたのWiFiパスワード
```

### 3. ビルド・フラッシュ
```bash
pio run                    # ビルド
pio run -t upload          # ESP32にフラッシュ
pio device monitor         # シリアルモニタ
```

### 4. Web制御
```
シリアルモニタでIPアドレス確認後、ブラウザでアクセス
例: http://192.168.1.100
```

## 📁 プロジェクト構造

```
embedded-esp32/
├── src/
│   ├── main.cpp              # WiFi LED制御メイン
│   └── wifi_secure.cpp       # セキュア版サンプル
├── include/
│   └── secrets.h.example     # セキュリティ設定テンプレート
├── platformio.ini            # PlatformIO設定
├── .devcontainer/            # Docker開発環境
└── docs/                     # ドキュメント
```

## 🌐 実装済み機能

### WiFi接続
- 自動WiFi接続
- 接続状態監視
- 信号強度表示
- 接続失敗時のエラー処理

### Webサーバー
- HTTP Webサーバー (ポート80)
- レスポンシブWebUI
- リアルタイム状態更新
- RESTful API

### LED制御
- ON/OFF制御
- トグル機能
- 状態表示
- 視覚的フィードバック

### セキュリティ
- 基本認証対応
- 入力検証
- エラーハンドリング
- セキュア設定分離

## 🔧 開発コマンド

### PlatformIO基本コマンド
```bash
pio run                    # ビルド
pio run -t clean          # クリーンビルド
pio run -t upload         # フラッシュ
pio device monitor        # シリアルモニタ
pio run -t upload -t monitor  # フラッシュ＆モニタ
```

### デバッグコマンド
```bash
pio device list           # 接続デバイス一覧
pio system info          # システム情報
pio lib list             # インストール済みライブラリ
```

## 🎯 使用例

### 基本的なLED制御
```
http://192.168.1.100/          # メインページ
http://192.168.1.100/led/on    # LED点灯
http://192.168.1.100/led/off   # LED消灯
http://192.168.1.100/led/toggle # LED切り替え
http://192.168.1.100/status    # ステータス取得
```

### シリアル出力例
```
🚀 ESP32 WiFi LED Controller Starting...
📡 Connecting to WiFi: MyWiFi
✅ WiFi Connected Successfully!
📍 IP Address: 192.168.1.100
📶 Signal Strength: -45 dBm
🌐 Web Server Started!
🔗 Access your ESP32 at: http://192.168.1.100
```

## 🛡️ セキュリティ対策

### 開発時の注意点
1. **WiFi認証情報**: ハードコードしない
2. **基本認証**: 本格運用時は必須
3. **HTTPS**: 可能な限り使用
4. **入力検証**: 全ての入力をチェック
5. **ファイアウォール**: 不要ポート閉鎖

### セキュア版の使用
```cpp
// wifi_secure.cpp を使用する場合
#include "secrets.h"  // 認証情報を分離
// 基本認証、入力検証が実装済み
```

## 🚨 トラブルシューティング

### WiFi接続失敗
```cpp
// 症状: WiFi接続できない
// 確認事項:
1. SSID/パスワードの確認
2. WiFi信号強度の確認
3. 2.4GHz帯の使用確認（5GHzは非対応）
4. ファイアウォール設定の確認
```

### Webサーバーアクセス失敗
```cpp
// 症状: ブラウザでアクセスできない
// 確認事項:
1. IPアドレスの確認（シリアルモニタで表示）
2. 同一ネットワーク内からのアクセス
3. ファイアウォール・セキュリティソフトの確認
4. ESP32の再起動
```

### ビルドエラー
```cpp
// 症状: コンパイルエラー
// 対処法:
pio run -t clean        # クリーンビルド
pio lib update          # ライブラリ更新
pio platform update     # プラットフォーム更新
```

## 📊 パフォーマンス

### メモリ使用量
- **RAM**: 約6.6% (21KB / 327KB)
- **Flash**: 約13.7% (269KB / 1.9MB)
- **ビルド時間**: 約112秒

### ネットワーク性能
- **応答時間**: 通常50ms以下
- **同時接続**: 4クライアント程度
- **データ転送**: HTTP/1.1対応

## 🎯 拡張可能性

### 追加可能な機能
1. **センサー統合**: 温度・湿度・光センサー
2. **クラウド連携**: AWS IoT、Google Cloud IoT
3. **MQTT通信**: リアルタイム双方向通信
4. **OTA更新**: WiFi経由ファームウェア更新
5. **スマートフォンアプリ**: 専用アプリ開発

### 実用プロジェクト例
1. **スマートホーム制御**: 照明・エアコン制御
2. **環境監視**: 温度・湿度・CO2監視
3. **セキュリティシステム**: カメラ・センサー統合
4. **植物監視**: 土壌湿度・自動水やり
5. **駐車場管理**: 車両検知・通知システム

## 📚 参考資料

### ESP32関連
- [ESP32 Arduino Core](https://github.com/espressif/arduino-esp32)
- [ESP32 WiFi Library](https://docs.espressif.com/projects/arduino-esp32/en/latest/api/wifi.html)
- [ESP32 WebServer Library](https://github.com/espressif/arduino-esp32/tree/master/libraries/WebServer)

### PlatformIO関連
- [PlatformIO ESP32 Platform](https://docs.platformio.org/en/latest/platforms/espressif32.html)
- [PlatformIO Library Manager](https://docs.platformio.org/en/latest/librarymanager/)

### セキュリティ関連
- [IoT Security Best Practices](https://www.owasp.org/www-project-iot-security-verification-standard/)
- [ESP32 Security Features](https://docs.espressif.com/projects/esp-idf/en/latest/esp32/security/security.html)

---

**🚀 ESP32 WiFi開発で現代的なIoTシステムを構築しましょう！**