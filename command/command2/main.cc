#include <iostream>
#include <memory>

#include "roast_cook.hh"
#include "command.hh"
#include "waiter.hh"

int main() {
  RoastCook cook;
  std::unique_ptr<Command> cmd1 = std::make_unique<MakeMuttonCmd>(&cook);
  std::unique_ptr<Command> cmd2 = std::make_unique<MakeChickenWingCmd>(&cook);
  Waiter waiter;

  waiter.setCmd(cmd1.get());
  waiter.setCmd(cmd2.get());

  waiter.notify();
  return 0;
}
