# QEMU Integration Tests for ARM Embedded Project
cmake_minimum_required(VERSION 3.16)

# ARM cross-compilation configuration
set(CMAKE_SYSTEM_NAME Generic)
set(CMAKE_SYSTEM_PROCESSOR ARM)

# Use ARM toolchain for integration tests
set(CMAKE_C_COMPILER arm-none-eabi-gcc)
set(CMAKE_CXX_COMPILER arm-none-eabi-g++)
set(CMAKE_ASM_COMPILER arm-none-eabi-gcc)

# Prevent CMake from testing the compiler
set(CMAKE_C_COMPILER_FORCED TRUE)
set(CMAKE_CXX_COMPILER_FORCED TRUE)
set(CMAKE_ASM_COMPILER_FORCED TRUE)

# Project declaration
project(EmbeddedArmIntegrationTests VERSION 1.0.0 LANGUAGES C CXX ASM)

# ARM Cortex-M4 specific flags
set(CPU_FLAGS "-mcpu=cortex-m4 -mthumb -mfpu=fpv4-sp-d16 -mfloat-abi=hard")

# Compiler flags for integration tests
set(CMAKE_C_FLAGS "${CPU_FLAGS} -Wall -Wextra -Og -g3 -DINTEGRATION_TEST")
set(CMAKE_CXX_FLAGS "${CPU_FLAGS} -Wall -Wextra -Og -g3 -DINTEGRATION_TEST -fno-exceptions -fno-rtti")
set(CMAKE_ASM_FLAGS "${CPU_FLAGS} -x assembler-with-cpp")

# Linker flags with semihosting support
set(CMAKE_EXE_LINKER_FLAGS "${CPU_FLAGS} -specs=rdimon.specs -Wl,--gc-sections")

# Include directories
include_directories(
    ${CMAKE_SOURCE_DIR}/../../include
    ${CMAKE_SOURCE_DIR}/../../src/hal
    ${CMAKE_SOURCE_DIR}/../../src/drivers
    ${CMAKE_SOURCE_DIR}/../mocks
)

# Source files for integration tests
set(INTEGRATION_SOURCES
    ../../src/hal/system_init.c
    ../../src/hal/gpio.c
    ../../src/drivers/led.c
    ../../src/startup/startup_stm32f4xx.s
    integration_test_main.c
    test_hardware_integration.c
    test_qemu_semihosting.c
)

# Create integration test executable
add_executable(IntegrationTestRunner.elf ${INTEGRATION_SOURCES})

# Linker script
set(LINKER_SCRIPT ${CMAKE_SOURCE_DIR}/../../linker/STM32F407VGTx_FLASH.ld)
set_target_properties(IntegrationTestRunner.elf PROPERTIES LINK_DEPENDS ${LINKER_SCRIPT})
target_link_options(IntegrationTestRunner.elf PRIVATE -T${LINKER_SCRIPT})

# Set output directory
set_target_properties(IntegrationTestRunner.elf PROPERTIES
    RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/bin
)

# Generate additional output formats
add_custom_command(TARGET IntegrationTestRunner.elf POST_BUILD
    COMMAND arm-none-eabi-objcopy -O ihex $<TARGET_FILE:IntegrationTestRunner.elf> ${CMAKE_BINARY_DIR}/bin/IntegrationTestRunner.hex
    COMMAND arm-none-eabi-objcopy -O binary $<TARGET_FILE:IntegrationTestRunner.elf> ${CMAKE_BINARY_DIR}/bin/IntegrationTestRunner.bin
    COMMAND arm-none-eabi-size $<TARGET_FILE:IntegrationTestRunner.elf>
    COMMENT "Generating HEX and BIN files for QEMU integration tests"
)

# Create simple QEMU test executable (minimal dependencies)
add_executable(SimpleQemuTest.elf 
    simple_qemu_test.c
    ../../src/startup/startup_stm32f4xx.s
)

# Linker script for simple test
set_target_properties(SimpleQemuTest.elf PROPERTIES LINK_DEPENDS ${LINKER_SCRIPT})
target_link_options(SimpleQemuTest.elf PRIVATE -T${LINKER_SCRIPT})

