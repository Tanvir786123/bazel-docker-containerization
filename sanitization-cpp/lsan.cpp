#include <iostream>

int main() {
    int* value = new int(42);

    std::cout << *value << '\n';

    // Intentionally leaked.
    return 0;
}
