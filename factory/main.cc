#include <memory>

#include "abs_factory.hh"
#include "f1.hh"
#include "f2.hh"

int main() {
  AbsFactory *factory = nullptr;
  std::unique_ptr<AbsProduct> p;
  F1 f1;
  F2 f2;
  factory = &f1;
  p = factory->CreateProduct();
  factory = &f2;
  p = factory->CreateProduct();

  return 0;
}