# Set output directory for simple test
set_target_properties(SimpleQemuTest.elf PROPERTIES
    RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/bin
)

# Generate additional output formats for simple test
add_custom_command(TARGET SimpleQemuTest.elf POST_BUILD
    COMMAND arm-none-eabi-objcopy -O ihex $<TARGET_FILE:SimpleQemuTest.elf> ${CMAKE_BINARY_DIR}/bin/SimpleQemuTest.hex
    COMMAND arm-none-eabi-objcopy -O binary $<TARGET_FILE:SimpleQemuTest.elf> ${CMAKE_BINARY_DIR}/bin/SimpleQemuTest.bin
    COMMAND arm-none-eabi-size $<TARGET_FILE:SimpleQemuTest.elf>
    COMMENT "Generating HEX and BIN files for simple QEMU test"
)

# Create minimal QEMU test executable (no complex startup)
add_executable(MinimalQemuTest.elf minimal_qemu_test.c)

# Use minimal linker script
set(MINIMAL_LINKER_SCRIPT ${CMAKE_SOURCE_DIR}/minimal.ld)
set_target_properties(MinimalQemuTest.elf PROPERTIES LINK_DEPENDS ${MINIMAL_LINKER_SCRIPT})
target_link_options(MinimalQemuTest.elf PRIVATE -T${MINIMAL_LINKER_SCRIPT})

# Set output directory for minimal test
set_target_properties(MinimalQemuTest.elf PROPERTIES
    RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/bin
)

# Generate additional output formats for minimal test
add_custom_command(TARGET MinimalQemuTest.elf POST_BUILD
    COMMAND arm-none-eabi-objcopy -O ihex $<TARGET_FILE:MinimalQemuTest.elf> ${CMAKE_BINARY_DIR}/bin/MinimalQemuTest.hex
    COMMAND arm-none-eabi-objcopy -O binary $<TARGET_FILE:MinimalQemuTest.elf> ${CMAKE_BINARY_DIR}/bin/MinimalQemuTest.bin
    COMMAND arm-none-eabi-size $<TARGET_FILE:MinimalQemuTest.elf>
    COMMENT "Generating minimal QEMU test files"
)

# Create improved QEMU test executable with better semihosting
add_executable(ImprovedQemuTest.elf improved_qemu_test.c)

# Use minimal linker script for improved test
set_target_properties(ImprovedQemuTest.elf PROPERTIES LINK_DEPENDS ${MINIMAL_LINKER_SCRIPT})
target_link_options(ImprovedQemuTest.elf PRIVATE -T${MINIMAL_LINKER_SCRIPT})

# Set output directory for improved test
set_target_properties(ImprovedQemuTest.elf PROPERTIES
    RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/bin
)

# Generate additional output formats for improved test
add_custom_command(TARGET ImprovedQemuTest.elf POST_BUILD
    COMMAND arm-none-eabi-objcopy -O ihex $<TARGET_FILE:ImprovedQemuTest.elf> ${CMAKE_BINARY_DIR}/bin/ImprovedQemuTest.hex
    COMMAND arm-none-eabi-objcopy -O binary $<TARGET_FILE:ImprovedQemuTest.elf> ${CMAKE_BINARY_DIR}/bin/ImprovedQemuTest.bin
    COMMAND arm-none-eabi-size $<TARGET_FILE:ImprovedQemuTest.elf>
    COMMENT "Generating improved QEMU test files"
)

# Create working QEMU test executable with direct semihosting
add_executable(WorkingQemuTest.elf working_qemu_test.c)

# Use minimal linker script for working test
set_target_properties(WorkingQemuTest.elf PROPERTIES LINK_DEPENDS ${MINIMAL_LINKER_SCRIPT})
target_link_options(WorkingQemuTest.elf PRIVATE -T${MINIMAL_LINKER_SCRIPT})

# Set output directory for working test
set_target_properties(WorkingQemuTest.elf PROPERTIES
    RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/bin
)

