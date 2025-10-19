#!/bin/bash

echo "=== Installing Renode ARM Simulator ==="

# Check if Renode is already installed
if command -v renode &> /dev/null; then
    echo "Renode is already installed:"
    renode --version | head -1
    exit 0
fi

echo "Installing Renode dependencies..."

# Install additional Mono dependencies
sudo apt-get update
sudo apt-get install -y --no-install-recommends \
    mono-complete \
    gtk-sharp2-dev \
    screen \
    policykit-1 \
    software-properties-common \
    gnupg

echo "Downloading Renode..."

# Download and install Renode
cd /tmp
wget -q https://github.com/renode/renode/releases/download/v1.14.0/renode_1.14.0_amd64.deb

if [ $? -ne 0 ]; then
    echo "❌ Failed to download Renode. Trying alternative approach..."
    
    # Alternative: Install from portable version
    echo "Downloading portable Renode..."
    wget -q https://github.com/renode/renode/releases/download/v1.14.0/renode-1.14.0.linux-portable.tar.gz
    
    if [ $? -eq 0 ]; then
        echo "Installing portable Renode..."
        sudo tar -xzf renode-1.14.0.linux-portable.tar.gz -C /opt/
        sudo ln -sf /opt/renode_1.14.0_portable/renode /usr/local/bin/renode
        sudo chmod +x /usr/local/bin/renode
        
        echo "✅ Portable Renode installed successfully"
        renode --version | head -1
    else
        echo "❌ Failed to download portable Renode"
        echo "⚠️  Renode installation failed, but QEMU is still available"
        exit 1
    fi
else
    echo "Installing Renode package..."
    sudo dpkg -i renode_1.14.0_amd64.deb || sudo apt-get install -f -y
    
    if [ $? -eq 0 ]; then
        echo "✅ Renode installed successfully"
        renode --version | head -1
    else
        echo "❌ Renode package installation failed"
        echo "⚠️  Renode installation failed, but QEMU is still available"
        exit 1
    fi
fi

# Clean up
rm -f /tmp/renode_1.14.0_amd64.deb
rm -f /tmp/renode-1.14.0.linux-portable.tar.gz

echo "Renode installation completed!"
echo "You can now use Renode for ARM Cortex-M simulation."