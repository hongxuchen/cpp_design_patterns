#include "command.hh"
#include "receiver.hh"

Command::~Command() = default;

ConcreteCommand::~ConcreteCommand() = default;

void ConcreteCommand::Execute() { Receiver::Action(); }
