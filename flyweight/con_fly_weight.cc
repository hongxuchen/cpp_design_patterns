#include "con_fly_weight.hpp"

#include <iostream>

ConFlyweight::ConFlyweight(std::string const& insState) : FlyWeight(insState) {
  std::cout << "ConFlyweight Build " << insState << '\n';
}

void ConFlyweight::operate(std::string const& exState) {
  std::cout << __PRETTY_FUNCTION__ << ": [" << insState_ << ", " << exState
            << "]\n";
}
