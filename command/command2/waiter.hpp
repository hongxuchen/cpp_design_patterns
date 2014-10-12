#ifndef WAITER_HPP
#define WAITER_HPP

#include <vector>
class Command;

class Waiter {
 public:
  void setCmd(Command* cmd);
  void notify();

 protected:
  std::vector<Command*> cmds_;
};

#endif
