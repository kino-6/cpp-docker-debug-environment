# Basic C++ Project Template

This is a basic C++ project template for VSCode with Docker development environment.

## Features

- Modern C++ development environment
- CMake build system
- GDB debugging support
- VSCode Dev Container integration

## Getting Started

1. Open this project in VSCode
2. Install the "Dev Containers" extension if not already installed
3. Press `Ctrl+Shift+P` and select "Dev Containers: Reopen in Container"
4. Wait for the container to build and start
5. Build the project using `Ctrl+Shift+P` -> "Tasks: Run Task" -> "Build"
6. Run the application or start debugging

## Project Structure

```
.
├── .devcontainer/          # Dev Container configuration
├── .vscode/               # VSCode settings
├── src/                   # Source files
├── include/               # Header files
├── CMakeLists.txt         # CMake configuration
└── README.md             # This file
```

## Requirements

- Docker Desktop
- VSCode with Dev Containers extension