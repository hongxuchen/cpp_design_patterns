#ifndef CONCRETE_PROTOTYPE_H
#define CONCRETE_PROTOTYPE_H

#include <stdio.h>
#include "prototype.hh"

class ConcretePrototype final : public Prototype {
 public:
  ConcretePrototype() { printf("%s\n", __PRETTY_FUNCTION__); }
  ConcretePrototype(ConcretePrototype const&) {
    printf("%s\n", __PRETTY_FUNCTION__);
  }
  ~ConcretePrototype() { printf("%s\n", __PRETTY_FUNCTION__); }

  virtual std::shared_ptr<Prototype> clone() override {
    return std::make_shared<ConcretePrototype>(*this);
  }
};

#endif
