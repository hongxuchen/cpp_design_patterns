#ifndef CON_FLY_WEIGHT_HPP
#define CON_FLY_WEIGHT_HPP

#include <string>

#include "fly_weight.hh"

class ConFlyweight : public FlyWeight {
 public:
  ConFlyweight(std::string const& ins_state);
  void Operate(std::string const& ex_state) override;
};

#endif
