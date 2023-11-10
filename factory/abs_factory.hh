#ifndef FACTORY_H
#define FACTORY_H

#include <memory>

class AbsProduct {
 public:
  virtual ~AbsProduct() = 0;

 protected:
  AbsProduct() {}
};

inline AbsProduct::~AbsProduct() = default;

class AbsFactory {
 public:
  virtual ~AbsFactory() = 0;
  virtual std::unique_ptr<AbsProduct> CreateProduct() = 0;

 protected:
  AbsFactory() {}
};

inline AbsFactory::~AbsFactory() {}

#endif
