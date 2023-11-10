#ifndef F1_H
#define F1_H

#include <cstdio>

#include "abs_factory.hh"

class P1 : public AbsProduct {
 public:
  P1() { printf("%s\n", __PRETTY_FUNCTION__); }
  ~P1() override = default;
};

class F1 : public AbsFactory {
 public:
  std::unique_ptr<AbsProduct> CreateProduct() override {
    return std::make_unique<P1>(P1());
  }
  F1() = default;
  ~F1() override = default;
};

#endif
