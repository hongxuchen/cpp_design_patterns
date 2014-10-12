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
  std::string state() { return state_; }
  void setState(std::string const &state) { state_ = state; }
};

#endif
