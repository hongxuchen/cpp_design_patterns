#include <memory>

#include "command.hh"
#include "invoker.hh"
#include "receiver.hh"

int main() {
  auto receiver = std::make_unique<Receiver>();
  std::unique_ptr<Command> const cmd =
      std::make_unique<ConcreteCommand>(receiver.get());
  auto invoker = std::make_unique<Invoker>(cmd.get());
  invoker->Invoke();

  return 0;
}
