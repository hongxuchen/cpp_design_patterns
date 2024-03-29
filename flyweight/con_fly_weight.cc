#include "con_fly_weight.hh"
#include "fly_weight.hh"

#include <iostream>
#include <string>

ConFlyweight::ConFlyweight(std::string const& ins_state) : FlyWeight(ins_state) {
  std::cout << "ConFlyweight Build " << ins_state << '\n';
}

void ConFlyweight::Operate(std::string const& ex_state) {
  std::cout << __PRETTY_FUNCTION__ << ": [" << ins_state << ", " << ex_state
            << "]\n";
}
