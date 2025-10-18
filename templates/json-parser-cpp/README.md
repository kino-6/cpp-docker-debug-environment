# JSON Parser C++ Project Template

A lightweight JSON parser demonstrating external library integration with nlohmann/json.

## Features

- Modern C++ development environment
- CMake build system with external library integration
- nlohmann/json library for JSON parsing
- GDB debugging support
- VSCode Dev Container integration

## Getting Started

### Option 1: Using Dev Container (Recommended)
1. Open this project in VSCode
2. Install the "Dev Containers" extension if not already installed
3. Press `Ctrl+Shift+P` and select "Dev Containers: Reopen in Container"
4. Wait for the container to build and start (first time takes 3-4 minutes due to dependencies)
5. Build the project: `cmake -S . -B build -G Ninja && cmake --build build`
6. Run the application: `./build/bin/JsonParserProject`

### Option 2: Local Development
1. Install required tools: GCC/Clang, CMake, Ninja
2. Build the project using our fast build script:
   ```bash
   ../build-scripts/fast-build.sh --clean
   ```
3. Run the application: `./build/bin/JsonParserProject`

## Project Structure

```
.
├── .devcontainer/          # Dev Container configuration
├── .vscode/               # VSCode settings
├── src/                   # Source files
│   └── main.cpp          # Main application
├── data/                  # Sample JSON files
│   └── sample.json       # Sample JSON data
├── CMakeLists.txt         # CMake configuration
└── README.md             # This file
```

## Usage

The JSON parser can:
- Parse JSON files
- Display JSON content in a formatted way
- Handle JSON parsing errors gracefully

## External Dependencies

- [nlohmann/json](https://github.com/nlohmann/json): Modern C++ JSON library

## Requirements

### Dev Container (Recommended)
- Docker Desktop
- VSCode with Dev Containers extension
- See [DEVCONTAINER_REQUIREMENTS.md](../DEVCONTAINER_REQUIREMENTS.md) for detailed requirements

### Local Development
- GCC/Clang compiler
- CMake 3.16+
- Ninja (recommended)
- Internet connection (for nlohmann/json download)
- See [REQUIREMENTS.md](../REQUIREMENTS.md) for detailed requirements