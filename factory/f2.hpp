#ifndef F2_H
#define F2_H

#include <stdio.h>
#include "abs_factory.hpp"

class P2 : public AbsProduct {
 public:
  P2() { printf("%s\n", __PRETTY_FUNCTION__); }
  virtual ~P2() {}
};

class F2 final : public AbsFactory {
 public:
  virtual std::shared_ptr<AbsProduct> createProduct() override {
    return std::make_shared<P2>(P2());
  }
  F2() {}
  ~F2() {}
};

#endif
