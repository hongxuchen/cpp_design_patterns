#include "decorator.hh"
#include "component.hh"

#include <iostream>
#include <utility>

Decorator::Decorator(ComponentPtr com) : com_(std::move(std::move(com))) {}

void Decorator::SetComponent(ComponentPtr com) { com_ = std::move(com); }

Decorator::~Decorator() {
  std::cout << __PRETTY_FUNCTION__ << " DELETION\n";
  /// delete com_;
  com_ = nullptr;
}

ConcreteDecoratorA::ConcreteDecoratorA(ComponentPtr com) : Decorator(std::move(com)) {}

ConcreteDecoratorA::~ConcreteDecoratorA() {
  std::cout << __PRETTY_FUNCTION__ << "\n";
}

void ConcreteDecoratorA::Operation() {
  com_->Operation();
  AddBehavorA();
}

void ConcreteDecoratorA::AddBehavorA() {
  std::cout << __PRETTY_FUNCTION__ << "\n";
}

ConcreteDecoratorB::ConcreteDecoratorB(ComponentPtr com) : Decorator(std::move(com)) {}

ConcreteDecoratorB::~ConcreteDecoratorB() {
  std::cout << __PRETTY_FUNCTION__ << "\n";
}

void ConcreteDecoratorB::Operation() {
  com_->Operation();
  AddBehavorB();
}

void ConcreteDecoratorB::AddBehavorB() {
  std::cout << __PRETTY_FUNCTION__ << "\n";
}

ConcreteDecoratorC::ConcreteDecoratorC(ComponentPtr com) : Decorator(std::move(com)) {}

ConcreteDecoratorC::~ConcreteDecoratorC() {
  std::cout << __PRETTY_FUNCTION__ << "\n";
}

void ConcreteDecoratorC::Operation() {
  com_->Operation();
  AddBehavorC();
}

void ConcreteDecoratorC::AddBehavorC() {
  std::cout << __PRETTY_FUNCTION__ << "\n";
}

ConcreteDecoratorD::ConcreteDecoratorD(ComponentPtr com) : Decorator(std::move(com)) {}

ConcreteDecoratorD::~ConcreteDecoratorD() {
  std::cout << __PRETTY_FUNCTION__ << "\n";
}

void ConcreteDecoratorD::Operation() {
  com_->Operation();
  AddBehavorD();
}

void ConcreteDecoratorD::AddBehavorD() {
  std::cout << __PRETTY_FUNCTION__ << "\n";
}
