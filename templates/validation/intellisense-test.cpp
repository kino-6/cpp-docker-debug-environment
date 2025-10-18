// IntelliSense Test File
// This file tests various IntelliSense features in the Dev Container environment

#include <iostream>
#include <vector>
#include <string>
#include <memory>
#include <algorithm>

// Test 1: Standard library IntelliSense
void test_standard_library() {
    std::vector<int> numbers = {1, 2, 3, 4, 5};
    
    // IntelliSense should provide auto-completion for:
    // - std::vector methods (push_back, size, etc.)
    // - std::algorithm functions
    // - Iterator types
    
    std::sort(numbers.begin(), numbers.end());
    
    auto it = std::find(numbers.begin(), numbers.end(), 3);
    if (it != numbers.end()) {
        std::cout << "Found: " << *it << std::endl;
    }
}

// Test 2: Modern C++ features
void test_modern_cpp() {
    // Auto type deduction
    auto lambda = [](int x) -> int {
        return x * 2;
    };
    
    // Smart pointers
    std::unique_ptr<std::string> ptr = std::make_unique<std::string>("test");
    
    // Range-based for loop
    std::vector<std::string> words = {"hello", "world", "cpp"};
    for (const auto& word : words) {
        std::cout << word << " ";
    }
}

// Test 3: Template IntelliSense
template<typename T>
class TestTemplate {
private:
    T value;
    
public:
    explicit TestTemplate(T val) : value(val) {}
    
    T getValue() const { return value; }
    void setValue(T val) { value = val; }
    
    // IntelliSense should provide template-aware completion
    template<typename U>
    auto combine(const U& other) -> decltype(value + other) {
        return value + other;
    }
};

// Test 4: Error detection
void test_error_detection() {
    // These should be highlighted as errors by IntelliSense:
    
    // Uncomment to test error detection:
    // int undefined_variable = some_undefined_function();
    // std::vector<int> vec;
    // vec.nonexistent_method();
    // TestTemplate<int> tmpl;  // Missing constructor argument
}

// Test 5: Include path resolution
#ifdef __has_include
    #if __has_include(<nlohmann/json.hpp>)
        #include <nlohmann/json.hpp>
        void test_external_library() {
            // This should work in JSON Parser template
            nlohmann::json j = {{"test", true}};
            std::cout << j.dump() << std::endl;
        }
    #endif
#endif

int main() {
    std::cout << "IntelliSense Test File" << std::endl;
    std::cout << "This file tests various IntelliSense features." << std::endl;
    
    test_standard_library();
    test_modern_cpp();
    
    #ifdef __has_include
        #if __has_include(<nlohmann/json.hpp>)
            test_external_library();
        #endif
    #endif
    
    return 0;
}