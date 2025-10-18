# Debug Configuration Import Scripts

## 🚀 Overview

These scripts allow you to import optimized C++ debug configurations into existing projects, providing the same high-performance debugging experience as the basic-cpp template.

## 📁 Files

- `import-debug-config.sh` - Linux/macOS/WSL script
- `import-debug-config.ps1` - Windows PowerShell script
- `README.md` - This documentation

## 🎯 Features

- **🔍 Auto Environment Detection** - Automatically detects Dev Container vs Native Windows
- **💾 Safe Backup** - Backs up existing configurations before import
- **📦 Project Name Detection** - Automatically adjusts configuration for your project
- **🐳 Dev Container Support** - Installs container configuration if needed
- **⚡ High-Speed Debugging** - Provides "Quick Debug" options for fast iteration

## 🚀 Usage

### Linux/macOS/WSL

```bash
# Navigate to your C++ project directory
cd /path/to/your/cpp/project

# Run the import script
bash /path/to/templates/basic-cpp/scripts/import-debug-config.sh
```

### Windows PowerShell

```powershell
# Navigate to your C++ project directory
cd C:\path\to\your\cpp\project

# Run the import script
PowerShell -ExecutionPolicy Bypass -File C:\path\to\templates\basic-cpp\scripts\import-debug-config.ps1
```

### Manual Environment Selection

```bash
# Force container environment
bash import-debug-config.sh container

# Force native environment  
bash import-debug-config.sh native
```

```powershell
# Force container environment
.\import-debug-config.ps1 -Environment container

# Force native environment
.\import-debug-config.ps1 -Environment native
```

## 📋 Requirements

### Your Project Should Have:
- `CMakeLists.txt` OR `Makefile` OR `src/` directory
- C++ source files

### System Requirements:
- **Container**: Docker + VSCode Dev Containers extension
- **Native**: GDB, CMake, Ninja (recommended)

## 🔧 What Gets Installed

### All Environments:
- `.vscode/launch.json` - Debug configurations
- `.vscode/tasks.json` - Build tasks
- `.vscode/README.md` - Usage documentation

### Container Environment Only:
- `.devcontainer/` - Dev Container configuration (if not present)

### Configurations Installed:

#### 🐳 Container Environment:
- **🚀 Quick Debug Container (No Build)** - Fastest debugging
- **Debug Basic C++ Project (Container)** - Manual build control
- **Debug Basic C++ Project (Auto Build)** - Automatic build

#### 🖥️ Native Environment:
- **🚀 Quick Debug (No Build)** - Fastest debugging
- **Debug Basic C++ Project** - Manual build control
- **Debug Basic C++ Project (Simple)** - Auto build with entry stop
- **Attach to Process** - Attach to running process

## 🎮 Post-Installation Workflow

### Container Environment:
1. **Reopen in Container**: `Ctrl+Shift+P` → "Dev Containers: Reopen in Container"
2. **Initial Build**: Run task "Container: Fresh Configure & Build"
3. **Set Breakpoints**: Click line numbers or press `F9`
4. **Quick Debug**: `F5` → Select "🚀 Quick Debug Container (No Build)"

### Native Environment:
1. **Build Project**: `Ctrl+Shift+B` → Select "CMake Build"
2. **Set Breakpoints**: Click line numbers or press `F9`
3. **Quick Debug**: `F5` → Select "🚀 Quick Debug (No Build)"

## 🔄 Backup & Restore

### Automatic Backup:
- Existing configurations are backed up to `.vscode/backup-YYYYMMDD-HHMMSS/`
- Includes `launch.json`, `tasks.json`, `settings.json`

### Manual Restore:
```bash
# Restore from backup
cp .vscode/backup-20241018-143022/* .vscode/
```

## 🛠️ Troubleshooting

### Script Won't Run:
```bash
# Make executable (Linux/macOS)
chmod +x import-debug-config.sh

# Check PowerShell execution policy (Windows)
Get-ExecutionPolicy
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

### Environment Detection Issues:
- Use manual environment selection: `bash import-debug-config.sh native`
- Check for `.devcontainer/devcontainer.json` for container detection

### Build Issues After Import:
- **Container**: Run "Container: Fresh Configure & Build" task
- **Native**: Delete `build/` directory and rebuild

### GDB Not Found:
- **Container**: Ensure Dev Container is running
- **Native**: Install GDB and update path in `launch.json`

## 📊 Supported Project Types

### ✅ Tested With:
- Single-file C++ projects
- Multi-file C++ projects with CMake
- Projects with external dependencies
- Header-only libraries
- Calculator applications
- JSON parser applications

### 📋 Project Structure Examples:

#### Simple Project:
```
my-project/
├── src/
│   └── main.cpp
├── CMakeLists.txt
└── README.md
```

#### Complex Project:
```
my-project/
├── src/
│   ├── main.cpp
│   └── utils.cpp
├── include/
│   └── utils.h
├── tests/
├── CMakeLists.txt
└── README.md
```

## 🎯 Best Practices

1. **Always backup** before running (script does this automatically)
2. **Test in container first** for consistent environment
3. **Use Quick Debug** for iterative development
4. **Manual builds** only when code changes
5. **Check README.md** in `.vscode/` for environment-specific tips

## 🔗 Related Documentation

- [VSCode C++ Debugging](https://code.visualstudio.com/docs/cpp/cpp-debug)
- [Dev Containers](https://code.visualstudio.com/docs/devcontainers/containers)
- [CMake Tools](https://github.com/microsoft/vscode-cmake-tools)