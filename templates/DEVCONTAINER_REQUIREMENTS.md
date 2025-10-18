# Dev Container Requirements

This document specifies the system requirements and dependencies for using Dev Containers with our C++ templates.

## Host System Requirements

### Operating System Support

- **Windows 10/11** (with WSL2)
- **macOS 10.15+** (Catalina or later)
- **Linux** (Ubuntu 20.04+, CentOS 8+, or equivalent)

### Required Software

#### 1. Docker Engine

- **Windows**: Docker Desktop 4.0+ with WSL2 backend
- **macOS**: Docker Desktop 4.0+
- **Linux**: Docker Engine 20.10+ or Docker Desktop

#### 2. Visual Studio Code

- **Version**: 1.60.0 or later
- **Required Extensions**:
  - Dev Containers (ms-vscode-remote.remote-containers)
  - C/C++ (ms-vscode.cpptools)
  - CMake Tools (ms-vscode.cmake-tools)

#### 3. WSL2 (Windows Only)

- **WSL Version**: 2.0+
- **Recommended Distribution**: Ubuntu 22.04 LTS
- **Memory**: 4GB+ allocated to WSL2

### Hardware Requirements

#### Minimum Requirements

- **CPU**: 2 cores, 2.0 GHz
- **Memory**: 8GB RAM (4GB for host + 4GB for containers)
- **Storage**: 10GB free space for Docker images and builds
- **Network**: Internet connection for initial image downloads

#### Recommended Requirements

- **CPU**: 4+ cores, 3.0 GHz (e.g., AMD Ryzen 5/7, Intel Core i5/i7)
- **Memory**: 16GB+ RAM (8GB for host + 8GB for containers)
- **Storage**: 20GB+ free space on SSD
- **Network**: Broadband connection for faster downloads

## Container Specifications

### Base Image

- **OS**: Ubuntu 22.04 LTS
- **Architecture**: x86_64 (amd64)
- **Size**: ~1.2GB (compressed), ~3.5GB (uncompressed)

### Development Tools Included

#### Compilers

- **GCC**: 11.4.0 (default)
- **Clang**: 14.0.0
- **G++**: 11.4.0 (C++ compiler)

#### Build Systems

- **CMake**: 3.22.1+
- **Ninja**: 1.10.1+
- **Make**: 4.3+

#### Debuggers

- **GDB**: 12.1+
- **LLDB**: 14.0+

#### Additional Tools

- **Git**: 2.34.1+
- **Curl/Wget**: For dependency downloads
- **Nano/Vim**: Text editors
- **jq**: JSON processor (JSON Parser template only)

### Container Configuration

#### User Setup

- **Username**: vscode
- **UID/GID**: 1000:1000
- **Sudo Access**: Passwordless sudo enabled
- **Shell**: /bin/bash

#### Performance Optimizations

- **Parallel Builds**: Automatic core detection
- **File System**: Optimized for WSL2 bind mounts
- **Memory**: Efficient layer caching
- **Network**: Optimized for dependency downloads

## Template-Specific Requirements

### Basic C++ Template

- **Container Size**: ~3.5GB
- **Build Time**: ~2.4 seconds
- **Memory Usage**: ~512MB during build
- **Dependencies**: None (standard library only)

### Calculator C++ Template

- **Container Size**: ~3.6GB (includes Doxygen)
- **Build Time**: ~2.4 seconds
- **Memory Usage**: ~512MB during build
- **Dependencies**: None (standard library only)
- **Additional Tools**: Doxygen, Graphviz (documentation)

### JSON Parser C++ Template

- **Container Size**: ~3.7GB (includes network tools)
- **Build Time**: ~7.7 seconds (includes dependency download)
- **Memory Usage**: ~1GB during build
- **Dependencies**: nlohmann/json (auto-downloaded)
- **Additional Tools**: jq, enhanced network utilities

## Performance Expectations

### Build Performance (WSL2 + Docker)