# Generate additional output formats for working test
add_custom_command(TARGET WorkingQemuTest.elf POST_BUILD
    COMMAND arm-none-eabi-objcopy -O ihex $<TARGET_FILE:WorkingQemuTest.elf> ${CMAKE_BINARY_DIR}/bin/WorkingQemuTest.hex
    COMMAND arm-none-eabi-objcopy -O binary $<TARGET_FILE:WorkingQemuTest.elf> ${CMAKE_BINARY_DIR}/bin/WorkingQemuTest.bin
    COMMAND arm-none-eabi-size $<TARGET_FILE:WorkingQemuTest.elf>
    COMMENT "Generating working QEMU test files"
)

# Create debug QEMU test executable with step-by-step tracking
add_executable(DebugQemuTest.elf debug_qemu_test.c)

# Use minimal linker script for debug test
set_target_properties(DebugQemuTest.elf PROPERTIES LINK_DEPENDS ${MINIMAL_LINKER_SCRIPT})
target_link_options(DebugQemuTest.elf PRIVATE -T${MINIMAL_LINKER_SCRIPT})

# Set output directory for debug test
set_target_properties(DebugQemuTest.elf PROPERTIES
    RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/bin
)

# Generate additional output formats for debug test
add_custom_command(TARGET DebugQemuTest.elf POST_BUILD
    COMMAND arm-none-eabi-objcopy -O ihex $<TARGET_FILE:DebugQemuTest.elf> ${CMAKE_BINARY_DIR}/bin/DebugQemuTest.hex
    COMMAND arm-none-eabi-objcopy -O binary $<TARGET_FILE:DebugQemuTest.elf> ${CMAKE_BINARY_DIR}/bin/DebugQemuTest.bin
    COMMAND arm-none-eabi-size $<TARGET_FILE:DebugQemuTest.elf>
    COMMENT "Generating debug QEMU test files"
)

# Create bare metal QEMU test executable (no library dependencies)
add_executable(BareMetalTest.elf bare_metal_test.c)

# Use minimal linker script for bare metal test
set_target_properties(BareMetalTest.elf PROPERTIES LINK_DEPENDS ${MINIMAL_LINKER_SCRIPT})
target_link_options(BareMetalTest.elf PRIVATE -T${MINIMAL_LINKER_SCRIPT} -nostdlib)

# Set output directory for bare metal test
set_target_properties(BareMetalTest.elf PROPERTIES
    RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/bin
)

# Generate additional output formats for bare metal test
add_custom_command(TARGET BareMetalTest.elf POST_BUILD
    COMMAND arm-none-eabi-objcopy -O ihex $<TARGET_FILE:BareMetalTest.elf> ${CMAKE_BINARY_DIR}/bin/BareMetalTest.hex
    COMMAND arm-none-eabi-objcopy -O binary $<TARGET_FILE:BareMetalTest.elf> ${CMAKE_BINARY_DIR}/bin/BareMetalTest.bin
    COMMAND arm-none-eabi-size $<TARGET_FILE:BareMetalTest.elf>
    COMMENT "Generating bare metal QEMU test files"
)

# Create fixed QEMU test executable with comprehensive semihosting
add_executable(FixedQemuTest.elf fixed_qemu_test.c)

# Use minimal linker script for fixed test
set_target_properties(FixedQemuTest.elf PROPERTIES LINK_DEPENDS ${MINIMAL_LINKER_SCRIPT})
target_link_options(FixedQemuTest.elf PRIVATE -T${MINIMAL_LINKER_SCRIPT} -nostdlib)

# Set output directory for fixed test
set_target_properties(FixedQemuTest.elf PROPERTIES
    RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/bin
)

# Generate additional output formats for fixed test
add_custom_command(TARGET FixedQemuTest.elf POST_BUILD
    COMMAND arm-none-eabi-objcopy -O ihex $<TARGET_FILE:FixedQemuTest.elf> ${CMAKE_BINARY_DIR}/bin/FixedQemuTest.hex
    COMMAND arm-none-eabi-objcopy -O binary $<TARGET_FILE:FixedQemuTest.elf> ${CMAKE_BINARY_DIR}/bin/FixedQemuTest.bin
    COMMAND arm-none-eabi-size $<TARGET_FILE:FixedQemuTest.elf>
    COMMENT "Generating fixed QEMU test files"
)

