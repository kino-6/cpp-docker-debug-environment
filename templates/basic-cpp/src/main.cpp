#include <iostream>
#include <string>

int main() {
    std::cout << "Hello, World!" << std::endl;
    
    std::string name;
    std::cout << "Enter your name: ";
    std::getline(std::cin, name);
    
    if (!name.empty()) {
        std::cout << "Hello, " << name << "!" << std::endl;
    }
    
    return 0;
}