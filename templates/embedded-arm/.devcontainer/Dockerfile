# ARM Embedded Development Container
FROM ubuntu:22.04

# Avoid prompts from apt
ENV DEBIAN_FRONTEND=noninteractive

# Install system dependencies and ARM development tools
RUN apt-get update && apt-get install -y --no-install-recommends \
    # Essential build tools
    build-essential \
    cmake \
    ninja-build \
    make \
    # ARM GCC Toolchain
    gcc-arm-none-eabi \
    binutils-arm-none-eabi \
    libnewlib-arm-none-eabi \
    # Debugging and simulation tools
    gdb-multiarch \
    openocd \
    qemu-system-arm \
    # Version control and utilities
    git \
    curl \
    wget \
    unzip \
    # Text editors
    nano \
    # Process and network tools
    htop \
    net-tools \
    # Certificate management
    ca-certificates \
    # Python for build scripts
    python3 \
    python3-pip \
    # Sudo for non-root user
    sudo \
    # Clean up in same layer
    && apt-get autoremove -y \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* \
    && rm -rf /tmp/* \
    && rm -rf /var/tmp/*

# Install additional Python tools for embedded development
RUN pip3 install --no-cache-dir \
    pyocd \
    intelhex

# Install GoogleTest for unit testing
RUN apt-get update && apt-get install -y --no-install-recommends \
    libgtest-dev \
    libgmock-dev \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Create a non-root user
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

# Set environment variables for ARM development
ENV ARM_TOOLCHAIN_PATH=/usr/bin
ENV QEMU_SYSTEM_ARM=/usr/bin/qemu-system-arm
ENV OPENOCD_PATH=/usr/bin/openocd

# Configure Git for better performance
RUN git config --global core.autocrlf false && \
    git config --global core.filemode false && \
    git config --global core.preloadindex true && \
    git config --global core.fscache true

# Configure bash as default shell and setup completion
RUN echo 'if [ -f /etc/bash_completion ]; then source /etc/bash_completion; fi' >> /home/vscode/.bashrc && \
    echo 'export PS1="\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ "' >> /home/vscode/.bashrc && \
    echo 'export HISTSIZE=1000' >> /home/vscode/.bashrc && \
    echo 'export HISTFILESIZE=2000' >> /home/vscode/.bashrc && \
    echo 'shopt -s histappend' >> /home/vscode/.bashrc && \
    echo 'shopt -s checkwinsize' >> /home/vscode/.bashrc

# Verify ARM toolchain installation
RUN arm-none-eabi-gcc --version

# Default command
CMD ["/bin/bash"]