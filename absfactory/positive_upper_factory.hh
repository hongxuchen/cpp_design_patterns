#ifndef _ABSPOSITIVEUPPERPRINTERFACTORY_H
#define _ABSPOSITIVEUPPERPRINTERFACTORY_H

#include "abs_factory.hh"
#include "positive_num.hh"
#include "upper_char.hh"

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
