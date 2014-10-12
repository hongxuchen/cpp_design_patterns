#include "composite.hpp"
#include <iostream>
#include <algorithm>

void Component::add(ComponentPtr) {
  std::cout << __PRETTY_FUNCTION__ << "[DO NOTHING]\n";
}

void Component::remove(ComponentPtr) {
  std::cout << __PRETTY_FUNCTION__ << " [DO NOTHING]\n";
}

ComponentPtr Component::getChild(std::size_t) { return nullptr; }

void Leaf::operate() { std::cout << __PRETTY_FUNCTION__ << "\n"; }

void Composite::add(ComponentPtr com) {
  std::cout << __PRETTY_FUNCTION__ << " [ADDING]\n";
  comVect_.push_back(com);
}

void Composite::remove(ComponentPtr com) {
  std::cout << __PRETTY_FUNCTION__ << " [REMOVING]\n";
  comVect_.erase(std::remove(comVect_.begin(), comVect_.end(), com),
                 comVect_.end());
}

void Composite::operate() {
  std::cout << __PRETTY_FUNCTION__ << "\n";
  for (auto& component : comVect_) component->operate();
}

ComponentPtr Composite::getChild(std::size_t index) {
  if (index >= comVect_.size()) {
    return nullptr;
  }
  return comVect_[index];
}
