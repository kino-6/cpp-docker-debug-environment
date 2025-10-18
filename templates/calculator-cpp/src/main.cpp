#include <iostream>
#include <iomanip>
#include <stdexcept>
#include "calculator.h"

void runDemo() {
    std::cout << "\n=== Calculator Demo ===" << std::endl;
    
    // Demo calculations for CI/CD testing
    double num1 = 10.5, num2 = 3.2;
    
    try {
        std::cout << std::fixed << std::setprecision(2);
        
        double result = Calculator::add(num1, num2);
        std::cout << "Addition: " << num1 << " + " << num2 << " = " << result << std::endl;
        
        result = Calculator::subtract(num1, num2);
        std::cout << "Subtraction: " << num1 << " - " << num2 << " = " << result << std::endl;
        
        result = Calculator::multiply(num1, num2);
        std::cout << "Multiplication: " << num1 << " * " << num2 << " = " << result << std::endl;
        
        result = Calculator::divide(num1, num2);
        std::cout << "Division: " << num1 << " / " << num2 << " = " << result << std::endl;
        
        // Test division by zero handling
        try {
            result = Calculator::divide(num1, 0);
        } catch (const std::exception& e) {
            std::cout << "Division by zero test: " << e.what() << std::endl;
        }
        
        std::cout << "Calculator demo completed successfully." << std::endl;
        
    } catch (const std::exception& e) {
        std::cout << "Error: " << e.what() << std::endl;
    }
}

int main(int argc, char* argv[]) {
    std::cout << "Welcome to the Calculator!" << std::endl;
    
    // CI/CD friendly: Run demo by default, or use command line arguments
    if (argc > 1 && std::string(argv[1]) == "--interactive") {
        std::cout << "Interactive mode not implemented in CI/CD version." << std::endl;
        std::cout << "Use without arguments for demo mode." << std::endl;
        return 1;
    }
    
    runDemo();
    return 0;
}