#include <iostream>
#include <string>
#include <vector>

// Simple function for debugging demonstration
int calculateSum(int a, int b) {
    int result = a + b;  // ← ブレークポイント設定箇所 1
    return result;
}

int main(int argc, char* argv[]) {
    std::cout << "=== Debug Demo Started ===" << std::endl;  // ← ブレークポイント設定箇所 2
    
    // CI/CD friendly: Use command line argument or default name
    std::string name = "Developer";
    
    if (argc > 1) {
        name = argv[1];  // ← ブレークポイント設定箇所 3
    }
    
    // Create some variables for debugging
    int x = 10;
    int y = 20;
    std::vector<int> numbers = {1, 2, 3, 4, 5};
    
    std::cout << "Hello, World!" << std::endl;
    std::cout << "Hello, " << name << "!" << std::endl;
    
    // Call function for step-into debugging
    int sum = calculateSum(x, y);  // ← ブレークポイント設定箇所 4
    
    std::cout << "Sum of " << x << " and " << y << " is: " << sum << std::endl;
    
    // Loop for debugging
    std::cout << "Numbers: ";
    for (size_t i = 0; i < numbers.size(); ++i) {
        std::cout << numbers[i] << " ";  // ← ブレークポイント設定箇所 5 (条件付き: i == 2)
    }
    std::cout << std::endl;
    
    std::cout << "Basic C++ application executed successfully." << std::endl;
    
    return 0;
}