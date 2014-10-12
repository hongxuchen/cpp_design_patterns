#include "negative_lower_factory.hpp"
#include "positive_upper_factory.hpp"
#include <memory>

int main(void) {
  PositiveUpperFactory positiveUpperFactory;
  NegativeLowerFactory negativeLowerFactory;

  auto p1 = positiveUpperFactory.createNum();
  auto p2 = positiveUpperFactory.createChar();
  auto p3 = negativeLowerFactory.createNum();
  auto p4 = negativeLowerFactory.createChar();

  p1->printNum();
  p2->printChar();
  p3->printNum();
  p4->printChar();

  return 0;
}
