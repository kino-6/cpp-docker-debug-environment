#!/bin/bash

cd tests/integration
cmake -B build -S . -G Ninja -DCMAKE_BUILD_TYPE=Debug
cmake --build build --parallel
timeout 10s qemu-system-arm -M netduinoplus2 -cpu cortex-m4 -kernel build/bin/SimpleQemuTest.elf -nographic -semihosting-config enable=on,target=native
