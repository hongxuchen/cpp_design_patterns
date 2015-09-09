#pragma once

#include "template.hh"

class Coffee : public CaffeineBeverage<Coffee> {
public:
    void Brew() {
        std::cout << "brew coffee\n";
    }

    void AddCondiments() {
        std::cout << "add sugar and milk\n";
    }
};