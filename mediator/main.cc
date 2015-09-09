#include "telephone.hh"
#include "mediator.hh"

#include <memory>

int main(void) {
  auto mediator = std::make_shared<Mediator>();
  Telephone p1(111, mediator);
  Telephone p2(222, mediator);

  p1.dial(222);
  p2.dial(111);

  return 0;
}
