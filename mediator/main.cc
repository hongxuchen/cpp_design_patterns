#include "telephone.hh"
#include "mediator.hh"

#include <memory>

int main() {
  auto mediator = std::make_shared<Mediator>();
  Telephone p1(111, mediator);
  Telephone p2(222, mediator);

  p1.Dial(222);
  p2.Dial(111);

  return 0;
}
