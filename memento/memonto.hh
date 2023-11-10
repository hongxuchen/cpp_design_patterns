#ifndef MEMONTO_HPP
#define MEMONTO_HPP

#include <string>

/// instance of memento
class Memento {
 private:
  std::string state_;

 public:
  Memento() = default;
  Memento(std::string const &state) { state_ = state; }
  std::string State() { return state_; }
  void SetState(std::string const &state) { state_ = state; }
};

#endif
