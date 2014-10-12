#ifndef FACTORY_H
#define FACTORY_H

#include <memory>

class AbsProduct {
 public:
  virtual ~AbsProduct() = 0;

 protected:
  AbsProduct() {}
};

AbsProduct::~AbsProduct() {}

class AbsFactory {
 public:
  virtual ~AbsFactory() = 0;
  virtual std::shared_ptr<AbsProduct> createProduct() = 0;

 protected:
  AbsFactory() {}
};

AbsFactory::~AbsFactory() {}

#endif
