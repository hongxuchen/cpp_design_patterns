#include "telephone.hh"
#include <iostream>
#include <utility>

std::ostream &operator<<(std::ostream &os, Telephone &phone) {
  os << "phone[" << phone.Num() << "]";
  return os;
}

Telephone::Telephone(int phone_num, MediatorPtr m)
    : num_(phone_num), mediator_(std::move(std::move(m))) {
  mediator_->Add(this);
}

void Telephone::Dial(int num) {
  std::cout << *this << " calls " << num << '\n';
  mediator_->DialTo(this, num);
}

void Telephone::OnCallReceive(int num) {
  std::cout << *this << " answers " << num << '\n';
}
