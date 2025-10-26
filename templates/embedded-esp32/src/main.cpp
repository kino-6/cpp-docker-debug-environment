/**
 * @file main.cpp
 * @brief ESP32 WiFi LED Controller with Web Interface
 */

#include <WiFi.h>
#include <WebServer.h>
#include "config_loader.h"

// WiFi Configuration (loaded from config_loader.h)
const char* ssid = WIFI_SSID;
const char* password = WIFI_PASSWORD;

// Web server on port 80
WebServer server(80);

// LED pin
#define LED_PIN 2

// LED state
bool ledState = false;

// HTML page for web interface
const char* htmlPage = R"rawliteral(
<!DOCTYPE html>
<html>
<head>
    <title>ESP32 WiFi LED Controller</title>
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <style>
        body { font-family: Arial, sans-serif; margin: 20px; background: #f0f0f0; }
        .container { max-width: 600px; margin: 0 auto; background: white; padding: 20px; border-radius: 10px; box-shadow: 0 2px 10px rgba(0,0,0,0.1); }
        h1 { color: #333; text-align: center; }
        .button { background-color: #4CAF50; color: white; padding: 15px 30px; border: none; border-radius: 5px; cursor: pointer; margin: 10px; font-size: 16px; }
        .button:hover { background-color: #45a049; }
        .button.off { background-color: #f44336; }
        .button.off:hover { background-color: #da190b; }
        .status { font-size: 18px; margin: 20px 0; padding: 10px; background: #e7f3ff; border-radius: 5px; }
        .info { background: #fff3cd; padding: 10px; border-radius: 5px; margin: 10px 0; }
    </style>
    <script>
        function controlLED(action) {
            fetch('/led/' + action)
                .then(response => response.text())
                .then(data => {
                    document.getElementById('status').innerHTML = data;
                    updateButtons(action);
                })
                .catch(error => console.error('Error:', error));
        }
        
        function updateButtons(action) {
            const onBtn = document.getElementById('onBtn');
            const offBtn = document.getElementById('offBtn');
            if (action === 'on') {
                onBtn.style.backgroundColor = '#4CAF50';
                offBtn.style.backgroundColor = '#ccc';
            } else {
                onBtn.style.backgroundColor = '#ccc';
                offBtn.style.backgroundColor = '#f44336';
            }
        }
        
        function updateStatus() {
            fetch('/status')
                .then(response => response.text())
                .then(data => {
                    document.getElementById('deviceInfo').innerHTML = data;
                })
                .catch(error => console.error('Error:', error));
        }
        
        setInterval(updateStatus, 5000);
        window.onload = updateStatus;
    </script>
</head>
<body>
    <div class="container">
        <h1>ESP32 WiFi LED Controller</h1>
        
        <div class="info">
            <strong>WiFi Connected!</strong><br>
            Control your ESP32 LED from anywhere on your network.
        </div>
        
        <div class="status" id="status">LED Status: Unknown</div>
        
        <div style="text-align: center;">
            <button id="onBtn" class="button" onclick="controlLED('on')">Turn LED ON</button>
            <button id="offBtn" class="button off" onclick="controlLED('off')">Turn LED OFF</button>
            <button class="button" onclick="controlLED('toggle')" style="background-color: #ff9800;">Toggle LED</button>
        </div>
        
        <div class="info" id="deviceInfo">Loading device info...</div>
        
        <div class="info">
            <strong>Development Info:</strong><br>
            This is a PlatformIO ESP32 project with WiFi-enabled LED control.
        </div>
    </div>
</body>
</html>
)rawliteral";

// Handle root page
void handleRoot() {
    server.send(200, "text/html", htmlPage);
}

// Handle LED ON
void handleLEDOn() {
    digitalWrite(LED_PIN, HIGH);
    ledState = true;
    String response = "✅ LED is ON";
    server.send(200, "text/plain", response);
    Serial.println("LED Control: ON -> " + response);
}

// Handle LED OFF
void handleLEDOff() {
    digitalWrite(LED_PIN, LOW);
    ledState = false;
    String response = "❌ LED is OFF";
    server.send(200, "text/plain", response);
    Serial.println("LED Control: OFF -> " + response);
}

// Handle LED Toggle
void handleLEDToggle() {
    ledState = !ledState;
    digitalWrite(LED_PIN, ledState ? HIGH : LOW);
    String response = ledState ? "✅ LED is ON (toggled)" : "❌ LED is OFF (toggled)";
    server.send(200, "text/plain", response);
    Serial.println("LED Control: TOGGLE -> " + response);
}

// Handle status request
void handleStatus() {
    String status = "<strong>📊 Device Status:</strong><br>";
    status += "• LED State: " + String(ledState ? "ON 💡" : "OFF 🔌") + "<br>";
    status += "• Uptime: " + String(millis() / 1000) + " seconds<br>";
    status += "• Free Heap: " + String(ESP.getFreeHeap()) + " bytes<br>";
    status += "• WiFi RSSI: " + String(WiFi.RSSI()) + " dBm<br>";
    status += "• IP Address: " + WiFi.localIP().toString();
    
    server.send(200, "text/html", status);
}

// Handle 404 errors
void handleNotFound() {
    server.send(404, "text/plain", "404: Page not found");
}

void setup() {
    Serial.begin(115200);
    pinMode(LED_PIN, OUTPUT);
    digitalWrite(LED_PIN, LOW);
    
    Serial.println();
    Serial.println("🚀 ESP32 WiFi LED Controller Starting...");
    
    // Connect to WiFi
    Serial.print("📡 Connecting to WiFi: ");
    Serial.println(ssid);
    
    WiFi.begin(ssid, password);
    
    // Wait for connection with timeout
    int attempts = 0;
    while (WiFi.status() != WL_CONNECTED && attempts < 30) {
        delay(1000);
        Serial.print(".");
        attempts++;
    }
    
    if (WiFi.status() == WL_CONNECTED) {
        Serial.println();
        Serial.println("✅ WiFi Connected Successfully!");
        Serial.print("📍 IP Address: ");
        Serial.println(WiFi.localIP());
        Serial.print("📶 Signal Strength: ");
        Serial.print(WiFi.RSSI());
        Serial.println(" dBm");
        
        // Blink LED to indicate successful connection
        for (int i = 0; i < 6; i++) {
            digitalWrite(LED_PIN, HIGH);
            delay(200);
            digitalWrite(LED_PIN, LOW);
            delay(200);
        }
    } else {
        Serial.println();
        Serial.println("❌ WiFi Connection Failed!");
        Serial.println("Please check your WiFi credentials and try again.");
        
        // Continuous fast blink to indicate error
        while (true) {
            digitalWrite(LED_PIN, HIGH);
            delay(100);
            digitalWrite(LED_PIN, LOW);
            delay(100);
        }
    }
    
    // Set up web server routes
    server.on("/", handleRoot);
    server.on("/led/on", handleLEDOn);
    server.on("/led/off", handleLEDOff);
    server.on("/led/toggle", handleLEDToggle);
    server.on("/status", handleStatus);
    server.onNotFound(handleNotFound);
    
    // Start web server
    server.begin();
    Serial.println("🌐 Web Server Started!");
    Serial.println("🔗 Access your ESP32 at: http://" + WiFi.localIP().toString());
    Serial.println("📱 Open this URL in your browser to control the LED");
    Serial.println();
}

void loop() {
    server.handleClient();
    
    // Optional: Print status every 30 seconds
    static unsigned long lastStatus = 0;
    if (millis() - lastStatus > 30000) {
        lastStatus = millis();
        Serial.println("📊 Status: LED=" + String(ledState ? "ON" : "OFF") + 
                      ", Clients=" + String(WiFi.softAPgetStationNum()) + 
                      ", Uptime=" + String(millis()/1000) + "s");
    }
}