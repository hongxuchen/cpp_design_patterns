#ifndef CON_FLY_WEIGHT_HPP
#define CON_FLY_WEIGHT_HPP

#include "fly_weight.hh"
#include <string>

class ConFlyweight : public FlyWeight {
 public:
  ConFlyweight(std::string const& insState);
  void operate(std::string const& exState);
};

#endif
