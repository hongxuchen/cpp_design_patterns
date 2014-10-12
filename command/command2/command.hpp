#ifndef COMMAND_HPP
#define COMMAND_HPP

#include "roast_cook.hpp"

class Command {
 public:
  Command(RoastCook* cook) { cook_ = cook; }
  virtual void ExecuteCmd() = 0;
  virtual ~Command() = default;

 protected:
  RoastCook* cook_;
};

class MakeMuttonCmd final : public Command {
 public:
  MakeMuttonCmd(RoastCook* cook) : Command(cook) {}
  virtual void ExecuteCmd() { cook_->MakeMutton(); }
};

class MakeChickenWingCmd final : public Command {
 public:
  MakeChickenWingCmd(RoastCook* cook) : Command(cook) {}
  virtual void ExecuteCmd() { cook_->MakeChickenWing(); }
};

#endif
