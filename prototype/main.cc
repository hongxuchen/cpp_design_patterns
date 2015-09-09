#include "prototype.hh"
#include "concrete_prototype.hh"
#include <memory>

int main(void) {
  std::shared_ptr<Prototype> p = std::make_shared<ConcretePrototype>();
  p->clone();
  return 0;
}
