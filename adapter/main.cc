#include "adaptee.hh"
#include "class_adapter.hh"
#include "object_adapter.hh"
#include "target.hh"
#include <memory>

int main() {
  Target* p_target = nullptr;

  ClassAdapter adapter1;
  p_target = &adapter1;
  p_target->Request();

  auto adaptee = std::make_shared<Adaptee>();
  ObjectAdapter adapter_a(adaptee);
  p_target = &adapter_a;
  p_target->Request();

  ObjectAdapter adapter_b;
  p_target = &adapter_b;
  p_target->Request();

  return 0;
}
