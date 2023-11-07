#ifndef MEDIATOR_H
#define MEDIATOR_H

#include "telephone.hh"
#include <vector>

class Telephone;

class Mediator {
 public:
  Mediator();
  virtual ~Mediator();

  void add(Telephone* t);
  void dialTo(Telephone* from, int num);

 private:
  std::vector<Telephone*> phones_;
};

#endif
