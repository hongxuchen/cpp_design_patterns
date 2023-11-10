#ifndef CONCRETE_COMPONENT_HPP
#define CONCRETE_COMPONENT_HPP

#include <iostream>

#include "component.hh"

class ConcreteComponent final : public Component {
 public:
  ConcreteComponent() { std::cout << __PRETTY_FUNCTION__ << "\n"; }
  ~ConcreteComponent() override { std::cout << __PRETTY_FUNCTION__ << "\n"; }
  void Operation() override { std::cout << __PRETTY_FUNCTION__ << "\n"; }
};

#endif
