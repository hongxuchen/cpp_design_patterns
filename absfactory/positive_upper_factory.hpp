#ifndef _ABSPOSITIVEUPPERPRINTERFACTORY_H
#define _ABSPOSITIVEUPPERPRINTERFACTORY_H

#include "positive_num.hpp"
#include "upper_char.hpp"
#include "abs_factory.hpp"

class PositiveUpperFactory : public AbsFactory {

 public:
  PositiveUpperFactory() {}
  virtual ~PositiveUpperFactory() {}

  virtual std::shared_ptr<AbsNum> createNum() override {
    return std::make_shared<PositiveNum>(PositiveNum());
  }
  virtual std::shared_ptr<AbsChar> createChar() override {
    return std::make_shared<UpperChar>(UpperChar());
  }
};

#endif  // _ABSPOSITIVEUPPERPRINTERFACTORY_H
