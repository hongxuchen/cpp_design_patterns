#include <memory>
#include <iostream>

struct Base {
  void print() { std::cout << "base\n"; }
};

struct Derived {
  void print() { std::cout << "derive\n"; }
};

int main(void) {
  std::shared_ptr<Base> pb = std::shared_ptr<Base>(new Base);
  std::shared_ptr<Derived> pd = std::shared_ptr<Derived>(new Derived);
  std::shared_ptr<Base> pb0(pd);
  pb->print();
  return 0;
}
