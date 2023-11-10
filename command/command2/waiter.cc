#include "waiter.hh"

#include <iostream>

#include "command.hh"

void Waiter::SetCmd(Command* cmd) {
  cmds.push_back(cmd);
  std::cout << "add menu\n";
}

void Waiter::Notify() {
  for (auto* cmd : cmds) cmd->ExecuteCmd();
}
