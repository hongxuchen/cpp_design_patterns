#ifndef CLASS_ADAPTER_HPP
#define CLASS_ADAPTER_HPP

#include "target.hpp"
#include "adaptee.hpp"
#include <iostream>

// inheritance
class ClassAdapter final : public Target, private Adaptee {
 public:
  ClassAdapter() {}
  ~ClassAdapter() {}
  virtual void Request() override {
    SpecificRequest();
    std::cout << __PRETTY_FUNCTION__ << "\n";
  }
};


#endif
