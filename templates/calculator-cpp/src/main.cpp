#include <iostream>
#include <iomanip>
#include <stdexcept>
#include "calculator.h"

void printMenu() {
    std::cout << "\n=== Simple Calculator ===" << std::endl;
    std::cout << "1. Addition" << std::endl;
    std::cout << "2. Subtraction" << std::endl;
    std::cout << "3. Multiplication" << std::endl;
    std::cout << "4. Division" << std::endl;
    std::cout << "5. Exit" << std::endl;
    std::cout << "Choose an operation (1-5): ";
}

int main() {
    std::cout << "Welcome to the Calculator!" << std::endl;
    
    int choice;
    double num1, num2, result;
    
    while (true) {
        printMenu();
        std::cin >> choice;
        
        if (choice == 5) {
            std::cout << "Thank you for using the calculator!" << std::endl;
            break;
        }
        
        if (choice < 1 || choice > 4) {
            std::cout << "Invalid choice. Please try again." << std::endl;
            continue;
        }
        
        std::cout << "Enter first number: ";
        std::cin >> num1;
        std::cout << "Enter second number: ";
        std::cin >> num2;
        
        try {
            switch (choice) {
                case 1:
                    result = Calculator::add(num1, num2);
                    std::cout << std::fixed << std::setprecision(2);
                    std::cout << num1 << " + " << num2 << " = " << result << std::endl;
                    break;
                case 2:
                    result = Calculator::subtract(num1, num2);
                    std::cout << std::fixed << std::setprecision(2);
                    std::cout << num1 << " - " << num2 << " = " << result << std::endl;
                    break;
                case 3:
                    result = Calculator::multiply(num1, num2);
                    std::cout << std::fixed << std::setprecision(2);
                    std::cout << num1 << " * " << num2 << " = " << result << std::endl;
                    break;
                case 4:
                    result = Calculator::divide(num1, num2);
                    std::cout << std::fixed << std::setprecision(2);
                    std::cout << num1 << " / " << num2 << " = " << result << std::endl;
                    break;
            }
        } catch (const std::exception& e) {
            std::cout << "Error: " << e.what() << std::endl;
        }
    }
    
    return 0;
}