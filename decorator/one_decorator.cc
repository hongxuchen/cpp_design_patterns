#include "one_decorator.hpp"
#include <iostream>

DecoratorOnlyOne::DecoratorOnlyOne(ComponentPtr com) : com_(com) {}

DecoratorOnlyOne::~DecoratorOnlyOne() {
  std::cout << __PRETTY_FUNCTION__ << " DELETION\n";
  /// delete com_;
  com_ = NULL;
}

void DecoratorOnlyOne::Operation() {
  com_->Operation();
  AddBehavor();
}

void DecoratorOnlyOne::AddBehavor() {
  std::cout << __PRETTY_FUNCTION__ << "\n";
}
