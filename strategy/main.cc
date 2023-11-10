#include <memory>
#include "decider.hh"
#include "op1.hh"
#include "op2.hh"

int main() {
  auto op1 = std::make_unique<Operator1>();
  auto op2 = std::make_unique<Operator2>();
  Decider s;
  s.SetOp(op1.get());
  s.Transform(10);
  s.SetOp(op2.get());
  s.Transform(10);
  return 0;
}
