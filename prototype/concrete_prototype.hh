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
  ~ConcretePrototype() override { printf("%s\n", __PRETTY_FUNCTION__); }

  std::shared_ptr<Prototype> Clone() override {
    return std::make_shared<ConcretePrototype>(*this);
  }
};

#endif
