#ifndef OP1_HPP
#define OP1_HPP

#include <sstream>
#include <iostream>
#include "op.hh"

class Operator1 : public Operator {
 public:
  void Transform(unsigned seed) override {
    std::cout << "sstream transform: ";
    std::stringstream sstream;
    sstream << std::oct << seed;
    std::cout << sstream.str() << '\n';
  }
};

#endif
