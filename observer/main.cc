#include <string>

#include "observer.hpp"

int main() {
  auto p = std::make_unique<Observer>();
  auto s1 = std::make_shared<Worker>("s1", p.get());
  auto s2 = std::make_shared<Worker>("s2", p.get());
  p->add(s1);
  p->add(s2);
  p->setMsg("(boss is comming)");
  p->notify();
  p->remove(0);
  p->notify();
  return 0;
}
