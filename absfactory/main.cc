#include "negative_lower_factory.hh"
#include "positive_upper_factory.hh"

int main() {
  PositiveUpperFactory positive_upper_factory;
  NegativeLowerFactory negative_lower_factory;

  auto p1 = positive_upper_factory.createNum();
  auto p2 = positive_upper_factory.createChar();
  auto p3 = negative_lower_factory.createNum();
  auto p4 = negative_lower_factory.createChar();

  p1->printNum();
  p2->printChar();
  p3->printNum();
  p4->printChar();

  return 0;
}
