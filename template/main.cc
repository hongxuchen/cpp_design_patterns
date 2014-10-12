#include <iostream>

#include "coffee.hpp"
#include "tea.hpp"


int main(void) {
    std::cout << "coffee\n";
    Coffee c;
    c.PrepareRecipe();

    std::cout << "\ntea:\n";
    Tea t;
    t.PrepareRecipe();
    return 0;
}