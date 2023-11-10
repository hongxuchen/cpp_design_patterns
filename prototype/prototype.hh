#ifndef PROTOTYPE_H
#define PROTOTYPE_H

#include <memory>

class Prototype {
 public:
  virtual ~Prototype() = default;
  virtual std::shared_ptr<Prototype> Clone() = 0;

 protected:
  Prototype() {}
};

#endif
