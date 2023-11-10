#include <memory>

#include "roast_cook.hh"
#include "command.hh"
#include "waiter.hh"

int main() {
  RoastCook cook;
  std::unique_ptr<Command> const cmd1 = std::make_unique<MakeMuttonCmd>(&cook);
  std::unique_ptr<Command> const cmd2 = std::make_unique<MakeChickenWingCmd>(&cook);
  Waiter waiter;

  waiter.SetCmd(cmd1.get());
  waiter.SetCmd(cmd2.get());

  waiter.Notify();
  return 0;
}
