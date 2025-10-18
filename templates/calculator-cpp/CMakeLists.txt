cmake_minimum_required(VERSION 3.16)
project(CalculatorProject VERSION 1.0.0)

# Set C++ standard
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# Enable debug symbols for debugging but with some optimization
if(NOT CMAKE_BUILD_TYPE)
    set(CMAKE_BUILD_TYPE RelWithDebInfo)
endif()

# Add compile options for better debugging and warnings
if(MSVC)
    add_compile_options(/W4 /MP)  # /MP enables parallel compilation
    # Set maximum parallel processes for MSVC
    if(NOT DEFINED CMAKE_VS_GLOBALS)
        set(CMAKE_VS_GLOBALS "UseMultiToolTask=true")
    endif()
else()
    add_compile_options(-Wall -Wextra -g)
    # Enable parallel compilation for GCC/Clang
    if(CMAKE_VERSION VERSION_GREATER_EQUAL "3.12")
        include(ProcessorCount)
        ProcessorCount(N)
        if(NOT N EQUAL 0)
            set(CMAKE_BUILD_PARALLEL_LEVEL ${N})
        endif()
    endif()
endif()

# Enable parallel builds for generators that support it
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

# Optimize for faster builds
if(CMAKE_BUILD_TYPE STREQUAL "Debug")
    # Use faster linker for debug builds
    if(UNIX AND NOT APPLE)
        find_program(LLD_LINKER lld)
        if(LLD_LINKER)
            add_link_options(-fuse-ld=lld)
        endif()
    endif()
endif()

# Include directories
include_directories(include)

# Create calculator library
add_library(calculator_lib src/calculator.cpp)
target_include_directories(calculator_lib PUBLIC include)

# Add executable
add_executable(${PROJECT_NAME} src/main.cpp)

# Link the library to the executable
target_link_libraries(${PROJECT_NAME} calculator_lib)

# Set output directory
set_target_properties(${PROJECT_NAME} PROPERTIES
    RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/bin
)