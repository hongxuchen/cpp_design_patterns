#pragma once

#include <iostream>

template<typename T>
class CaffeineBeverage {
public:
    void PrepareRecipe() {
        BoilWater();
        Brew();
        PourInCup();
        AddCondiments();
    }

    void BoilWater() {
        std::cout << "boil water\n";
    }

    void Brew() {
        static_cast<T *>(this)->Brew();
    }

    void PourInCup() {
        std::cout << "pour in cup\n";
    }

    void AddCondiments() {
        static_cast<T *>(this)->AddCondiments();
    }
};