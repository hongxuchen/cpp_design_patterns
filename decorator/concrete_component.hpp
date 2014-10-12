#ifndef CONCRETE_COMPONENT_HPP
#define CONCRETE_COMPONENT_HPP

#include <iostream>

class ConcreteComponent final : public Component {
 public:
  ConcreteComponent() { std::cout << __PRETTY_FUNCTION__ << "\n"; }
  ~ConcreteComponent() { std::cout << __PRETTY_FUNCTION__ << "\n"; }
  virtual void Operation() override {
    std::cout << __PRETTY_FUNCTION__ << "\n";
  }
};

#endif
