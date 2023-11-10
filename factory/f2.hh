#ifndef F2_H
#define F2_H

#include <cstdio>
#include <memory>

#include "abs_factory.hh"

class P2 : public AbsProduct {
 public:
  P2() { printf("%s\n", __PRETTY_FUNCTION__); }
  ~P2() override = default;
};

class F2 : public AbsFactory {
 public:
  std::unique_ptr<AbsProduct> CreateProduct() override {
    return std::make_unique<P2>(P2());
  }
  F2() = default;
  ~F2() override = default;
};

#endif
