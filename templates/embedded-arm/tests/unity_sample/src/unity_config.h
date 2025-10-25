#ifndef UNITY_CONFIG_H
#define UNITY_CONFIG_H

#include <stdio.h>

// Unity configuration for embedded testing

// Basic Unity settings
#define UNITY_INCLUDE_DOUBLE
#define UNITY_INCLUDE_FLOAT
#define UNITY_SUPPORT_64

// Output configuration
#define UNITY_OUTPUT_CHAR(a)    putchar(a)
#define UNITY_OUTPUT_FLUSH()     fflush(stdout)
#define UNITY_OUTPUT_START()     /* No special start needed */
#define UNITY_OUTPUT_COMPLETE()  /* No special complete needed */

// Memory configuration for embedded systems
#define UNITY_POINTER_WIDTH 32

// Test configuration
#define UNITY_EXCLUDE_SETJMP_H   // For embedded systems without setjmp

#endif // UNITY_CONFIG_H