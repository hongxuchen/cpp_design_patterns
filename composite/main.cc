#include "composite.hh"
#include <iostream>

int main(void) {
  ComponentPtr pRoot = nullptr;

  pRoot = std::make_shared<Composite>();

  pRoot->add(std::make_shared<Leaf>());

  ComponentPtr pLeaf1 = std::make_shared<Leaf>();
  ComponentPtr pLeaf2 = std::make_shared<Leaf>();

  pLeaf1->add(pLeaf2);
  pLeaf1->remove(pLeaf2);
  pLeaf1->operate();

  ComponentPtr pCom = std::make_shared<Composite>();
  pCom->add(pLeaf1);
  pCom->add(pLeaf2);
  pCom->operate();

  pRoot->add(pCom);
  pRoot->operate();
  pRoot->remove(pCom);

  return 0;
}
