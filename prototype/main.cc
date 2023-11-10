#include "prototype.hh"
#include "concrete_prototype.hh"
#include <memory>

int main() {
  std::shared_ptr<Prototype> const p = std::make_shared<ConcretePrototype>();
  p->Clone();
  return 0;
}
