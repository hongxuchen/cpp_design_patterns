#ifndef TELEPHONE_H
#define TELEPHONE_H

#include "mediator.hh"
#include <memory>
#include <ostream>

class Mediator;

using MediatorPtr = std::shared_ptr<Mediator>;

class Telephone {
 public:
  Telephone(int phone_num, MediatorPtr m);
  void Dial(int phone_num);
  int Num() const { return num_; }
  void OnCallReceive(int incomming_num);

 private:
  int num_;
  MediatorPtr mediator_;
};
std::ostream &operator<<(std::ostream &os, Telephone &phone);

#endif
