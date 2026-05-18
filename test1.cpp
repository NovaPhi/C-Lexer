#include <iostream>

// Print a greeting to the console
int main() {
    std::string name = "World";
    int count = 3;

    while (count > 0) {
        std::cout << "Hello, " << name << "\n";
        count = count - 1;
    }

    return 0;
}