# JSON Parser C++ Project Template

A lightweight JSON parser demonstrating external library integration with nlohmann/json.

## Features

- Modern C++ development environment
- CMake build system with external library integration
- nlohmann/json library for JSON parsing
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

- Docker Desktop
- VSCode with Dev Containers extension