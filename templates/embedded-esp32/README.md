# ESP32 IoT開発環境

## 🎯 概要

ESP32を使用したIoT開発のための包括的な開発環境です。WiFi/Bluetooth内蔵のESP32で、実用的なIoTアプリケーションを開発できます。

## ✨ 特徴

- **ESP-IDF v5.x**: 最新の公式開発フレームワーク
- **WiFi/Bluetooth**: 内蔵無線機能をフル活用
- **Webサーバー**: HTTP API搭載
- **センサー統合**: 温度・湿度・光センサー対応
- **クラウド連携**: MQTT/HTTP通信
- **Dev Container**: 一貫した開発環境

## 🚀 クイックスタート

### 1. 環境起動
```bash
# プロジェクトを開く
cd templates/embedded-esp32
code .

# Dev Container起動
# Ctrl+Shift+P > Dev Containers: Reopen in Container
```

### 2. ビルド・フラッシュ
```bash
# ビルド
idf.py build

# ESP32にフラッシュ
idf.py -p /dev/ttyUSB0 flash monitor

# または VSCodeタスク
# Ctrl+Shift+P > Tasks: Run Task > ESP32: Build and Flash
```

### 3. WiFi LED制御テスト
```bash
# WiFi設定後、ブラウザで以下にアクセス
http://192.168.1.100/api/led/on   # LED点灯
http://192.168.1.100/api/temp     # 温度取得
```

## 📁 プロジェクト構造

```
embedded-esp32/
├── main/                   # メインアプリケーション
│   ├── main.c             # エントリポイント
│   ├── wifi_manager.c     # WiFi接続管理
│   ├── web_server.c       # HTTPサーバー
│   ├── led_controller.c   # LED制御
│   └── sensor_reader.c    # センサー読み取り
├── components/             # 再利用可能コンポーネント
│   ├── http_api/          # HTTP API実装
│   ├── mqtt_client/       # MQTT通信
│   └── sensor_drivers/    # センサードライバー
├── examples/               # 実用サンプル
│   ├── wifi_led_control/  # WiFi LED制御
│   ├── iot_temperature/   # IoT温度監視
│   └── bluetooth_audio/   # Bluetooth音楽
├── tests/                  # テスト環境
├── tools/                  # 開発ツール
└── docs/                   # ドキュメント
```

## 🎯 サンプルプロジェクト

### 1. WiFi LED Controller ⭐ **実装済み**
**機能**: WiFi経由でLED制御
- レスポンシブWebUI
- リアルタイム状態更新
- セキュア認証対応
- RESTful API

**使用方法**:
```bash
# WiFi設定を変更してビルド
pio run -t upload -t monitor
# ブラウザで http://[ESP32のIP] にアクセス
```

### 2. IoT Temperature Monitor **拡張可能**
**機能**: 温度監視システム
- センサーデータ収集
- MQTT通信
- クラウドダッシュボード

### 3. Smart Home Controller **拡張可能**
**機能**: スマートホーム制御
- 複数デバイス制御
- スケジュール機能
- 音声制御連携

## 🔧 開発環境

### ハードウェア要件
- **ESP32開発ボード**: ESP32-DevKitC推奨
- **センサー**: DHT22 (温度・湿度)、LDR (光センサー)
- **LED**: 内蔵LED + 外部RGB LED
- **USB接続**: フラッシュ・デバッグ用

### ソフトウェア要件
- **ESP-IDF**: v5.1以降
- **Python**: 3.8以降
- **VSCode**: Dev Containers拡張機能
- **Docker**: 最新版

## 📊 パフォーマンス

| 機能 | 起動時間 | メモリ使用量 |
|------|----------|--------------|
| WiFi接続 | 3-5秒 | 50KB |
| Webサーバー | 1秒 | 30KB |
| MQTT通信 | 2秒 | 20KB |
| Bluetooth | 5秒 | 80KB |

## 🚨 トラブルシューティング

### よくある問題
1. **ESP32が認識されない**
   - USBドライバー確認
   - ポート権限設定

2. **WiFi接続失敗**
   - SSID/パスワード確認
   - 電波強度確認

3. **フラッシュエラー**
   - ボタン操作確認
   - ケーブル接続確認

## 📚 参考資料

- [ESP-IDF Programming Guide](https://docs.espressif.com/projects/esp-idf/)
- [ESP32 Technical Reference](https://www.espressif.com/sites/default/files/documentation/esp32_technical_reference_manual_en.pdf)
- [Arduino ESP32 Core](https://github.com/espressif/arduino-esp32)

---

**🚀 ESP32でIoT開発を始めましょう！**