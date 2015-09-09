#ifndef F1_H
#define F1_H

#include <stdio.h>
#include "abs_factory.hh"

class P1 : public AbsProduct {
 public:
  P1() { printf("%s\n", __PRETTY_FUNCTION__); }
  virtual ~P1() {}
};

class F1 final : public AbsFactory {
 public:
  virtual std::shared_ptr<AbsProduct> createProduct() override {
    return std::make_shared<P1>(P1());
  }
  F1() {}
  ~F1() {}
};

#endif
