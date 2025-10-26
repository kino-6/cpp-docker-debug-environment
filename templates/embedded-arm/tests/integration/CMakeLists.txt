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

# Linker script
set(MINIMAL_LINKER_SCRIPT ${CMAKE_SOURCE_DIR}/minimal.ld)

# Include directories
include_directories(
    ${CMAKE_SOURCE_DIR}/../../include
    ${CMAKE_SOURCE_DIR}/../../src/hal
    ${CMAKE_SOURCE_DIR}/../../src/drivers
    ${CMAKE_SOURCE_DIR}/../mocks
)

# Helper function to create ARM executable
function(create_arm_executable target_name source_file)
    add_executable(${target_name} ${source_file})
    set_target_properties(${target_name} PROPERTIES
        LINK_DEPENDS ${MINIMAL_LINKER_SCRIPT}
        RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/bin
    )
    target_link_options(${target_name} PRIVATE -T${MINIMAL_LINKER_SCRIPT} -nostdlib)
    
    # Generate HEX and BIN files
    add_custom_command(TARGET ${target_name} POST_BUILD
        COMMAND arm-none-eabi-objcopy -O ihex $<TARGET_FILE:${target_name}> ${CMAKE_BINARY_DIR}/bin/${target_name}.hex
        COMMAND arm-none-eabi-objcopy -O binary $<TARGET_FILE:${target_name}> ${CMAKE_BINARY_DIR}/bin/${target_name}.bin
        COMMAND arm-none-eabi-size $<TARGET_FILE:${target_name}>
        COMMENT "Generating ${target_name} output files"
    )
endfunction()

# Create main test executables
create_arm_executable(PracticalEmbeddedSystem.elf practical_embedded_system.c)
create_arm_executable(DebugTestProgram.elf debug_test_program.c)
create_arm_executable(SimpleLedTest.elf simple_led_test.c)
create_arm_executable(WorkingSemihostAlternative.elf working_semihost_alternative.c)

# Create additional test executables
create_arm_executable(SimpleQemuTest.elf simple_qemu_test.c)
create_arm_executable(WorkingQemuTest.elf working_qemu_test.c)
create_arm_executable(ImprovedQemuTest.elf improved_qemu_test.c)
create_arm_executable(DebugQemuTest.elf debug_qemu_test.c)

# Enable compile commands for better IDE support
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)