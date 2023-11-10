#ifndef OP2_HPP
#define OP2_HPP

#include <iostream>
#include <vector>
#include "op.hh"

class Operator2 : public Operator {
 public:
  void Transform(unsigned seed) override {
    std::vector<unsigned short> str;
    unsigned temp;
    std::cout << "manual transform: ";
    while (seed != 0u) {
      temp = seed / 8;
      auto reminder = seed - temp * 8;
      str.push_back(reminder);
      seed = temp;
    }
    for (auto it = str.rbegin(); it != str.rend(); ++it) {
      std::cout << *it;
    }
    std::cout << '\n';
  }
};

#endif
