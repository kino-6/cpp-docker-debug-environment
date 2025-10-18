#include <iostream>
#include <fstream>
#include <string>
#include <unistd.h>  // for isatty
#include <nlohmann/json.hpp>

using json = nlohmann::json;

void printJsonInfo(const json& j) {
    std::cout << "\n=== JSON Content ===" << std::endl;
    std::cout << "Pretty printed JSON:" << std::endl;
    std::cout << j.dump(2) << std::endl;
    
    std::cout << "\n=== Parsed Values ===" << std::endl;
    
    // Access individual values
    if (j.contains("name")) {
        std::cout << "Name: " << j["name"].get<std::string>() << std::endl;
    }
    
    if (j.contains("age")) {
        std::cout << "Age: " << j["age"].get<int>() << std::endl;
    }
    
    if (j.contains("city")) {
        std::cout << "City: " << j["city"].get<std::string>() << std::endl;
    }
    
    if (j.contains("active")) {
        std::cout << "Active: " << (j["active"].get<bool>() ? "Yes" : "No") << std::endl;
    }
    
    if (j.contains("salary")) {
        std::cout << "Salary: $" << j["salary"].get<double>() << std::endl;
    }
    
    // Access array
    if (j.contains("skills") && j["skills"].is_array()) {
        std::cout << "Skills: ";
        for (const auto& skill : j["skills"]) {
            std::cout << skill.get<std::string>() << " ";
        }
        std::cout << std::endl;
    }
    
    // Access nested object
    if (j.contains("address") && j["address"].is_object()) {
        const auto& address = j["address"];
        std::cout << "Address: ";
        if (address.contains("street")) {
            std::cout << address["street"].get<std::string>();
        }
        if (address.contains("zipcode")) {
            std::cout << ", " << address["zipcode"].get<std::string>();
        }
        std::cout << std::endl;
    }
}

bool loadJsonFromFile(const std::string& filename, json& j) {
    std::ifstream file(filename);
    if (!file.is_open()) {
        std::cerr << "Error: Could not open file " << filename << std::endl;
        return false;
    }
    
    try {
        file >> j;
        return true;
    } catch (const json::parse_error& e) {
        std::cerr << "JSON parse error: " << e.what() << std::endl;
        return false;
    }
}

int main() {
    std::cout << "JSON Parser Demo" << std::endl;
    
    // Try to load sample JSON file
    json j;
    if (loadJsonFromFile("data/sample.json", j)) {
        printJsonInfo(j);
    } else {
        std::cout << "Failed to load sample.json, creating sample JSON in memory..." << std::endl;
        
        // Create sample JSON in memory
        j = {
            {"name", "Jane Smith"},
            {"age", 25},
            {"city", "San Francisco"},
            {"skills", {"C++", "Docker", "VSCode"}},
            {"address", {
                {"street", "456 Tech Ave"},
                {"zipcode", "94102"}
            }},
            {"active", true},
            {"salary", 85000.75}
        };
        
        printJsonInfo(j);
    }
    
    // Interactive JSON input (only if stdin is a terminal)
    if (isatty(STDIN_FILENO)) {
        std::cout << "\n=== Interactive Mode ===" << std::endl;
        std::cout << "Enter a JSON string (or 'quit' to exit): ";
        
        std::string input;
        std::getline(std::cin, input);
        
        while (input != "quit" && !input.empty()) {
            try {
                json userJson = json::parse(input);
                std::cout << "Parsed JSON:" << std::endl;
                std::cout << userJson.dump(2) << std::endl;
            } catch (const json::parse_error& e) {
                std::cout << "Invalid JSON: " << e.what() << std::endl;
            }
            
            std::cout << "Enter a JSON string (or 'quit' to exit): ";
            std::getline(std::cin, input);
        }
    } else {
        std::cout << "\n=== Non-interactive mode ===" << std::endl;
        std::cout << "JSON Parser completed successfully!" << std::endl;
    }
    
    std::cout << "Thank you for using the JSON parser!" << std::endl;
    return 0;
}