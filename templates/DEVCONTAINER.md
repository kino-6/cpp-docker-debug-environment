# Dev Container Usage Guide

This guide explains how to use the Dev Container configurations provided with each C++ template.

## What are Dev Containers?

Dev Containers provide a consistent, reproducible development environment using Docker containers. They ensure that all developers work with the same tools, dependencies, and configurations regardless of their host operating system.

## Prerequisites

### Required Software
1. **Docker Desktop** (Windows/macOS) or **Docker Engine** (Linux)
2. **Visual Studio Code**
3. **Dev Containers extension** for VSCode

### Installation

#### Windows/macOS
```powershell
# Install Docker Desktop
winget install Docker.DockerDesktop

# Install VSCode
winget install Microsoft.VisualStudioCode
```

#### Linux (Ubuntu/Debian)
```bash
# Install Docker Engine
sudo apt update
sudo apt install docker.io docker-compose
sudo usermod -aG docker $USER

# Install VSCode
sudo snap install code --classic
```

#### VSCode Extension
1. Open VSCode
2. Go to Extensions (Ctrl+Shift+X)
3. Search for "Dev Containers"
4. Install the extension by Microsoft

## Using Dev Containers

### Method 1: Command Palette
1. Open the project folder in VSCode
2. Press `Ctrl+Shift+P` (or `Cmd+Shift+P` on macOS)
3. Type "Dev Containers: Reopen in Container"
4. Select the command and wait for the container to build

### Method 2: Notification Popup
1. Open a project with `.devcontainer` folder
2. VSCode will show a notification: "Reopen in Container"
3. Click "Reopen in Container"

### Method 3: Status Bar
1. Click on the green icon in the bottom-left corner of VSCode
2. Select "Reopen in Container"

## Container Features by Template

### Basic C++ Template
- **Base Image**: Ubuntu 22.04 LTS
- **Compilers**: GCC, G++, Clang
- **Build Systems**: CMake, Ninja, Make
- **Debugger**: GDB, LLDB
- **Extensions**: C/C++ tools, CMake tools

### Calculator C++ Template
- **Additional Features**: Documentation tools (Doxygen, Graphviz)
- **Optimized for**: Library development with header/source separation
- **Include Paths**: Pre-configured for `include/` and `src/` directories

### JSON Parser C++ Template
- **Additional Tools**: jq (JSON processor), enhanced network tools
- **Optimized for**: Projects with external dependencies
- **Network Access**: Full internet access for dependency downloads

## Container Configuration Details

### User Setup
- **Non-root user**: `vscode` (UID: 1000)
- **Sudo access**: Passwordless sudo for package installation
- **Home directory**: `/home/vscode`

### Workspace Mounting
- **Host Path**: Your project directory
- **Container Path**: `/workspace`
- **Mount Type**: Bind mount with cached consistency
- **Permissions**: Full read/write access

### Performance Optimizations
- **Parallel Builds**: `CMAKE_BUILD_PARALLEL_LEVEL=0` (auto-detect cores)
- **Make Jobs**: `MAKEFLAGS="-j$(nproc)"` (use all available cores)
- **Security**: SYS_PTRACE capability for debugging

### VSCode Integration
- **IntelliSense**: Configured for Linux GCC
- **Build Directory**: `${workspaceFolder}/build`
- **Auto-configure**: CMake configures automatically on container start

## Common Workflows

### Building Projects
```bash
# Inside the container terminal
cmake -S . -B build -G Ninja
cmake --build build --parallel

# Or using our fast build script
../build-scripts/fast-build.sh --clean
```

### Debugging
1. Set breakpoints in VSCode
2. Press F5 or use "Run and Debug" panel
3. The debugger will attach automatically

### Installing Additional Packages
```bash
# Install packages as needed
sudo apt update
sudo apt install <package-name>
```

## Troubleshooting

### Container Build Fails
```bash
# Clean Docker cache
docker system prune -a

# Rebuild container
Ctrl+Shift+P -> "Dev Containers: Rebuild Container"
```

### Permission Issues
```bash
# Fix file permissions
sudo chown -R vscode:vscode /workspace
```

### Network Issues
```bash
# Test internet connectivity
curl -I https://github.com

# Check DNS resolution
nslookup github.com
```

### Performance Issues
```bash
# Check container resources
docker stats

# Monitor system resources
htop
```

## Advanced Configuration

### Custom Environment Variables
Edit `.devcontainer/devcontainer.json`:
```json
{
    "containerEnv": {
        "MY_CUSTOM_VAR": "value",
        "CMAKE_BUILD_TYPE": "Debug"
    }
}
```

### Additional VSCode Extensions
```json
{
    "customizations": {
        "vscode": {
            "extensions": [
                "ms-vscode.cpptools",
                "your-extension-id"
            ]
        }
    }
}
```

### Port Forwarding
```json
{
    "forwardPorts": [8080, 3000],
    "portsAttributes": {
        "8080": {
            "label": "Web Server"
        }
    }
}
```

### Custom Dockerfile
You can modify the Dockerfile in `.devcontainer/Dockerfile` to:
- Install additional tools
- Set up specific configurations
- Add custom scripts

## Best Practices

### 1. Keep Containers Lightweight
- Only install necessary tools
- Use multi-stage builds for complex setups
- Clean up package caches

### 2. Version Control
- Commit `.devcontainer/` directory
- Use specific base image tags (not `latest`)
- Document any custom modifications

### 3. Security
- Use non-root users
- Limit container capabilities
- Keep base images updated

### 4. Performance
- Use bind mounts for source code
- Cache dependencies when possible
- Optimize for your development workflow

## Integration with Build Scripts

Our fast build scripts work seamlessly with Dev Containers:

```bash
# Windows (from host)
templates/build-scripts/fast-build.ps1 -Clean

# Linux (inside container)
../build-scripts/fast-build.sh --clean --jobs 0
```

The containers are optimized to work with our intelligent thread detection and parallel build systems.

## Comparison with Local Development

| Aspect | Local Development | Dev Container |
|--------|------------------|---------------|
| **Setup Time** | Hours (install tools) | Minutes (download image) |
| **Consistency** | Varies by system | Identical everywhere |
| **Isolation** | Affects host system | Completely isolated |
| **Performance** | Native speed | Near-native (95%+) |
| **Portability** | System-dependent | Works anywhere |
| **Debugging** | Native tools | Full debugging support |

## Next Steps

After setting up Dev Containers:
1. **Test the environment** with provided templates
2. **Customize configurations** for your specific needs
3. **Share with team** for consistent development
4. **Integrate with CI/CD** using the same containers

---

*Dev Containers provide the foundation for our next phase: Docker environment setup and cross-compilation support.*