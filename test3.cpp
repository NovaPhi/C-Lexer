#include <iostream>

// A simple student record
class Student {
public:
    std::string name;
    int age;
    int grade;

    bool is_passing() {
        return grade >= 60;
    }
};

int main() {
    Student s;
    s.name = "Alice";
    s.age = 20;
    s.grade = 85;

    if (s.is_passing()) {
        std::cout << "Passing\n";
    } else {
        std::cout << "Failing\n";
    }

    return 0;
}