| Template | Configure Time | Build Time | Total Time |
|----------|----------------|------------|------------|
| Basic C++ | ~1.5s | ~0.9s | **~2.4s** |
| Calculator C++ | ~1.5s | ~0.9s | **~2.4s** |
| JSON Parser C++ | ~2.0s | ~5.7s | **~7.7s** |

### Comparison with Native Development

| Environment | Basic C++ | Calculator C++ | JSON Parser C++ |
|-------------|-----------|----------------|-----------------|
| **Native Windows** | 3.04s | 3.05s | 10.15s |
| **WSL2 + Docker** | **2.43s** | **2.44s** | **7.69s** |
| **Performance Gain** | **+20%** | **+20%** | **+24%** |

## Network Requirements

### Initial Setup

- **Docker Image Download**: ~1.2GB (Ubuntu 22.04 + tools)
- **Dependency Downloads**: Varies by template
  - Basic C++: None
  - Calculator C++: None  
  - JSON Parser C++: ~500KB (nlohmann/json)

### Ongoing Usage

- **Minimal Network**: After initial setup, minimal network required
- **Dependency Updates**: Occasional updates for security patches
- **Bandwidth**: 1 Mbps sufficient for normal development

## Security Considerations

### Container Security

- **Non-root User**: All development runs as 'vscode' user
- **Capability Restrictions**: Only SYS_PTRACE for debugging
- **Network Isolation**: Container network isolated from host
- **File System**: Read-only base system, writable workspace only

### Host Security

- **Docker Daemon**: Requires Docker daemon access
- **File Permissions**: Workspace files accessible to host user
- **Port Forwarding**: Only explicitly configured ports exposed

## Troubleshooting Requirements

### Common Issues and Solutions

#### Docker Not Running

```bash
# Windows
Start Docker Desktop application

# Linux
sudo systemctl start docker
sudo usermod -aG docker $USER  # Add user to docker group
```

#### WSL2 Memory Issues

```powershell
# Create/edit %USERPROFILE%\.wslconfig
[wsl2]
memory=8GB
processors=4
```

#### Container Build Failures

```bash
# Clean Docker cache
docker system prune -a

# Rebuild container
Ctrl+Shift+P -> "Dev Containers: Rebuild Container"
```

#### Performance Issues

- **Ensure WSL2 backend**: Docker Desktop -> Settings -> General -> Use WSL2
- **Allocate sufficient memory**: WSL2 should have 4GB+ allocated
- **Use SSD storage**: Place workspace on SSD for better I/O performance

## Compatibility Matrix

### Tested Configurations

| Host OS | Docker Version | VSCode Version | Status |
|---------|----------------|----------------|--------|
| Windows 11 | Docker Desktop 4.25+ | 1.85+ | ✅ Fully Tested |
| Windows 10 | Docker Desktop 4.20+ | 1.80+ | ⚠️ Should Work |
| macOS 13+ | Docker Desktop 4.20+ | 1.80+ | ⚠️ Should Work |
| Ubuntu 22.04 | Docker Engine 24.0+ | 1.80+ | ⚠️ Should Work |

### Known Limitations

- **Windows Home**: Requires WSL2, may have performance limitations
- **macOS Intel**: Slower performance due to emulation overhead
- **Linux ARM64**: Not tested, may require architecture-specific images

## Migration from Local Development

### Advantages of Dev Containers

- **Consistency**: Identical environment across all developers
- **Isolation**: No pollution of host system
- **Performance**: 20-24% faster builds on Windows
- **Portability**: Works identically on any supported platform

### Migration Steps

1. **Install Prerequisites**: Docker Desktop + VSCode + Dev Containers extension
2. **Open Project**: Use "Dev Containers: Reopen in Container"
3. **Wait for Build**: Initial container build takes 2-3 minutes
4. **Start Developing**: Full development environment ready

### Rollback Plan

- **Local Development**: All templates work without containers
- **Hybrid Approach**: Use containers for some projects, local for others
- **No Lock-in**: Standard CMake projects work everywhere

---

*This document ensures reliable Dev Container setup across all supported platforms and provides clear expectations for performance and requirements.*
