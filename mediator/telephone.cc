#include "telephone.hh"
#include <iostream>

std::ostream &operator<<(std::ostream &os, Telephone &phone) {
  os << "phone[" << phone.num() << "]";
  return os;
}

Telephone::Telephone(int phoneNum, MediatorPtr m)
    : num_(phoneNum), mediator_(m) {
  mediator_->add(this);
}

void Telephone::dial(int num) {
  std::cout << *this << " calls " << num << '\n';
  mediator_->dialTo(this, num);
}

void Telephone::onCallReceive(int num) {
  std::cout << *this << " answers " << num << '\n';
}
