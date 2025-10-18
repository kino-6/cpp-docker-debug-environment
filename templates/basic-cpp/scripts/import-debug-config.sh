#!/bin/bash

# C++ Debug Configuration Import Script
# このスクリプトは既存のC++プロジェクトにデバッグ設定をインポートします

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEMPLATE_DIR="$(dirname "$SCRIPT_DIR")"

echo -e "${BLUE}🚀 C++ Debug Configuration Import Tool${NC}"
echo "=================================================="

# Check if we're in a valid project directory
if [ ! -f "CMakeLists.txt" ] && [ ! -f "Makefile" ] && [ ! -d "src" ]; then
    echo -e "${RED}❌ Error: This doesn't appear to be a C++ project directory${NC}"
    echo "   Please run this script from your C++ project root directory"
    echo "   (should contain CMakeLists.txt, Makefile, or src/ directory)"
    exit 1
fi

echo -e "${GREEN}✅ C++ project detected${NC}"

# Create .vscode directory if it doesn't exist
if [ ! -d ".vscode" ]; then
    echo -e "${YELLOW}📁 Creating .vscode directory...${NC}"
    mkdir -p .vscode
fi

# Backup existing configuration
backup_dir=".vscode/backup-$(date +%Y%m%d-%H%M%S)"
if [ -f ".vscode/launch.json" ] || [ -f ".vscode/tasks.json" ]; then
    echo -e "${YELLOW}💾 Backing up existing configuration to ${backup_dir}${NC}"
    mkdir -p "$backup_dir"
    [ -f ".vscode/launch.json" ] && cp ".vscode/launch.json" "$backup_dir/"
    [ -f ".vscode/tasks.json" ] && cp ".vscode/tasks.json" "$backup_dir/"
    [ -f ".vscode/settings.json" ] && cp ".vscode/settings.json" "$backup_dir/"
fi

# Recommend Dev Container approach
echo -e "${BLUE}🐳 This configuration is optimized for Dev Container development${NC}"
echo -e "${GREEN}✅ Recommended: Use Dev Container for consistent cross-platform experience${NC}"
echo ""
echo "Choose your development approach:"
echo "1) 🐳 Dev Container (Recommended) - Consistent, cross-platform"
echo "2) 🖥️  Native Development - Local tools required"
echo "3) 🤖 Auto-detect environment"

read -p "Enter choice (1-3): " choice
case $choice in
    1) 
        environment="container"
        echo -e "${GREEN}🐳 Dev Container selected${NC}"
        ;;
    2) 
        environment="native"
        echo -e "${YELLOW}🖥️  Native development selected${NC}"
        echo -e "${YELLOW}⚠️  Note: Requires local GDB, CMake, and compiler installation${NC}"
        ;;
    3)
        # Auto-detection logic
        if [ -f ".devcontainer/devcontainer.json" ]; then
            environment="container"
            echo -e "${GREEN}🐳 Dev Container environment detected${NC}"
        elif [[ "$OSTYPE" == "msys" ]] || [[ "$OSTYPE" == "win32" ]] || [[ "$OSTYPE" == "cygwin" ]]; then
            environment="native"
            echo -e "${GREEN}🖥️  Windows environment detected${NC}"
        else
            environment="container"
            echo -e "${GREEN}🐳 Defaulting to Dev Container (recommended)${NC}"
        fi
        ;;
    *) 
        echo -e "${RED}Invalid choice, defaulting to Dev Container${NC}"
        environment="container"
        ;;
esac

# Copy appropriate configuration files
echo -e "${BLUE}📋 Installing debug configuration for ${environment} environment...${NC}"

