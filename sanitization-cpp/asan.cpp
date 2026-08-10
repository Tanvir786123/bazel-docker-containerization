#include <iostream>

int main() {
    int *values = new int[4];

    values[4] = 42;  // Out-of-bounds write.

    std::cout << values[4] << '\n';

    delete[] values;
    return 0;
}
