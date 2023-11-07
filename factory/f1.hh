#ifndef F1_H
#define F1_H

#include <cstdio>

#include "abs_factory.hh"

class P1 : public AbsProduct {
 public:
  P1() { printf("%s\n", __PRETTY_FUNCTION__); }
  ~P1() override = default;
};

class F1 final : public AbsFactory {
 public:
  std::shared_ptr<AbsProduct> createProduct() override {
    return std::make_shared<P1>(P1());
  }
  F1() = default;
  ~F1() override = default;
};

#endif
