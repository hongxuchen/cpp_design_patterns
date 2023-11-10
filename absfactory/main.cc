#include "negative_lower_factory.hh"
#include "positive_upper_factory.hh"

int main() {
  AbsFactory* f = nullptr;
  std::unique_ptr<AbsNum> n = nullptr;
  std::unique_ptr<AbsChar> c = nullptr;

  PositiveUpperFactory positive_upper_factory;
  f = &positive_upper_factory;
  n = f->CreateNum();
  n->PrintNum();
  c = f->CreateChar();
  c->PrintChar();

  NegativeLowerFactory negative_lower_factory;
  f = &negative_lower_factory;
  n = f->CreateNum();
  n->PrintNum();
  c = f->CreateChar();
  c->PrintChar();

  return 0;
}
