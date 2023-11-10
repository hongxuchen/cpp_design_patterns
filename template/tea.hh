#pragma once

#include "template.hh"

class Coffee : public CaffeineBeverage<Coffee> {
public:
    static void Brew() {
        std::cout << "brew coffee\n";
    }

    static void AddCondiments() {
        std::cout << "add sugar and milk\n";
    }
};