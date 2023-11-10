#ifndef CARE_TAKER_HPP
#define CARE_TAKER_HPP

#include "memonto.hh"

/// contain the memnto
class Caretaker {
 private:
  Memento memento_;

 public:
  Memento &Memnto() { return memento_; }
  void SetMemento(Memento const &memento) { memento_ = memento; }
};

#endif
