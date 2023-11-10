#include "decorator.hh"

#include <iostream>
#include <utility>

#include "component.hh"

Decorator::Decorator(ComponentPtr com) : com(std::move(com)) {}

void Decorator::SetComponent(ComponentPtr com) { this->com = std::move(com); }

Decorator::~Decorator() {
  std::cout << __PRETTY_FUNCTION__ << " DELETION\n";
  /// delete com_;
  com = nullptr;
}

ConcreteDecoratorA::ConcreteDecoratorA(ComponentPtr com)
    : Decorator(std::move(com)) {}

ConcreteDecoratorA::~ConcreteDecoratorA() {
  std::cout << __PRETTY_FUNCTION__ << "\n";
}

void ConcreteDecoratorA::Operation() {
  com->Operation();
  AddBehavorA();
}

void ConcreteDecoratorA::AddBehavorA() {  // NOLINT
  std::cout << __PRETTY_FUNCTION__ << "\n";
}

ConcreteDecoratorB::ConcreteDecoratorB(ComponentPtr com)
    : Decorator(std::move(com)) {}

ConcreteDecoratorB::~ConcreteDecoratorB() {
  std::cout << __PRETTY_FUNCTION__ << "\n";
}

void ConcreteDecoratorB::Operation() {
  com->Operation();
  AddBehavorB();
}

void ConcreteDecoratorB::AddBehavorB() {  // NOLINT
  std::cout << __PRETTY_FUNCTION__ << "\n";
}

ConcreteDecoratorC::ConcreteDecoratorC(ComponentPtr com)
    : Decorator(std::move(com)) {}

ConcreteDecoratorC::~ConcreteDecoratorC() {
  std::cout << __PRETTY_FUNCTION__ << "\n";
}

void ConcreteDecoratorC::Operation() {
  com->Operation();
  AddBehavorC();
}

void ConcreteDecoratorC::AddBehavorC() {  // NOLINT
  std::cout << __PRETTY_FUNCTION__ << "\n";
}

ConcreteDecoratorD::ConcreteDecoratorD(ComponentPtr com)
    : Decorator(std::move(com)) {}

ConcreteDecoratorD::~ConcreteDecoratorD() {
  std::cout << __PRETTY_FUNCTION__ << "\n";
}

void ConcreteDecoratorD::Operation() {
  com->Operation();
  AddBehavorD();
}

void ConcreteDecoratorD::AddBehavorD() {  // NOLINT
  std::cout << __PRETTY_FUNCTION__ << "\n";
}
