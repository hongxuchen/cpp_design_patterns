#ifndef NEGATIVE_LOWER_FACTORY_H
#define NEGATIVE_LOWER_FACTORY_H

#include "abs_factory.hh"
#include "lower_char.hh"
#include "negative_num.hh"

class NegativeLowerFactory : public AbsFactory {
 public:
  NegativeLowerFactory() = default;
  ~NegativeLowerFactory() override = default;

  std::unique_ptr<AbsNum> CreateNum() override {
    return std::make_unique<NegativeNum>(NegativeNum());
  }
  std::unique_ptr<AbsChar> CreateChar() override {
    return std::make_unique<LowerChar>(LowerChar());
  }
};

#endif  // _ABSNEGATIVELOWERPRINTERFACTORY_H
