#ifndef COMMAND_HPP
#define COMMAND_HPP

class Command {
 public:
  virtual ~Command();
  virtual void Execute() = 0;

 protected:
  Command() = default;
};

class Receiver;

class ConcreteCommand final : public Command {
 public:
  ConcreteCommand(Receiver* recv) { recv_ = recv; }

  ~ConcreteCommand();
  virtual void Execute() override;

 private:
  Receiver* recv_;
};

#endif
