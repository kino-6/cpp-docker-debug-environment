/**
 * @file mock_system.c
 * @brief Mock implementation of system functions for unit testing
 */

#include <stdio.h>
#include <stdint.h>
#include <stdbool.h>

// Mock system state
static uint32_t mock_system_tick = 0;
static bool mock_system_running = false;

// Mock system functions
void system_tick_handler(void)
{
    printf("[MOCK] system_tick_handler() called\n");
    mock_system_tick++;
}

void system_start(void)
{
    printf("[MOCK] system_start() called\n");
    mock_system_running = true;
}

void system_stop(void)
{
    printf("[MOCK] system_stop() called\n");
    mock_system_running = false;
}

// Mock test helper functions
uint32_t mock_get_system_tick_count(void)
{
    return mock_system_tick;
}

bool mock_is_system_running(void)
{
    return mock_system_running;
}

void mock_reset_system_tick_count(void)
{
    mock_system_tick = 0;
}

void mock_set_system_running(bool running)
{
    mock_system_running = running;
}