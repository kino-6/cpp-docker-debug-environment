/**
 * @file mock_system.c
 * @brief Mock implementation of system functions for unit testing
 */

#include <stdio.h>
#include <stdint.h>
#include <unistd.h>

// Mock delay function (non-blocking for tests)
void delay_ms(uint32_t ms)
{
    printf("[MOCK] delay_ms(%u) - simulated\n", ms);
    // For unit tests, we don't actually delay
    // In integration tests, we might use usleep(ms * 1000)
    (void)ms; // Suppress unused parameter warning
}

// Mock system tick counter
static volatile uint32_t mock_system_tick = 0;

uint32_t get_system_tick(void)
{
    return mock_system_tick;
}

void mock_advance_system_tick(uint32_t ticks)
{
    mock_system_tick += ticks;
    printf("[MOCK] System tick advanced by %u to %u\n", ticks, mock_system_tick);
}

void mock_reset_system_tick(void)
{
    mock_system_tick = 0;
}