#pragma once

#include "template.hh"

class Tea : public CaffeineBeverage<Tea> {
public:
    static void Brew() {
        std::cout << "brew tea" << '\n';
    }

    static void AddCondiments() {
        std::cout << "add lemon" << '\n';
    }
};