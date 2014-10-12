#include <memory>
#include "decider.hpp"
#include "op1.hpp"
#include "op2.hpp"

int main(void) {
  auto op1 = std::make_unique<Operator1>();
  auto op2 = std::make_unique<Operator2>();
  Decider s;
  s.setOp(op1.get());
  s.transform(10);
  s.setOp(op2.get());
  s.transform(10);
  return 0;
}
