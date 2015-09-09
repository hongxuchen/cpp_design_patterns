#ifndef CARE_TAKER_HPP
#define CARE_TAKER_HPP

#include "memonto.hh"

/// contain the memnto
class Caretaker {
 private:
  Memento memento_;

 public:
  Memento &memnto() { return memento_; }
  void setMemento(Memento const &memento) { memento_ = memento; }
};

#endif
