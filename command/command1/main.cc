#include "command.hpp"
#include "invoker.hpp"
#include "receiver.hpp"

#include <memory>

int main() {
  auto receiver = std::make_unique<Receiver>();
  std::unique_ptr<Command> cmd =
      std::make_unique<ConcreteCommand>(receiver.get());
  auto invoker = std::make_unique<Invoker>(cmd.get());
  invoker->Invoke();

  return 0;
}