# Create minimal semihosting test executable
add_executable(MinimalSemihostTest.elf minimal_semihost_test.c)

# Use minimal linker script for minimal semihost test
set_target_properties(MinimalSemihostTest.elf PROPERTIES LINK_DEPENDS ${MINIMAL_LINKER_SCRIPT})
target_link_options(MinimalSemihostTest.elf PRIVATE -T${MINIMAL_LINKER_SCRIPT} -nostdlib)

# Set output directory for minimal semihost test
set_target_properties(MinimalSemihostTest.elf PROPERTIES
    RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/bin
)

# Generate additional output formats for minimal semihost test
add_custom_command(TARGET MinimalSemihostTest.elf POST_BUILD
    COMMAND arm-none-eabi-objcopy -O ihex $<TARGET_FILE:MinimalSemihostTest.elf> ${CMAKE_BINARY_DIR}/bin/MinimalSemihostTest.hex
    COMMAND arm-none-eabi-objcopy -O binary $<TARGET_FILE:MinimalSemihostTest.elf> ${CMAKE_BINARY_DIR}/bin/MinimalSemihostTest.bin
    COMMAND arm-none-eabi-size $<TARGET_FILE:MinimalSemihostTest.elf>
    COMMENT "Generating minimal semihosting test files"
)

# Create no semihosting test executable (basic ARM execution test)
add_executable(NoSemihostTest.elf no_semihost_test.c)

# Use minimal linker script for no semihost test
set_target_properties(NoSemihostTest.elf PROPERTIES LINK_DEPENDS ${MINIMAL_LINKER_SCRIPT})
target_link_options(NoSemihostTest.elf PRIVATE -T${MINIMAL_LINKER_SCRIPT} -nostdlib)

# Set output directory for no semihost test
set_target_properties(NoSemihostTest.elf PROPERTIES
    RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/bin
)

# Generate additional output formats for no semihost test
add_custom_command(TARGET NoSemihostTest.elf POST_BUILD
    COMMAND arm-none-eabi-objcopy -O ihex $<TARGET_FILE:NoSemihostTest.elf> ${CMAKE_BINARY_DIR}/bin/NoSemihostTest.hex
    COMMAND arm-none-eabi-objcopy -O binary $<TARGET_FILE:NoSemihostTest.elf> ${CMAKE_BINARY_DIR}/bin/NoSemihostTest.bin
    COMMAND arm-none-eabi-size $<TARGET_FILE:NoSemihostTest.elf>
    COMMENT "Generating no semihosting test files"
)

# Create Cortex-M specific semihosting test executable
add_executable(CortexMSemihostTest.elf cortex_m_semihost_test.c)

# Use minimal linker script for Cortex-M semihost test
set_target_properties(CortexMSemihostTest.elf PROPERTIES LINK_DEPENDS ${MINIMAL_LINKER_SCRIPT})
target_link_options(CortexMSemihostTest.elf PRIVATE -T${MINIMAL_LINKER_SCRIPT} -nostdlib)

# Set output directory for Cortex-M semihost test
set_target_properties(CortexMSemihostTest.elf PROPERTIES
    RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/bin
)

# Generate additional output formats for Cortex-M semihost test
add_custom_command(TARGET CortexMSemihostTest.elf POST_BUILD
    COMMAND arm-none-eabi-objcopy -O ihex $<TARGET_FILE:CortexMSemihostTest.elf> ${CMAKE_BINARY_DIR}/bin/CortexMSemihostTest.hex
    COMMAND arm-none-eabi-objcopy -O binary $<TARGET_FILE:CortexMSemihostTest.elf> ${CMAKE_BINARY_DIR}/bin/CortexMSemihostTest.bin
    COMMAND arm-none-eabi-size $<TARGET_FILE:CortexMSemihostTest.elf>
    COMMENT "Generating Cortex-M semihosting test files"
)

# Create simple working test executable (most basic test)
add_executable(SimpleWorkingTest.elf simple_working_test.c)

# Use minimal linker script for simple working test
set_target_properties(SimpleWorkingTest.elf PROPERTIES LINK_DEPENDS ${MINIMAL_LINKER_SCRIPT})
target_link_options(SimpleWorkingTest.elf PRIVATE -T${MINIMAL_LINKER_SCRIPT} -nostdlib)

