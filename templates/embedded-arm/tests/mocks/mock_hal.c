/**
 * @file mock_hal.c
 * @brief Mock implementation of HAL functions for unit testing
 */

#include <stdio.h>
#include <stdint.h>
#include <stdbool.h>

// Mock state tracking
static bool mock_system_initialized = false;
static uint32_t mock_system_clock = 0;

// Mock function implementations
void system_init(void)
{
    printf("[MOCK] system_init() called\n");
    mock_system_initialized = true;
    mock_system_clock = 168000000; // 168MHz
}

bool mock_is_system_initialized(void)
{
    return mock_system_initialized;
}

uint32_t mock_get_system_clock(void)
{
    return mock_system_clock;
}

void mock_reset_system_state(void)
{
    mock_system_initialized = false;
    mock_system_clock = 0;
}

// Mock system tick
static uint32_t mock_system_tick = 0;

void delay_ms(uint32_t ms)
{
    printf("[MOCK] delay_ms(%u) called\n", ms);
    mock_system_tick += ms;
}

uint32_t get_system_tick(void)
{
    return mock_system_tick;
}

void mock_advance_system_tick(uint32_t ticks)
{
    mock_system_tick += ticks;
}

void mock_reset_system_tick(void)
{
    mock_system_tick = 0;
}