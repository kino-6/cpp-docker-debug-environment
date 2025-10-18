# VSCode C++ Debug Configuration

## �  Dev Container First Approach

This template is optimized for **Dev Container development** to ensure consistent, cross-platform C++ debugging experience.

### 🎯 Why Dev Container?

- **✅ Consistent Environment** - Same tools across Windows/macOS/Linux
- **✅ No Local Setup** - No need to install GDB, CMake, compilers locally
- **✅ Isolated Dependencies** - Project-specific toolchain versions
- **✅ Team Consistency** - Everyone uses identical development environment
- **✅ Easy Onboarding** - New developers get started in minutes

## 🚀 Quick Start

### 1. Open in Dev Container

```bash
# In VSCode
Ctrl+Shift+P → "Dev Containers: Reopen in Container"
```

### 2. Initial Build

```bash
# Run task (Ctrl+Shift+P → "Tasks: Run Task")
Fresh Configure & Build
```

### 3. Start Debugging

```bash
# Set breakpoints, then press F5
🚀 Quick Debug (No Build)  # Fastest option
```

## 🎮 Debug Configurations

### **🚀 Quick Debug (No Build)** ⭐ Recommended

- **Fastest debugging experience**
- No automatic build - use when code hasn't changed
- Perfect for iterative debugging sessions

### **Debug Basic C++ Project**

- Manual build control
- Full debug symbols and pretty-printing
- Use when you want to control build timing

### **Debug Basic C++ Project (Auto Build)**

- Automatic fresh build before debugging
- Use when switching between major code changes
- Slower but ensures latest code

### **Attach to Process**

- Attach debugger to running process
- Advanced debugging scenarios

## 🔧 Build Tasks

### **CMake Build** (Ctrl+Shift+B)

- Standard incremental build
- Use for regular development

### **Fresh Configure & Build**

- Clean build from scratch
- Use when switching environments or after major changes

### **Clean Build Directory**

- Remove all build artifacts
- Use when build cache is corrupted

## 📋 Typical Workflow

### 🔄 Development Loop

1. **Edit Code** - Make your changes
2. **Quick Build** - `Ctrl+Shift+B` (only if needed)
3. **Set Breakpoints** - Click line numbers or `F9`
4. **Quick Debug** - `F5` → `🚀 Quick Debug (No Build)`
5. **Debug & Fix** - Step through, inspect variables
6. **Repeat** - Back to step 1

### 🆕 First Time / Major Changes

1. **Fresh Build** - Run `Fresh Configure & Build` task
2. **Full Debug** - `F5` → `Debug Basic C++ Project (Auto Build)`

## 🛠️ Native Development (Optional)

If you prefer native development, copy the native configurations:

```bash
# Copy native settings (Windows)
cp .vscode/native/* .vscode/

# Copy native settings (Linux/macOS)
cp .vscode/native/* .vscode/
```

### Native Requirements

- **Windows**: MinGW-w64 GDB, CMake, Ninja
- **Linux**: build-essential, gdb, cmake, ninja-build
- **macOS**: Xcode Command Line Tools, CMake, Ninja

## 🔍 Troubleshooting

### Container Issues

**Container won't start:**

```bash
# Check Docker is running
docker --version

# Rebuild container
Ctrl+Shift+P → "Dev Containers: Rebuild Container"
```

**Build fails:**

```bash
# Clean and rebuild
Run task: "Fresh Configure & Build"
```

**GDB not found:**

```bash
# Container should have GDB pre-installed
# If not, rebuild container
```

### Debug Issues

**Breakpoints not hit:**

- Ensure you built with Debug configuration
- Check that executable exists: `/workspace/build/bin/BasicCppProject`
- Try `Fresh Configure & Build` task

**Variables not showing:**

- Debug build should include symbols
- Check CMake configuration includes `-g` flag

**Path errors:**

- Ensure you're in Dev Container (check bottom-left VSCode indicator)
- Paths should use `/workspace/` prefix in container

## 📊 Performance Tips

### ⚡ Fast Debugging

1. **Use Quick Debug** - Skip unnecessary rebuilds
2. **Incremental Builds** - Only build when code changes
3. **Targeted Breakpoints** - Don't set too many breakpoints
4. **Container Persistence** - Keep container running between sessions

### 🔧 Build Optimization

- **Ninja Generator** - Faster than Make (already configured)
- **Parallel Builds** - Uses all CPU cores (already configured)
- **Debug Symbols** - Optimized for debugging (already configured)

## 🎯 Best Practices

### 🐳 Container Development

1. **Always use Dev Container** for team projects
2. **Commit .devcontainer/** to version control
3. **Document container requirements** in project README
4. **Use volume mounts** for persistent data

### 🚀 Debugging Workflow

1. **Set strategic breakpoints** - Not every line
2. **Use Quick Debug** for iteration
3. **Fresh build** when in doubt
4. **Inspect variables** in Variables panel
5. **Use Debug Console** for expressions

### 📁 Project Structure

```
your-project/
├── .devcontainer/          # Container configuration
├── .vscode/               # Debug configuration
├── src/                   # Source files
├── include/              # Header files (optional)
├── build/                # Build output (auto-generated)
├── CMakeLists.txt        # Build configuration
└── README.md            # Project documentation
```

## 🔗 Related Resources

- [Dev Containers Documentation](https://code.visualstudio.com/docs/devcontainers/containers)
- [VSCode C++ Debugging](https://code.visualstudio.com/docs/cpp/cpp-debug)
- [CMake Documentation](https://cmake.org/documentation/)
- [GDB Quick Reference](https://sourceware.org/gdb/current/onlinedocs/gdb/)

---

**🎉 Happy Debugging!** This configuration is optimized for the best C++ development experience in VSCode with Dev Containers.
