#include <iostream>
#include <string>

#include "oringinator.hpp"
#include "care_taker.hpp"

int main(void) {
  Originator originator;
  originator.setState("state1");
  std::cout << "original:\t" << originator.state() << std::endl;
  Caretaker caretaker;
  caretaker.setMemento(originator.createMemento());
  originator.setState("state2");
  std::cout << "changed:\t" << originator.state() << std::endl;
  originator.restoreMemento(caretaker.memnto());
  std::cout << "recovered:\t" << originator.state() << std::endl;
}
