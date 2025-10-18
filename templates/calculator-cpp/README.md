# Calculator C++ Project Template

A simple calculator library demonstrating C++ project structure with header files and function separation.

## Features

- Modern C++ development environment
- CMake build system with library creation
- Header/source file separation
- GDB debugging support
- VSCode Dev Container integration

## Getting Started

### Option 1: Using Dev Container (Recommended)
1. Open this project in VSCode
2. Install the "Dev Containers" extension if not already installed
3. Press `Ctrl+Shift+P` and select "Dev Containers: Reopen in Container"
4. Wait for the container to build and start (first time takes 2-3 minutes)
5. Build the project: `cmake -S . -B build -G Ninja && cmake --build build`
6. Run the application: `./build/bin/CalculatorProject`

### Option 2: Local Development
1. Install required tools: GCC/Clang, CMake, Ninja
2. Build the project using our fast build script:
   ```bash
   ../build-scripts/fast-build.sh --clean
   ```
3. Run the application: `./build/bin/CalculatorProject`

## Project Structure

```
.
├── .devcontainer/          # Dev Container configuration
├── .vscode/               # VSCode settings
├── src/                   # Source files
│   ├── main.cpp          # Main application
│   └── calculator.cpp    # Calculator implementation
├── include/               # Header files
│   └── calculator.h      # Calculator interface
├── CMakeLists.txt         # CMake configuration
└── README.md             # This file
```

## Usage

The calculator supports basic arithmetic operations:
- Addition (+)
- Subtraction (-)
- Multiplication (*)
- Division (/)

## Requirements

### Dev Container (Recommended)
- Docker Desktop
- VSCode with Dev Containers extension
- See [DEVCONTAINER_REQUIREMENTS.md](../DEVCONTAINER_REQUIREMENTS.md) for detailed requirements

### Local Development
- GCC/Clang compiler
- CMake 3.16+
- Ninja (recommended)
- See [REQUIREMENTS.md](../REQUIREMENTS.md) for detailed requirements