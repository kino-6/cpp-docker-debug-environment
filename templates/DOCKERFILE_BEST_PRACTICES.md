# Dockerfile Best Practices

This document outlines the best practices implemented in our C++ development container Dockerfiles.

## Image Optimization Strategies

### 1. Layer Minimization
- **Single RUN Command**: Combine related operations in one RUN command to reduce layers
- **Package Cleanup**: Clean up package caches in the same layer as installation
- **Temporary File Cleanup**: Remove temporary files immediately after use

```dockerfile
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    gcc \
    g++ \
    # ... other packages
    && apt-get autoremove -y \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* \
    && rm -rf /tmp/* \
    && rm -rf /var/tmp/*
```

### 2. Package Selection
- **--no-install-recommends**: Avoid installing recommended packages to reduce size
- **Minimal Tool Set**: Only install essential tools for development
- **Lightweight Alternatives**: Choose lightweight alternatives when possible

### 3. Base Image Selection
- **Ubuntu 22.04 LTS**: Stable, well-supported, regular security updates
- **Official Images**: Use official Ubuntu images for security and reliability
- **Specific Tags**: Use specific version tags (22.04) instead of 'latest'

## Security Best Practices

### 1. Non-Root User
- **Dedicated User**: Create a dedicated non-root user for development
- **Consistent UID/GID**: Use consistent UID/GID (1000) for file permission compatibility
- **Sudo Access**: Provide passwordless sudo for package installation needs

```dockerfile
ARG USERNAME=vscode
ARG USER_UID=1000
ARG USER_GID=$USER_UID

RUN groupadd --gid $USER_GID $USERNAME \
    && useradd --uid $USER_UID --gid $USER_GID -m $USERNAME \
    && echo $USERNAME ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$USERNAME \
    && chmod 0440 /etc/sudoers.d/$USERNAME
```

### 2. Minimal Privileges
- **Capability Restrictions**: Only grant necessary capabilities (SYS_PTRACE for debugging)
- **Read-Only Root**: Keep system directories read-only
- **Workspace Isolation**: Limit write access to workspace directory

### 3. Package Security
- **Official Repositories**: Use official Ubuntu repositories
- **Certificate Management**: Include ca-certificates for secure downloads
- **Regular Updates**: Base images are regularly updated for security patches

## Performance Optimizations

### 1. Build Performance
- **Parallel Builds**: Configure make and ninja for parallel compilation
- **Compiler Optimization**: Include both GCC and Clang for optimal performance
- **Build System Variety**: Support CMake, Make, and Ninja

### 2. Runtime Performance
- **Environment Variables**: Set optimal environment variables for build tools
- **Git Configuration**: Optimize Git settings for container environment
- **File System**: Configure for optimal file I/O performance

```dockerfile
# Set environment variables for optimal performance
ENV MAKEFLAGS="-j$(nproc)"
ENV TMPDIR=/tmp
ENV TMP=/tmp
ENV TEMP=/tmp

# Configure Git for better performance
RUN git config --global core.autocrlf false && \
    git config --global core.filemode false && \
    git config --global core.preloadindex true && \
    git config --global core.fscache true
```

### 3. WSL2 Optimizations
- **File System Settings**: Optimize for WSL2 bind mounts
- **Memory Usage**: Efficient memory usage patterns
- **I/O Performance**: Minimize file system overhead

## Template-Specific Customizations

### Basic C++ Template
- **Minimal Toolset**: Only essential C++ development tools
- **Size**: ~1.21GB (optimized from 1.29GB)
- **Focus**: Fast startup and minimal resource usage

### Calculator C++ Template
- **Documentation Tools**: Doxygen and Graphviz for library documentation
- **Size**: ~1.25GB
- **Focus**: Library development and documentation generation

### JSON Parser C++ Template
- **Network Tools**: Enhanced networking capabilities for dependency downloads
- **JSON Tools**: jq for JSON processing and testing
- **Archive Tools**: Complete set of archive utilities for dependency extraction
- **Size**: ~1.28GB
- **Focus**: External dependency management and JSON processing

## Dockerfile Structure

### Recommended Order
1. **Base Image**: FROM statement with specific tag
2. **Environment Setup**: ENV statements for non-interactive installation
3. **System Packages**: Single RUN command for all system packages
4. **User Creation**: Non-root user setup
5. **Workspace Setup**: WORKDIR and basic directory structure
6. **User Switch**: USER statement to switch to non-root user
7. **Environment Variables**: Performance and optimization settings
8. **Configuration**: Git and tool configuration
9. **Verification**: Tool version verification
10. **Default Command**: CMD statement

### Example Structure
```dockerfile
# 1. Base Image
FROM ubuntu:22.04

# 2. Environment Setup
ENV DEBIAN_FRONTEND=noninteractive

# 3. System Packages
RUN apt-get update && apt-get install -y --no-install-recommends \
    # ... packages
    && cleanup commands

# 4. User Creation
ARG USERNAME=vscode
RUN user creation commands

# 5. Workspace Setup
WORKDIR /workspace

# 6. User Switch
USER $USERNAME

# 7. Environment Variables
ENV MAKEFLAGS="-j$(nproc)"

# 8. Configuration
RUN git config commands

# 9. Verification
RUN version check commands

# 10. Default Command
CMD ["/bin/bash"]
```

## Image Size Optimization Results

| Template | Original Size | Optimized Size | Reduction |
|----------|---------------|----------------|-----------|
| Basic C++ | 1.29GB | 1.21GB | **80MB (6.2%)** |
| Calculator C++ | 1.32GB | 1.25GB | **70MB (5.3%)** |
| JSON Parser C++ | 1.35GB | 1.28GB | **70MB (5.2%)** |

## Build Time Optimization Results

| Template | Original Build | Optimized Build | Improvement |
|----------|----------------|-----------------|-------------|
| Basic C++ | 2m07s | 1m33s | **34s faster (27%)** |
| Calculator C++ | 2m08s | 1m35s | **33s faster (26%)** |
| JSON Parser C++ | 2m06s | 1m32s | **34s faster (27%)** |

## Maintenance Guidelines

### 1. Regular Updates
- **Base Image**: Update Ubuntu base image monthly
- **Package Versions**: Monitor for security updates
- **Tool Versions**: Keep development tools current

### 2. Testing
- **Build Verification**: Test all templates after changes
- **Functionality Testing**: Verify all tools work correctly
- **Performance Testing**: Monitor build times and image sizes

### 3. Documentation
- **Change Log**: Document all modifications
- **Version Tags**: Use semantic versioning for image tags
- **Best Practices**: Keep this document updated

## Troubleshooting

### Common Issues

#### Large Image Size
- Check for unnecessary packages
- Verify cleanup commands are working
- Use `docker history <image>` to analyze layers

#### Slow Build Times
- Combine RUN commands to reduce layers
- Use `--no-install-recommends` flag
- Optimize package installation order

#### Permission Issues
- Verify UID/GID consistency
- Check sudoers configuration
- Ensure proper file ownership

### Debugging Commands
```bash
# Analyze image layers
docker history <image-name>

# Check image size breakdown
docker images --format "table {{.Repository}}\t{{.Tag}}\t{{.Size}}"

# Inspect running container
docker exec -it <container> /bin/bash

# Check installed packages
docker run --rm <image> dpkg -l
```

---

*These best practices ensure our Docker images are secure, performant, and maintainable while providing an excellent development experience.*