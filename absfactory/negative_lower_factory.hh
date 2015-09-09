#ifndef NEGATIVE_LOWER_FACTORY_H
#define NEGATIVE_LOWER_FACTORY_H

#include "negative_num.hh"
#include "lower_char.hh"
#include "abs_factory.hh"

class NegativeLowerFactory : public AbsFactory {
 public:
  NegativeLowerFactory() {}
  virtual ~NegativeLowerFactory() {}

  std::shared_ptr<AbsNum> createNum() override {
    return std::make_shared<NegativeNum>(NegativeNum());
  }
  std::shared_ptr<AbsChar> createChar() override {
    return std::make_shared<LowerChar>(LowerChar());
  }
};

#endif  // _ABSNEGATIVELOWERPRINTERFACTORY_H
