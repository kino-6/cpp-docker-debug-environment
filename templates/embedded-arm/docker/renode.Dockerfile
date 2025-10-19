# Renode ARM Simulator Dockerfile
FROM ubuntu:22.04

# Install dependencies
RUN apt-get update && apt-get install -y \
    wget \
    gnupg \
    software-properties-common \
    python3 \
    python3-pip \
    mono-complete \
    gtk-sharp2-dev \
    screen \
    && rm -rf /var/lib/apt/lists/*

# Install Renode
RUN wget https://github.com/renode/renode/releases/download/v1.14.0/renode_1.14.0_amd64.deb \
    && dpkg -i renode_1.14.0_amd64.deb || apt-get install -f -y \
    && rm renode_1.14.0_amd64.deb

# Install ARM GCC toolchain
RUN apt-get update && apt-get install -y \
    gcc-arm-none-eabi \
    gdb-multiarch \
    && rm -rf /var/lib/apt/lists/*

# Create workspace
WORKDIR /workspace

# Copy Renode configuration
COPY renode-config/ /opt/renode-config/

# Expose GDB port
EXPOSE 1234

# Default command
CMD ["renode", "--disable-xwt", "--port", "1234"]