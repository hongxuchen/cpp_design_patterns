#include "composite.hh"
#include <algorithm>
#include <cstddef>
#include <iostream>

void Component::Add(ComponentPtr) {
  std::cout << __PRETTY_FUNCTION__ << "[DO NOTHING]\n";
}

void Component::Remove(ComponentPtr) {
  std::cout << __PRETTY_FUNCTION__ << " [DO NOTHING]\n";
}

ComponentPtr Component::GetChild(std::size_t) { return nullptr; }

void Leaf::Operate() { std::cout << __PRETTY_FUNCTION__ << "\n"; }

void Composite::Add(ComponentPtr com) {
  std::cout << __PRETTY_FUNCTION__ << " [ADDING]\n";
  comVect_.push_back(com);
}

void Composite::Remove(ComponentPtr com) {
  std::cout << __PRETTY_FUNCTION__ << " [REMOVING]\n";
  comVect_.erase(std::remove(comVect_.begin(), comVect_.end(), com),
                 comVect_.end());
}

void Composite::Operate() {
  std::cout << __PRETTY_FUNCTION__ << "\n";
  for (auto& component : comVect_) component->Operate();
}

ComponentPtr Composite::GetChild(std::size_t index) {
  if (index >= comVect_.size()) {
    return nullptr;
  }
  return comVect_[index];
}
