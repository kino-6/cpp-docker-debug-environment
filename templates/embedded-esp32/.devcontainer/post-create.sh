#!/bin/bash

echo "=== ESP32 Development Environment Setup ==="

# Create cache directory for ESP-IDF tools
mkdir -p /opt/esp/.espressif

# Install additional development tools
echo "Installing additional tools..."
apt-get update
apt-get install -y \
    git \
    nano \
    tree \
    htop \
    screen \
    python3-pip

# Install Python packages for ESP32 development
echo "Installing Python packages..."
pip3 install --user esptool

# Create useful aliases
echo "Setting up aliases..."
cat >> ~/.bashrc << 'EOF'

# ESP32 Development Aliases
alias idf='idf.py'
alias build='idf.py build'
alias flash='idf.py flash'
alias monitor='idf.py monitor'
alias clean='idf.py clean'
alias menuconfig='idf.py menuconfig'
alias size='idf.py size'
alias erase='idf.py erase-flash'

# Quick commands
alias bf='idf.py build && idf.py flash'
alias bfm='idf.py build && idf.py flash && idf.py monitor'
alias fm='idf.py flash && idf.py monitor'

EOF

# Set up ESP-IDF environment
echo "Setting up ESP-IDF environment..."
source /opt/esp/idf/export.sh

# Verify installation
echo "Verifying ESP-IDF installation..."
idf.py --version

# Set proper permissions for USB devices (for flashing)
echo "Setting up USB device permissions..."
usermod -a -G dialout esp 2>/dev/null || true

echo ""
echo "=== ESP32 Development Environment Setup Complete ==="
echo ""
echo "🎯 Available Commands:"
echo "   idf.py build          - Build project"
echo "   idf.py flash          - Flash to ESP32"
echo "   idf.py monitor        - Serial monitor"
echo "   idf.py menuconfig     - Configuration menu"
echo ""
echo "🚀 Quick Aliases:"
echo "   bf                    - Build and flash"
echo "   bfm                   - Build, flash, and monitor"
echo "   esp32-ports           - List available ports"
echo "   esp32-setup-project   - Create new project"
echo ""
echo "📚 Documentation:"
echo "   https://docs.espressif.com/projects/esp-idf/"
echo ""
echo "✅ Ready for ESP32 development!"