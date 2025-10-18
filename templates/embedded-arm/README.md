# ARM Embedded Development Template

## 🎯 Overview

This template provides a complete ARM Cortex-M4 embedded development environment with:

- **Target**: STM32F407VG (ARM Cortex-M4 with FPU)
- **Demo**: LED blink application for STM32F4-Discovery board
- **Toolchain**: ARM GCC cross-compiler
- **Debug**: GDB + OpenOCD + QEMU support
- **IDE**: VSCode with Dev Container

## 🚀 Quick Start

### Option 1: Dev Container (Recommended)

1. **Open in Dev Container**
   ```bash
   # In VSCode
   Ctrl+Shift+P → "Dev Containers: Reopen in Container"
   ```

2. **Build Project**
   ```bash
   # Run task or use terminal
   Ctrl+Shift+P → "Tasks: Run Task" → "ARM: Fresh Configure & Build"
   
   # Or in terminal
   ./scripts/build-test.sh
   ```

3. **Check Output**
   ```bash
   ls -la build/bin/
   # Should see: EmbeddedArmProject.elf, .hex, .bin files
   ```

### Option 2: Native Development

**Prerequisites:**
- ARM GCC Toolchain (`gcc-arm-none-eabi`)
- CMake (≥3.16)
- Ninja build system

**Ubuntu/Debian:**
```bash
sudo apt-get install gcc-arm-none-eabi cmake ninja-build
```

**Build:**
```bash
./scripts/build-test.sh
```

## 📁 Project Structure

```
embedded-arm/
├── .devcontainer/          # Dev Container configuration
├── src/
│   ├── main.c              # Main application (LED blink)
│   ├── hal/                # Hardware Abstraction Layer
│   │   ├── system_init.c   # System clock configuration
│   │   └── gpio.c          # GPIO control functions
│   ├── drivers/            # Device drivers
│   │   └── led.c           # LED driver
│   └── startup/            # Startup code
│       └── startup_stm32f4xx.s
├── include/                # Header files
├── linker/                 # Linker scripts
│   └── STM32F407VGTx_FLASH.ld
├── scripts/                # Build and utility scripts
└── CMakeLists.txt          # Build configuration
```

## 🎮 LED Blink Demo

The demo application controls 4 LEDs on the STM32F4-Discovery board:

- **Green LED (PD12)**: Main blink (500ms interval)
- **Orange LED (PD13)**: Not used in basic demo
- **Red LED (PD14)**: Blinks every 4th cycle
- **Blue LED (PD15)**: Blinks every 8th cycle

### Debugging Points

Set breakpoints at these locations for debugging:

1. **main.c:45** - `debug_counter++` - Main loop iteration
2. **led.c:65** - `gpio_toggle_pin()` - LED toggle operation
3. **system_init.c:85** - Clock configuration
4. **gpio.c:95** - GPIO pin configuration

## 🔧 Build System

### CMake Configuration

- **Target**: ARM Cortex-M4 with hardware FPU
- **Compiler**: `arm-none-eabi-gcc`
- **Build System**: Ninja (faster than Make)
- **Output**: ELF, HEX, and BIN files

### Memory Layout

- **Flash**: 1MB (0x08000000 - 0x080FFFFF)
- **RAM**: 128KB (0x20000000 - 0x2001FFFF)
- **CCM RAM**: 64KB (0x10000000 - 0x1000FFFF)

### Build Outputs

- `EmbeddedArmProject.elf` - Debug symbols included
- `EmbeddedArmProject.hex` - Intel HEX format for programming
- `EmbeddedArmProject.bin` - Raw binary format

## 🐛 Debugging

### QEMU Simulation (Coming Soon)

```bash
# Start QEMU with GDB server
qemu-system-arm -M stm32f4-discovery -nographic -s -S

# Connect GDB
arm-none-eabi-gdb build/bin/EmbeddedArmProject.elf
(gdb) target remote localhost:1234
(gdb) load
(gdb) continue
```

### Hardware Debugging (Coming Soon)

```bash
# Start OpenOCD
openocd -f interface/stlink.cfg -f target/stm32f4x.cfg

# Connect GDB
arm-none-eabi-gdb build/bin/EmbeddedArmProject.elf
(gdb) target remote localhost:3333
(gdb) monitor reset halt
(gdb) load
(gdb) continue
```

## 📊 Memory Usage

Typical memory usage for the LED blink demo:

```
   text    data     bss     dec     hex filename
   2048      16    1024    3088     c10 EmbeddedArmProject.elf
```

- **text**: Program code in Flash (~2KB)
- **data**: Initialized variables in RAM (~16B)
- **bss**: Uninitialized variables in RAM (~1KB)

## 🛠️ Development Tips

### VSCode Tasks

- `ARM: Fresh Configure & Build` - Clean build from scratch
- `ARM: CMake Build` - Incremental build
- `ARM: Show Binary Info` - Display memory usage

### Debugging Features

- Hardware breakpoints supported
- Variable inspection
- Memory view
- Register view
- Call stack analysis

## 🔍 Troubleshooting

### Build Issues

**ARM toolchain not found:**
```bash
# Check installation
arm-none-eabi-gcc --version

# Install on Ubuntu/Debian
sudo apt-get install gcc-arm-none-eabi
```

**CMake configuration fails:**
```bash
# Clean and reconfigure
rm -rf build
cmake -B build -S . -G Ninja -DCMAKE_BUILD_TYPE=Debug
```

### Runtime Issues

**LEDs not blinking:**
- Check target hardware (STM32F4-Discovery)
- Verify GPIO pin configuration
- Check system clock configuration

## 📚 Next Steps

1. **Add UART communication**
2. **Implement timer-based delays**
3. **Add interrupt handling**
4. **Integrate FreeRTOS**
5. **Add sensor drivers**

## 🎯 Hardware Target

This template is designed for the **STM32F4-Discovery** board:

- **MCU**: STM32F407VGT6
- **Core**: ARM Cortex-M4 with FPU
- **Flash**: 1MB
- **RAM**: 192KB (128KB + 64KB CCM)
- **Clock**: Up to 168MHz
- **LEDs**: 4x user LEDs (PD12-PD15)

The code can be adapted for other STM32F4 series microcontrollers with minimal changes.