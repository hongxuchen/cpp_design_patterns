#ifndef INVOKER_HPP
#define INVOKER_HPP

#include "command.hh"

class Invoker {
 public:
  Invoker(Command* cmd) { cmd_ = cmd; }
  void Invoke();
  ~Invoker() = default;

 private:
  Command* cmd_;
};

#endif
