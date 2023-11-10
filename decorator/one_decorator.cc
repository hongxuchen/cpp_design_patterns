#include "one_decorator.hh"

#include <iostream>
#include <utility>

#include "component.hh"

DecoratorOnlyOne::DecoratorOnlyOne(ComponentPtr com) : com_(std::move(com)) {}

DecoratorOnlyOne::~DecoratorOnlyOne() {
  std::cout << __PRETTY_FUNCTION__ << " DELETION\n";
  com_ = nullptr;
}

void DecoratorOnlyOne::Operation() {
  com_->Operation();
  AddBehavor();
}

void DecoratorOnlyOne::AddBehavor() {  // NOLINT
  std::cout << __PRETTY_FUNCTION__ << "\n";
}
