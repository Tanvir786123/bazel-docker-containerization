#include <iostream>
#include <thread>

int counter = 0;

void increment() {
    for (int i = 0; i < 100000; ++i) {
        ++counter;
    }
}

int main() {
    std::thread first(increment);
    std::thread second(increment);

    first.join();
    second.join();

    std::cout << counter << '\n';

    return 0;
}
