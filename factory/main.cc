#include "f1.hh"
#include "f2.hh"

int main(void) {
  AbsFactory *factory = nullptr;
  std::shared_ptr<AbsProduct> p;
  F1 f1;
  F2 f2;
  factory = &f1;
  p = factory->createProduct();
  factory = &f2;
  p = factory->createProduct();

  return 0;
}