# Set output directory for simple working test
set_target_properties(SimpleWorkingTest.elf PROPERTIES
    RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/bin
)

# Generate additional output formats for simple working test
add_custom_command(TARGET SimpleWorkingTest.elf POST_BUILD
    COMMAND arm-none-eabi-objcopy -O ihex $<TARGET_FILE:SimpleWorkingTest.elf> ${CMAKE_BINARY_DIR}/bin/SimpleWorkingTest.hex
    COMMAND arm-none-eabi-objcopy -O binary $<TARGET_FILE:SimpleWorkingTest.elf> ${CMAKE_BINARY_DIR}/bin/SimpleWorkingTest.bin
    COMMAND arm-none-eabi-size $<TARGET_FILE:SimpleWorkingTest.elf>
    COMMENT "Generating simple working test files"
)

# Create Renode-optimized test executable
add_executable(RenodeTest.elf renode_test.c)

# Use minimal linker script for Renode test
set_target_properties(RenodeTest.elf PROPERTIES LINK_DEPENDS ${MINIMAL_LINKER_SCRIPT})
target_link_options(RenodeTest.elf PRIVATE -T${MINIMAL_LINKER_SCRIPT} -nostdlib)

# Set output directory for Renode test
set_target_properties(RenodeTest.elf PROPERTIES
    RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/bin
)

# Generate additional output formats for Renode test
add_custom_command(TARGET RenodeTest.elf POST_BUILD
    COMMAND arm-none-eabi-objcopy -O ihex $<TARGET_FILE:RenodeTest.elf> ${CMAKE_BINARY_DIR}/bin/RenodeTest.hex
    COMMAND arm-none-eabi-objcopy -O binary $<TARGET_FILE:RenodeTest.elf> ${CMAKE_BINARY_DIR}/bin/RenodeTest.bin
    COMMAND arm-none-eabi-size $<TARGET_FILE:RenodeTest.elf>
    COMMENT "Generating Renode test files"
)

# Create ARM Official Semihosting Sample (using minimal linker script to avoid conflicts)
add_executable(OfficialSemihostSample.elf official_semihost_sample.c)

# Use minimal linker script to avoid rdimon.specs conflicts
set_target_properties(OfficialSemihostSample.elf PROPERTIES LINK_DEPENDS ${MINIMAL_LINKER_SCRIPT})
target_link_options(OfficialSemihostSample.elf PRIVATE -T${MINIMAL_LINKER_SCRIPT} --specs=rdimon.specs)

# Create Ultra Simple Semihosting Test (absolute minimal)
add_executable(UltraSimpleSemihost.elf ultra_simple_semihost.c)

# Use minimal linker script with no library dependencies
set_target_properties(UltraSimpleSemihost.elf PROPERTIES LINK_DEPENDS ${MINIMAL_LINKER_SCRIPT})
target_link_options(UltraSimpleSemihost.elf PRIVATE -T${MINIMAL_LINKER_SCRIPT} -nostdlib)

# Create Simple Official Sample (no stdio dependencies)
add_executable(SimpleOfficialSample.elf simple_official_sample.c)

# Use minimal linker script with nosys.specs (more reliable)
set_target_properties(SimpleOfficialSample.elf PROPERTIES LINK_DEPENDS ${MINIMAL_LINKER_SCRIPT})
target_link_options(SimpleOfficialSample.elf PRIVATE -T${MINIMAL_LINKER_SCRIPT} -nostdlib)

# Create UART Output Test (alternative to semihosting)
add_executable(UartOutputTest.elf uart_output_test.c)

# Use minimal linker script for UART test
set_target_properties(UartOutputTest.elf PROPERTIES LINK_DEPENDS ${MINIMAL_LINKER_SCRIPT})
target_link_options(UartOutputTest.elf PRIVATE -T${MINIMAL_LINKER_SCRIPT} -nostdlib)

# Create Simple LED Test (visual confirmation)
add_executable(SimpleLedTest.elf simple_led_test.c)

