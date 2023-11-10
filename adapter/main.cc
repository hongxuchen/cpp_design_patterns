#include "adaptee.hh"
#include "class_adapter.hh"
#include "object_adapter.hh"

int main() {

  // use a ClassAdapter
  {
    ClassAdapter c_adapter{2, 1.2};
    c_adapter.Request();
  }

  {
    // an existing adaptee
    Adaptee adaptee = Adaptee{3, 5.2};
    // eliminate adaptee, transfer to ObjectAdapter
    ObjectAdapter adapter_a(std::move(adaptee));
    adapter_a.Request();
  }

  {
    ObjectAdapter adapter_b{3, 4.4};
    adapter_b.Request();
  }

  return 0;
}
