#ifndef FLY_WEIGHT_HPP
#define FLY_WEIGHT_HPP

#include <string>

class FlyWeight {
 public:
  virtual void Operate(std::string const& ex_state) = 0;
  std::string InsState() { return ins_state; }

 protected:
  FlyWeight(std::string const& ins_state) : ins_state(ins_state) {}
  std::string ins_state;
};

#endif