# Use minimal linker script for LED test
set_target_properties(SimpleLedTest.elf PROPERTIES LINK_DEPENDS ${MINIMAL_LINKER_SCRIPT})
target_link_options(SimpleLedTest.elf PRIVATE -T${MINIMAL_LINKER_SCRIPT} -nostdlib)

# Create Working Semihosting Alternative (multiple output methods)
add_executable(WorkingSemihostAlternative.elf working_semihost_alternative.c)

# Use minimal linker script for alternative test
set_target_properties(WorkingSemihostAlternative.elf PROPERTIES LINK_DEPENDS ${MINIMAL_LINKER_SCRIPT})
target_link_options(WorkingSemihostAlternative.elf PRIVATE -T${MINIMAL_LINKER_SCRIPT} -nostdlib)

# Create Debug Test Program (comprehensive GDB debugging)
add_executable(DebugTestProgram.elf debug_test_program.c)

# Use minimal linker script for debug test
set_target_properties(DebugTestProgram.elf PROPERTIES LINK_DEPENDS ${MINIMAL_LINKER_SCRIPT})
target_link_options(DebugTestProgram.elf PRIVATE -T${MINIMAL_LINKER_SCRIPT} -nostdlib)

# Create Practical Embedded System (real-world example)
add_executable(PracticalEmbeddedSystem.elf practical_embedded_system.c)

# Use minimal linker script for practical system
set_target_properties(PracticalEmbeddedSystem.elf PROPERTIES LINK_DEPENDS ${MINIMAL_LINKER_SCRIPT})
target_link_options(PracticalEmbeddedSystem.elf PRIVATE -T${MINIMAL_LINKER_SCRIPT} -nostdlib)

# Set output directory for official sample
set_target_properties(OfficialSemihostSample.elf PROPERTIES
    RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/bin
)

# Generate additional output formats for official sample
add_custom_command(TARGET OfficialSemihostSample.elf POST_BUILD
    COMMAND arm-none-eabi-objcopy -O ihex $<TARGET_FILE:OfficialSemihostSample.elf> ${CMAKE_BINARY_DIR}/bin/OfficialSemihostSample.hex
    COMMAND arm-none-eabi-objcopy -O binary $<TARGET_FILE:OfficialSemihostSample.elf> ${CMAKE_BINARY_DIR}/bin/OfficialSemihostSample.bin
    COMMAND arm-none-eabi-size $<TARGET_FILE:OfficialSemihostSample.elf>
    COMMENT "Generating ARM official semihosting sample files"
)

# Set output directory for simple official sample
set_target_properties(SimpleOfficialSample.elf PROPERTIES
    RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/bin
)

# Generate additional output formats for simple official sample
add_custom_command(TARGET SimpleOfficialSample.elf POST_BUILD
    COMMAND arm-none-eabi-objcopy -O ihex $<TARGET_FILE:SimpleOfficialSample.elf> ${CMAKE_BINARY_DIR}/bin/SimpleOfficialSample.hex
    COMMAND arm-none-eabi-objcopy -O binary $<TARGET_FILE:SimpleOfficialSample.elf> ${CMAKE_BINARY_DIR}/bin/SimpleOfficialSample.bin
    COMMAND arm-none-eabi-size $<TARGET_FILE:SimpleOfficialSample.elf>
    COMMENT "Generating simple official sample files"
)

# Set output directory for ultra simple semihost test
set_target_properties(UltraSimpleSemihost.elf PROPERTIES
    RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/bin
)

# Generate additional output formats for ultra simple semihost test
add_custom_command(TARGET UltraSimpleSemihost.elf POST_BUILD
    COMMAND arm-none-eabi-objcopy -O ihex $<TARGET_FILE:UltraSimpleSemihost.elf> ${CMAKE_BINARY_DIR}/bin/UltraSimpleSemihost.hex
    COMMAND arm-none-eabi-objcopy -O binary $<TARGET_FILE:UltraSimpleSemihost.elf> ${CMAKE_BINARY_DIR}/bin/UltraSimpleSemihost.bin
    COMMAND arm-none-eabi-size $<TARGET_FILE:UltraSimpleSemihost.elf>
    COMMENT "Generating ultra simple semihosting test files"
)

