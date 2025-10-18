# Use Ubuntu 22.04 LTS as base image for stability and long-term support
FROM ubuntu:22.04

# Avoid prompts from apt
ENV DEBIAN_FRONTEND=noninteractive

# Install system dependencies and development tools in a single layer
RUN apt-get update && apt-get install -y --no-install-recommends \
    # Essential build tools
    build-essential \
    gcc \
    g++ \
    clang \
    # Build systems
    cmake \
    ninja-build \
    make \
    # Debugging tools
    gdb \
    lldb \
    # Version control
    git \
    # Network tools (for downloading dependencies)
    curl \
    wget \
    ca-certificates \
    # Archive tools (for dependency extraction)
    unzip \
    tar \
    xz-utils \
    # Text editors (lightweight)
    nano \
    # Process tools
    htop \
    # Network tools (minimal)
    net-tools \
    # JSON tools (for testing)
    jq \
    # Sudo for non-root user
    sudo \
    # Clean up in same layer to reduce image size
    && apt-get autoremove -y \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* \
    && rm -rf /tmp/* \
    && rm -rf /var/tmp/*

# Create a non-root user (sudo already installed above)
ARG USERNAME=vscode
ARG USER_UID=1000
ARG USER_GID=$USER_UID

RUN groupadd --gid $USER_GID $USERNAME \
    && useradd --uid $USER_UID --gid $USER_GID -m $USERNAME \
    && echo $USERNAME ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$USERNAME \
    && chmod 0440 /etc/sudoers.d/$USERNAME

# Set up workspace directory
WORKDIR /workspace

# Switch to non-root user
USER $USERNAME

# Set environment variables for optimal performance
# Note: CMAKE_BUILD_PARALLEL_LEVEL=0 means auto-detect, but some versions don't support it
# ENV CMAKE_BUILD_PARALLEL_LEVEL=0
ENV MAKEFLAGS="-j$(nproc)"

# WSL2 optimizations
ENV TMPDIR=/tmp
ENV TMP=/tmp
ENV TEMP=/tmp

# Configure Git for better performance on WSL2
RUN git config --global core.autocrlf false && \
    git config --global core.filemode false && \
    git config --global core.preloadindex true && \
    git config --global core.fscache true

# Verify installations
RUN gcc --version && \
    g++ --version && \
    clang --version && \
    cmake --version && \
    ninja --version && \
    gdb --version && \
    jq --version

# Default command
CMD ["/bin/bash"]