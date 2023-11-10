#ifndef ORINGINATOR_HPP
#define ORINGINATOR_HPP

#include <string>
#include "memonto.hh"

/// working class
class Originator {
 private:
  std::string state_;

 public:
  std::string State() { return state_; }
  void SetState(std::string const &state) { state_ = state; }
  Memento CreateMemento() { return Memento(state_); }
  void RestoreMemento(Memento &memento) { SetState(memento.State()); }
};

#endif