# Enable compile commands for better IDE support
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

# Set output directory for UART output test
set_target_properties(UartOutputTest.elf PROPERTIES
    RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/bin
)

# Generate additional output formats for UART output test
add_custom_command(TARGET UartOutputTest.elf POST_BUILD
    COMMAND arm-none-eabi-objcopy -O ihex $<TARGET_FILE:UartOutputTest.elf> ${CMAKE_BINARY_DIR}/bin/UartOutputTest.hex
    COMMAND arm-none-eabi-objcopy -O binary $<TARGET_FILE:UartOutputTest.elf> ${CMAKE_BINARY_DIR}/bin/UartOutputTest.bin
    COMMAND arm-none-eabi-size $<TARGET_FILE:UartOutputTest.elf>
    COMMENT "Generating UART output test files"
)

# Set output directory for LED test
set_target_properties(SimpleLedTest.elf PROPERTIES
    RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/bin
)

# Generate additional output formats for LED test
add_custom_command(TARGET SimpleLedTest.elf POST_BUILD
    COMMAND arm-none-eabi-objcopy -O ihex $<TARGET_FILE:SimpleLedTest.elf> ${CMAKE_BINARY_DIR}/bin/SimpleLedTest.hex
    COMMAND arm-none-eabi-objcopy -O binary $<TARGET_FILE:SimpleLedTest.elf> ${CMAKE_BINARY_DIR}/bin/SimpleLedTest.bin
    COMMAND arm-none-eabi-size $<TARGET_FILE:SimpleLedTest.elf>
    COMMENT "Generating LED test files"
)

# Set output directory for working semihosting alternative
set_target_properties(WorkingSemihostAlternative.elf PROPERTIES
    RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/bin
)

# Generate additional output formats for working semihosting alternative
add_custom_command(TARGET WorkingSemihostAlternative.elf POST_BUILD
    COMMAND arm-none-eabi-objcopy -O ihex $<TARGET_FILE:WorkingSemihostAlternative.elf> ${CMAKE_BINARY_DIR}/bin/WorkingSemihostAlternative.hex
    COMMAND arm-none-eabi-objcopy -O binary $<TARGET_FILE:WorkingSemihostAlternative.elf> ${CMAKE_BINARY_DIR}/bin/WorkingSemihostAlternative.bin
    COMMAND arm-none-eabi-size $<TARGET_FILE:WorkingSemihostAlternative.elf>
    COMMENT "Generating working semihosting alternative files"
)

# Set output directory for debug test program
set_target_properties(DebugTestProgram.elf PROPERTIES
    RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/bin
)

# Generate additional output formats for debug test program
add_custom_command(TARGET DebugTestProgram.elf POST_BUILD
    COMMAND arm-none-eabi-objcopy -O ihex $<TARGET_FILE:DebugTestProgram.elf> ${CMAKE_BINARY_DIR}/bin/DebugTestProgram.hex
    COMMAND arm-none-eabi-objcopy -O binary $<TARGET_FILE:DebugTestProgram.elf> ${CMAKE_BINARY_DIR}/bin/DebugTestProgram.bin
    COMMAND arm-none-eabi-size $<TARGET_FILE:DebugTestProgram.elf>
    COMMENT "Generating debug test program files"
)

# Set output directory for practical embedded system
set_target_properties(PracticalEmbeddedSystem.elf PROPERTIES
    RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/bin
)

# Generate additional output formats for practical embedded system
add_custom_command(TARGET PracticalEmbeddedSystem.elf POST_BUILD
    COMMAND arm-none-eabi-objcopy -O ihex $<TARGET_FILE:PracticalEmbeddedSystem.elf> ${CMAKE_BINARY_DIR}/bin/PracticalEmbeddedSystem.hex
    COMMAND arm-none-eabi-objcopy -O binary $<TARGET_FILE:PracticalEmbeddedSystem.elf> ${CMAKE_BINARY_DIR}/bin/PracticalEmbeddedSystem.bin
    COMMAND arm-none-eabi-size $<TARGET_FILE:PracticalEmbeddedSystem.elf>
    COMMENT "Generating practical embedded system files"
)