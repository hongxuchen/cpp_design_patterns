#include "command.hpp"
#include "receiver.hpp"

Command::~Command() = default;

ConcreteCommand::~ConcreteCommand() = default;

void ConcreteCommand::Execute() { recv_->Action(); }
