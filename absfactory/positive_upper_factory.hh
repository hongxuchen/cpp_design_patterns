#ifndef _ABSPOSITIVEUPPERPRINTERFACTORY_H
#define _ABSPOSITIVEUPPERPRINTERFACTORY_H

#include "abs_factory.hh"
#include "positive_num.hh"
#include "upper_char.hh"

class PositiveUpperFactory : public AbsFactory {
 public:
  PositiveUpperFactory() = default;
  ~PositiveUpperFactory() override = default;

  std::unique_ptr<AbsNum> CreateNum() override {
    return std::make_unique<PositiveNum>(PositiveNum());
  }
  std::unique_ptr<AbsChar> CreateChar() override {
    return std::make_unique<UpperChar>(UpperChar());
  }
};

#endif  // _ABSPOSITIVEUPPERPRINTERFACTORY_H
