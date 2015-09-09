#include "class_adapter.hh"
#include "object_adapter.hh"

int main() {
  Target* pTarget = nullptr;

  ClassAdapter adapter1;
  pTarget = &adapter1;
  pTarget->Request();

  auto adaptee = std::make_shared<Adaptee>();
  ObjectAdapter adapterA(adaptee);
  pTarget = &adapterA;
  pTarget->Request();

  ObjectAdapter adapterB;
  pTarget = &adapterB;
  pTarget->Request();

  return 0;
}
