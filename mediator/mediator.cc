#include "mediator.hh"

Mediator::Mediator() = default;

Mediator::~Mediator() = default;

void Mediator::add(Telephone* t) { phones_.push_back(t); }

void Mediator::dialTo(Telephone* from, int num) {
  for (auto & phone : phones_) {
    if (phone->num() == num) phone->onCallReceive(from->num());
  }
}
