#ifndef ORINGINATOR_HPP
#define ORINGINATOR_HPP

#include <string>
#include "memonto.hh"

/// working class
class Originator {
 private:
  std::string state_;

 public:
  std::string state() { return state_; }
  void setState(std::string const &state) { state_ = state; }
  Memento createMemento() { return Memento(state_); }
  void restoreMemento(Memento &memento) { setState(memento.state()); }
};

#endif
