#pragma once

#include "template.hh"

class Tea : public CaffeineBeverage<Tea> {
public:
    void Brew() {
        std::cout << "brew tea" << std::endl;
    }

    void AddCondiments() {
        std::cout << "add lemon" << std::endl;
    }
};