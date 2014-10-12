#include "prototype.hpp"
#include "concrete_prototype.hpp"
#include <memory>

int main(void) {
  std::shared_ptr<Prototype> p = std::make_shared<ConcretePrototype>();
  p->clone();
  return 0;
}