if [ "$environment" = "container" ]; then
    # Copy container configuration (default)
    cp "$TEMPLATE_DIR/.vscode/launch.json" ".vscode/"
    cp "$TEMPLATE_DIR/.vscode/tasks.json" ".vscode/"
    echo -e "${GREEN}✅ Dev Container debug configuration installed${NC}"
    echo -e "${BLUE}📝 Usage:${NC}"
    echo "   1. Reopen in Dev Container (Ctrl+Shift+P → 'Dev Containers: Reopen in Container')"
    echo "   2. Run task: 'Fresh Configure & Build'"
    echo "   3. Press F5 → Select '🚀 Quick Debug (No Build)'"
else
    # Copy native configuration
    cp "$TEMPLATE_DIR/.vscode/native/launch.json" ".vscode/"
    cp "$TEMPLATE_DIR/.vscode/native/tasks.json" ".vscode/"
    echo -e "${GREEN}✅ Native debug configuration installed${NC}"
    echo -e "${YELLOW}⚠️  Requirements: GDB, CMake, Ninja, C++ compiler${NC}"
    echo -e "${BLUE}📝 Usage:${NC}"
    echo "   1. Press Ctrl+Shift+B → Select 'CMake Build'"
    echo "   2. Press F5 → Select '🚀 Quick Debug (No Build)'"
fi

# Copy devcontainer configuration if it doesn't exist
if [ "$environment" = "container" ] && [ ! -d ".devcontainer" ]; then
    echo -e "${YELLOW}🐳 Installing Dev Container configuration...${NC}"
    cp -r "$TEMPLATE_DIR/.devcontainer" "./"
    echo -e "${GREEN}✅ Dev Container configuration installed${NC}"
fi

# Install README
cp "$TEMPLATE_DIR/.vscode/README.md" ".vscode/"

# Project-specific adjustments
echo -e "${BLUE}🔧 Adjusting configuration for your project...${NC}"

# Detect project name from directory or CMakeLists.txt
project_name=$(basename "$(pwd)")
if [ -f "CMakeLists.txt" ]; then
    cmake_project=$(grep -i "project(" CMakeLists.txt | head -1 | sed 's/.*project(\s*\([^)]*\).*/\1/' | tr -d ' ')
    if [ -n "$cmake_project" ]; then
        project_name="$cmake_project"
    fi
fi

echo -e "${BLUE}📦 Detected project name: ${project_name}${NC}"

# Update configuration files with project name
if [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS sed
    sed -i '' "s/BasicCppProject/${project_name}/g" .vscode/launch.json
    sed -i '' "s/BasicCppProject/${project_name}/g" .vscode/tasks.json
else
    # Linux/Windows sed
    sed -i "s/BasicCppProject/${project_name}/g" .vscode/launch.json
    sed -i "s/BasicCppProject/${project_name}/g" .vscode/tasks.json
fi

echo -e "${GREEN}🎉 Debug configuration import completed!${NC}"
echo ""
echo -e "${BLUE}📋 Next Steps:${NC}"
if [ "$environment" = "container" ]; then
    echo "   1. 🐳 Reopen in Dev Container (Ctrl+Shift+P → 'Dev Containers: Reopen in Container')"
    echo "   2. 🔧 Run 'Fresh Configure & Build' task"
    echo "   3. 🎯 Set breakpoints and press F5 → '🚀 Quick Debug (No Build)'"
    echo ""
    echo -e "${GREEN}🎉 Enjoy consistent, cross-platform C++ debugging!${NC}"
else
    echo "   1. 🔧 Install requirements: GDB, CMake, Ninja, C++ compiler"
    echo "   2. 🏗️  Build project (Ctrl+Shift+B → 'CMake Build')"
    echo "   3. 🎯 Set breakpoints and press F5 → '🚀 Quick Debug (No Build)'"
    echo ""
    echo -e "${YELLOW}💡 Consider switching to Dev Container for easier setup!${NC}"
fi
echo ""
echo -e "${YELLOW}💡 Tip: Check .vscode/README.md for detailed usage instructions${NC}"

if [ -n "$backup_dir" ]; then
    echo -e "${BLUE}🔄 Restore backup: cp ${backup_dir}/* .vscode/${NC}"
fi