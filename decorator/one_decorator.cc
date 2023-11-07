#include "one_decorator.hh"
#include "component.hh"

#include <iostream>
#include <utility>

DecoratorOnlyOne::DecoratorOnlyOne(ComponentPtr com) : com_(std::move(std::move(com))) {}

DecoratorOnlyOne::~DecoratorOnlyOne() {
  std::cout << __PRETTY_FUNCTION__ << " DELETION\n";
  /// delete com_;
  com_ = nullptr;
}

void DecoratorOnlyOne::Operation() {
  com_->Operation();
  AddBehavor();
}

void DecoratorOnlyOne::AddBehavor() {
  std::cout << __PRETTY_FUNCTION__ << "\n";
}
