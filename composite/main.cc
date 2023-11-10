#include "composite.hh"
#include <memory>

int main() {
  ComponentPtr p_root = nullptr;

  p_root = std::make_shared<Composite>();

  p_root->Add(std::make_shared<Leaf>());

  ComponentPtr const p_leaf1 = std::make_shared<Leaf>();
  ComponentPtr const p_leaf2 = std::make_shared<Leaf>();

  p_leaf1->Add(p_leaf2);
  p_leaf1->Remove(p_leaf2);
  p_leaf1->Operate();

  ComponentPtr const p_com = std::make_shared<Composite>();
  p_com->Add(p_leaf1);
  p_com->Add(p_leaf2);
  p_com->Operate();

  p_root->Add(p_com);
  p_root->Operate();
  p_root->Remove(p_com);

  return 0;
}
