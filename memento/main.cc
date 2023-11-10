#include <iostream>
#include <string>

#include "oringinator.hh"
#include "care_taker.hh"

int main() {
  Originator originator;
  originator.SetState("state1");
  std::cout << "original:\t" << originator.State() << '\n';
  Caretaker caretaker;
  caretaker.SetMemento(originator.CreateMemento());
  originator.SetState("state2");
  std::cout << "changed:\t" << originator.State() << '\n';
  originator.RestoreMemento(caretaker.Memnto());
  std::cout << "recovered:\t" << originator.State() << '\n';
}
