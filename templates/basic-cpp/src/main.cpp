#include <iostream>
#include <string>

int main(int argc, char* argv[]) {
    std::cout << "Hello, World!" << std::endl;
    
    // CI/CD friendly: Use command line argument or default name
    std::string name = "Developer";
    
    if (argc > 1) {
        name = argv[1];
    }
    
    std::cout << "Hello, " << name << "!" << std::endl;
    std::cout << "Basic C++ application executed successfully." << std::endl;
    
    return 0;
}