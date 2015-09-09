#ifndef TELEPHONE_H
#define TELEPHONE_H

#include "mediator.hh"
#include <memory>
#include <ostream>

class Mediator;

typedef std::shared_ptr<Mediator> MediatorPtr;

class Telephone {
 public:
  Telephone(int phoneNum, MediatorPtr m);
  void dial(int phoneNum);
  int num() const { return num_; }
  void onCallReceive(int incommingNum);

 private:
  int num_;
  MediatorPtr mediator_;
};
std::ostream &operator<<(std::ostream &os, Telephone &phone);

#endif
