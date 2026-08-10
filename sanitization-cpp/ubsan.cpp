#include <climits>
#include <iostream>

int main() {
    int value = INT_MAX;

    value += 1;  // Signed integer overflow.

    std::cout << value << '\n';

    return 0;
}
