# ESP32 WiFi LED Controller - API仕様書

## 🌐 **API概要**

ESP32 WiFi LED ControllerのRESTful API仕様です。HTTP/1.1プロトコルでLED制御とデバイス状態取得が可能です。

## 📡 **ベースURL**

```
http://[ESP32_IP_ADDRESS]/
例: http://192.168.1.100/
```

## 🔗 **エンドポイント一覧**

### **1. メインページ**
```http
GET /
```

**説明**: レスポンシブWebUIを表示

**レスポンス**:
- **Content-Type**: `text/html`
- **ステータス**: `200 OK`
- **ボディ**: HTML5 + CSS3 + JavaScript

**機能**:
- LED制御ボタン
- リアルタイム状態更新
- デバイス情報表示
- レスポンシブデザイン

---

### **2. LED点灯**
```http
GET /led/on
```

**説明**: LEDを点灯させる

**レスポンス**:
```json
Content-Type: text/plain
Status: 200 OK
Body: "✅ LED is ON"
```

**副作用**:
- GPIO2ピンをHIGHに設定
- 内部状態を`ledState = true`に更新
- シリアル出力: `"LED Control: ON -> ✅ LED is ON"`

---

### **3. LED消灯**
```http
GET /led/off
```

**説明**: LEDを消灯させる

**レスポンス**:
```json
Content-Type: text/plain
Status: 200 OK
Body: "❌ LED is OFF"
```

**副作用**:
- GPIO2ピンをLOWに設定
- 内部状態を`ledState = false`に更新
- シリアル出力: `"LED Control: OFF -> ❌ LED is OFF"`

---

### **4. LED切り替え**
```http
GET /led/toggle
```

**説明**: LEDの状態を切り替える（ON→OFF、OFF→ON）

**レスポンス**:
```json
Content-Type: text/plain
Status: 200 OK

// LED点灯時
Body: "✅ LED is ON (toggled)"

// LED消灯時  
Body: "❌ LED is OFF (toggled)"
```

**副作用**:
- 現在の状態を反転
- GPIO2ピンの状態を切り替え
- 内部状態を更新
- シリアル出力

---

### **5. デバイス状態取得**
```http
GET /status
```

**説明**: ESP32デバイスの詳細状態を取得

**レスポンス**:
```json
Content-Type: text/html
Status: 200 OK
```

**レスポンスボディ例**:
```html
<strong>📊 Device Status:</strong><br>
• LED State: ON 💡<br>
• Uptime: 1234 seconds<br>
• Free Heap: 245760 bytes<br>
• WiFi RSSI: -45 dBm<br>
• IP Address: 192.168.1.100
```

**含まれる情報**:
- **LED状態**: ON/OFF + 絵文字
- **稼働時間**: 起動からの秒数
- **空きメモリ**: ヒープメモリ使用量
- **WiFi信号強度**: RSSI値（dBm）
- **IPアドレス**: 現在のローカルIP

---

### **6. 404エラー**
```http
GET /invalid-path
```

**説明**: 存在しないパスへのアクセス

**レスポンス**:
```json
Content-Type: text/plain
Status: 404 Not Found
Body: "404: Page not found"
```

## 🔧 **技術仕様**

### **HTTPヘッダー**
```http
Server: ESP32WebServer
Connection: close
Cache-Control: no-cache
```

### **レスポンス時間**
- **通常**: 10-50ms
- **WiFi弱電界**: 100-500ms
- **高負荷時**: 最大1秒

### **同時接続**
- **推奨**: 1-2クライアント
- **最大**: 4クライアント
- **制限**: メモリ使用量による

### **エラーハンドリング**
```cpp
// WiFi切断時
if (WiFi.status() != WL_CONNECTED) {
    // 自動再接続試行
    WiFi.reconnect();
}

// メモリ不足時
if (ESP.getFreeHeap() < 10000) {
    // 警告ログ出力
    Serial.println("⚠️ Low memory warning");
}
```

## 🛡️ **セキュリティ**

### **現在の実装**
- **認証**: なし（開発版）
- **暗号化**: HTTP（平文）
- **入力検証**: 基本的なパス検証のみ

### **本格運用時の推奨対策**
```cpp
// 基本認証
server.authenticate("admin", "password");

// HTTPS対応
WiFiClientSecure client;

// 入力検証
if (!isValidInput(request)) {
    server.send(400, "text/plain", "Bad Request");
    return;
}

// レート制限
if (requestCount > MAX_REQUESTS_PER_MINUTE) {
    server.send(429, "text/plain", "Too Many Requests");
    return;
}
```

## 📱 **クライアント実装例**

### **JavaScript (Webブラウザ)**
```javascript
// LED制御
async function controlLED(action) {
    try {
        const response = await fetch(`/led/${action}`);
        const result = await response.text();
        console.log(result);
        return result;
    } catch (error) {
        console.error('LED制御エラー:', error);
    }
}

// 状態取得
async function getStatus() {
    try {
        const response = await fetch('/status');
        const status = await response.text();
        document.getElementById('status').innerHTML = status;
    } catch (error) {
        console.error('状態取得エラー:', error);
    }
}

// 使用例
controlLED('on');     // LED点灯
controlLED('off');    // LED消灯
controlLED('toggle'); // LED切り替え
getStatus();          // 状態取得
```

### **Python (requests)**
```python
import requests

# ベースURL
base_url = "http://192.168.1.100"

# LED制御
def control_led(action):
    try:
        response = requests.get(f"{base_url}/led/{action}")
        print(f"LED {action}: {response.text}")
        return response.text
    except requests.RequestException as e:
        print(f"エラー: {e}")

# 状態取得
def get_status():
    try:
        response = requests.get(f"{base_url}/status")
        print(f"Status: {response.text}")
        return response.text
    except requests.RequestException as e:
        print(f"エラー: {e}")

# 使用例
control_led('on')     # LED点灯
control_led('off')    # LED消灯
control_led('toggle') # LED切り替え
get_status()          # 状態取得
```

### **curl (コマンドライン)**
```bash
# LED制御
curl http://192.168.1.100/led/on
curl http://192.168.1.100/led/off
curl http://192.168.1.100/led/toggle

# 状態取得
curl http://192.168.1.100/status

# メインページ
curl http://192.168.1.100/
```

## 🚀 **拡張API案**

### **センサーデータ取得**
```http
GET /api/sensors
GET /api/sensors/temperature
GET /api/sensors/humidity
```

### **設定変更**
```http
POST /api/config
PUT /api/wifi
```

### **ファームウェア更新**
```http
POST /api/ota/update
GET /api/ota/status
```

### **WebSocket (リアルタイム)**
```javascript
const ws = new WebSocket('ws://192.168.1.100/ws');
ws.onmessage = (event) => {
    const data = JSON.parse(event.data);
    console.log('リアルタイムデータ:', data);
};
```

## 📊 **パフォーマンス指標**

### **レスポンス時間**
| エンドポイント | 平均 | 最大 |
|---------------|------|------|
| `/` | 20ms | 100ms |
| `/led/*` | 10ms | 50ms |
| `/status` | 15ms | 80ms |

### **メモリ使用量**
| 機能 | RAM使用量 | Flash使用量 |
|------|-----------|-------------|
| WebServer | 15KB | 50KB |
| HTML/CSS/JS | 8KB | 20KB |
| API処理 | 5KB | 15KB |

---

**🌐 ESP32 WiFi LED Controller APIで簡単IoT制御！**