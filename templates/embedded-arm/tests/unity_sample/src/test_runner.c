#include "unity.h"
#include <stdio.h>

// External test function declarations
void test_led_init(void);
void test_led_set_on(void);
void test_led_set_off(void);
void test_led_toggle(void);

// Unity test runner
int main(void) {
    printf("Unity Test Framework - LED Control Sample\n");
    printf("==========================================\n\n");
    
    UNITY_BEGIN();
    
    // Run LED tests
    RUN_TEST(test_led_init);
    RUN_TEST(test_led_set_on);
    RUN_TEST(test_led_set_off);
    RUN_TEST(test_led_toggle);
    
    return UNITY_END();
}