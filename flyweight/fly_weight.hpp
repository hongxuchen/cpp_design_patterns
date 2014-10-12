#ifndef FLY_WEIGHT_HPP
#define FLY_WEIGHT_HPP

#include <string>

class FlyWeight {
 public:
  virtual void operate(std::string const& exState) = 0;
  std::string insState() { return insState_; }

 protected:
  FlyWeight(std::string const& insState) { insState_ = insState; }
  std::string insState_;
};

#endif
