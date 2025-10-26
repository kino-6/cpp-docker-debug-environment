# Main application component
idf_component_register(
    SRCS 
        "simple_main.c"
    INCLUDE_DIRS 
        "."
        "include"
    REQUIRES
        driver
        freertos
)