#include <iostream>
#include <string>

#include "oringinator.hh"
#include "care_taker.hh"

int main() {
  Originator originator;
  originator.setState("state1");
  std::cout << "original:\t" << originator.state() << '\n';
  Caretaker caretaker;
  caretaker.setMemento(originator.createMemento());
  originator.setState("state2");
  std::cout << "changed:\t" << originator.state() << '\n';
  originator.restoreMemento(caretaker.memnto());
  std::cout << "recovered:\t" << originator.state() << '\n';
}
