#ifndef WAITER_HPP
#define WAITER_HPP

#include <vector>
class Command;

class Waiter {
 public:
  void SetCmd(Command* cmd);
  void Notify();

 protected:
  std::vector<Command*> cmds;
};

#endif
