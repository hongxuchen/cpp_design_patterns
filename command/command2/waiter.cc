#include "waiter.hh"

#include <iostream>

#include "command.hh"

void Waiter::setCmd(Command* cmd) {
  cmds_.push_back(cmd);
  std::cout << "add menu\n";
}

void Waiter::notify() {
  for (auto* cmd : cmds_) cmd->ExecuteCmd();
}
