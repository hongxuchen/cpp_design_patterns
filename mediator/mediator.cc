#include "mediator.hh"

Mediator::Mediator() = default;

Mediator::~Mediator() = default;

void Mediator::Add(Telephone* t) { phones_.push_back(t); }

void Mediator::DialTo(Telephone* from, int num) {
  for (auto & phone : phones_) {
    if (phone->Num() == num) phone->OnCallReceive(from->Num());
  }
}
