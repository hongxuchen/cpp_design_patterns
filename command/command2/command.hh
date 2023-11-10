#ifndef COMMAND_HPP
#define COMMAND_HPP

#include "roast_cook.hh"

class Command {
 public:
  Command(RoastCook* cook) : cook ( cook) {}
  virtual void ExecuteCmd() = 0;
  virtual ~Command() = default;

 protected:
  RoastCook* cook;
};

class MakeMuttonCmd final : public Command {
 public:
  MakeMuttonCmd(RoastCook* cook) : Command(cook) {}
   void ExecuteCmd() override { cook->MakeMutton(); }
};

class MakeChickenWingCmd final : public Command {
 public:
  MakeChickenWingCmd(RoastCook* cook) : Command(cook) {}
   void ExecuteCmd() override { cook->MakeChickenWing(); }
};

#endif
