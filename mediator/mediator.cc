#include "mediator.hpp"

Mediator::Mediator() {}

Mediator::~Mediator() {}

void Mediator::add(Telephone* t) { phones_.push_back(t); }

void Mediator::dialTo(Telephone* from, int num) {
  for (std::size_t i = 0; i < phones_.size(); ++i) {
    if (phones_[i]->num() == num) phones_[i]->onCallReceive(from->num());
  }
}
