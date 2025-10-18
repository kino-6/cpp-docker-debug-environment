# Use Ubuntu 22.04 LTS as base image for stability and long-term support
FROM ubuntu:22.04

# Avoid prompts from apt
ENV DEBIAN_FRONTEND=noninteractive

# Install system dependencies and development tools
RUN apt-get update && apt-get install -y \
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
    # Utilities
    curl \
    wget \
    unzip \
    zip \
    # Text editors (for emergency editing)
    nano \
    vim \
    # Process tools
    htop \
    # Network tools
    net-tools \
    # Documentation tools (for library development)
    doxygen \
    graphviz \
    # Clean up
    && apt-get autoremove -y \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Create a non-root user
ARG USERNAME=vscode
ARG USER_UID=1000
ARG USER_GID=$USER_UID

RUN groupadd --gid $USER_GID $USERNAME \
    && useradd --uid $USER_UID --gid $USER_GID -m $USERNAME \
    && apt-get update \
    && apt-get install -y sudo \
    && echo $USERNAME ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$USERNAME \
    && chmod 0440 /etc/sudoers.d/$USERNAME \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

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
    gdb --version

# Default command
CMD ["/bin/bash"]