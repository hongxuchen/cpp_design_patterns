#include "composite.hh"
#include <memory>

int main() {
  ComponentPtr p_root = nullptr;

  p_root = std::make_shared<Composite>();

  p_root->add(std::make_shared<Leaf>());

  ComponentPtr const p_leaf1 = std::make_shared<Leaf>();
  ComponentPtr const p_leaf2 = std::make_shared<Leaf>();

  p_leaf1->add(p_leaf2);
  p_leaf1->remove(p_leaf2);
  p_leaf1->operate();

  ComponentPtr const p_com = std::make_shared<Composite>();
  p_com->add(p_leaf1);
  p_com->add(p_leaf2);
  p_com->operate();

  p_root->add(p_com);
  p_root->operate();
  p_root->remove(p_com);

  return 0;
}
