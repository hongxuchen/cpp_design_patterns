#ifndef PROTOTYPE_H
#define PROTOTYPE_H

#include <memory>

class Prototype {
 public:
  virtual ~Prototype() {}
  virtual std::shared_ptr<Prototype> clone() = 0;

 protected:
  Prototype() {}
};

#endif
