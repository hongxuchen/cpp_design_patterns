#include "telephone.hh"
#include <iostream>
#include <utility>

std::ostream &operator<<(std::ostream &os, Telephone &phone) {
  os << "phone[" << phone.num() << "]";
  return os;
}

Telephone::Telephone(int phone_num, MediatorPtr m)
    : num_(phone_num), mediator_(std::move(std::move(m))) {
  mediator_->add(this);
}

void Telephone::dial(int num) {
  std::cout << *this << " calls " << num << '\n';
  mediator_->dialTo(this, num);
}

void Telephone::onCallReceive(int num) {
  std::cout << *this << " answers " << num << '\n';
}
