#ifndef CLASS_ADAPTER_HPP
#define CLASS_ADAPTER_HPP

#include <iostream>

#include "adaptee.hh"
#include "target.hh"

// adapt by inheritance, C++ specific
class ClassAdapter final : public Target, private Adaptee {
 public:
  ClassAdapter(int i, double j) : Adaptee(i, j) {}
  ~ClassAdapter() override = default;
  void Request() override {
    SpecificRequest();
    // i/j can be accessed directly
    std::cout << __PRETTY_FUNCTION__ << " => (" << i << ", " << j << ")\n";
  }
};

#endif
