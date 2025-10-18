// Breakpoint Test File for VSCode Debug Configuration
// This file is designed to test various debugging features

#include <iostream>
#include <vector>
#include <string>
#include <map>

// Test class for debugging complex objects
class DebugTestClass {
private:
    int private_value;
    std::string name;

public:
    DebugTestClass(const std::string& n, int val) : name(n), private_value(val) {}
    
    void printInfo() {
        std::cout << "Name: " << name << ", Value: " << private_value << std::endl;
        // Breakpoint Test Point 1: Set breakpoint here to inspect member variables
    }
    
    int getValue() const { return private_value; }
    std::string getName() const { return name; }
};

// Function to test step-into debugging
int calculateSum(int a, int b) {
    int result = a + b;
    // Breakpoint Test Point 2: Set breakpoint here to inspect parameters and result
    return result;
}

// Function to test complex data structures
void testComplexStructures() {
    // Vector test
    std::vector<int> numbers = {1, 2, 3, 4, 5};
    
    // Map test
    std::map<std::string, int> scores;
    scores["Alice"] = 95;
    scores["Bob"] = 87;
    scores["Charlie"] = 92;
    
    // Breakpoint Test Point 3: Set breakpoint here to inspect containers
    for (const auto& pair : scores) {
        std::cout << pair.first << ": " << pair.second << std::endl;
    }
}

// Function to test exception handling in debugger
void testExceptionHandling() {
    try {
        // Intentional division by zero for testing
        int divisor = 0;
        if (divisor == 0) {
            throw std::runtime_error("Division by zero error for debugging test");
        }
        int result = 100 / divisor;
        std::cout << "Result: " << result << std::endl;
    } catch (const std::exception& e) {
        // Breakpoint Test Point 4: Set breakpoint here to inspect exception
        std::cout << "Caught exception: " << e.what() << std::endl;
    }
}

// Function to test pointer and memory debugging
void testPointerDebugging() {
    int* dynamicInt = new int(42);
    int stackInt = 24;
    int* stackPointer = &stackInt;
    
    // Breakpoint Test Point 5: Set breakpoint here to inspect pointers and memory
    std::cout << "Dynamic value: " << *dynamicInt << std::endl;
    std::cout << "Stack value: " << *stackPointer << std::endl;
    
    delete dynamicInt;
    dynamicInt = nullptr;
    
    // Breakpoint Test Point 6: Set breakpoint here to verify pointer cleanup
}

int main() {
    std::cout << "=== Breakpoint Test Program ===" << std::endl;
    
    // Test 1: Basic variable debugging
    int testVar = 10;
    std::string testString = "Debug Test";
    
    // Breakpoint Test Point 7: Set breakpoint here to inspect basic variables
    std::cout << "Test variable: " << testVar << std::endl;
    std::cout << "Test string: " << testString << std::endl;
    
    // Test 2: Function call debugging
    int sum = calculateSum(15, 25);
    std::cout << "Sum result: " << sum << std::endl;
    
    // Test 3: Object debugging
    DebugTestClass testObj("TestObject", 100);
    testObj.printInfo();
    
    // Test 4: Complex structures
    testComplexStructures();
    
    // Test 5: Exception handling
    testExceptionHandling();
    
    // Test 6: Pointer debugging
    testPointerDebugging();
    
    // Test 7: Loop debugging
    std::cout << "Loop test:" << std::endl;
    for (int i = 0; i < 5; ++i) {
        // Breakpoint Test Point 8: Set conditional breakpoint here (i == 3)
        std::cout << "Loop iteration: " << i << std::endl;
    }
    
    std::cout << "=== Breakpoint Test Completed ===" << std::endl;
    return 0;
}

/*
Debugging Test Instructions:
============================

1. Basic Variable Inspection:
   - Set breakpoint at "Breakpoint Test Point 7"
   - Inspect testVar and testString in Variables panel
   - Verify values are displayed correctly

2. Function Step-Into Test:
   - Set breakpoint at calculateSum() call
   - Use F11 (Step Into) to enter the function
   - Set breakpoint at "Breakpoint Test Point 2"
   - Inspect parameters a, b and result variable

3. Object Member Inspection:
   - Set breakpoint at "Breakpoint Test Point 1"
   - Inspect testObj members (name, private_value)
   - Verify private members are accessible in debugger

4. Container Debugging:
   - Set breakpoint at "Breakpoint Test Point 3"
   - Inspect numbers vector and scores map
   - Expand containers to view individual elements

5. Exception Debugging:
   - Set breakpoint at "Breakpoint Test Point 4"
   - Inspect exception object and message
   - Verify call stack shows exception path

6. Pointer and Memory Debugging:
   - Set breakpoint at "Breakpoint Test Point 5"
   - Inspect dynamicInt and stackPointer
   - View memory addresses and dereferenced values
   - Set breakpoint at "Breakpoint Test Point 6"
   - Verify dynamicInt is nullptr after delete

7. Conditional Breakpoint Test:
   - Set conditional breakpoint at "Breakpoint Test Point 8"
   - Condition: i == 3
   - Verify breakpoint only triggers when condition is met

8. Call Stack Verification:
   - At any breakpoint, verify Call Stack panel shows:
     - Current function
     - Calling function (main)
     - Correct line numbers

9. Watch Expressions:
   - Add watch expressions:
     - testVar * 2
     - testString.length()
     - testObj.getValue()
   - Verify expressions are evaluated correctly

10. Step Execution Test:
    - Use F10 (Step Over) to execute line by line
    - Use F11 (Step Into) to enter function calls
    - Use Shift+F11 (Step Out) to exit functions
    - Verify execution follows expected path
*/