#include <memory>
#include <string>

#include "observer.hh"
#include "worker.hh"

int main() {
  auto p = std::make_unique<Observer>();
  auto s1 = std::make_shared<Worker>("s1", p.get());
  auto s2 = std::make_shared<Worker>("s2", p.get());
  p->Add(s1);
  p->Add(s2);
  p->SetMsg("(boss is comming)");
  p->Notify();
  p->Remove(0);
  p->Notify();
  return 0;
}
