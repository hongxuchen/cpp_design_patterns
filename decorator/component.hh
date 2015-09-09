#ifndef COMPONENT_HPP
#define COMPONENT_HPP

#include <memory>

class Component {
 public:
  virtual ~Component() {}
  virtual void Operation() = 0;

 protected:
  Component() {}
};

typedef std::shared_ptr<Component> ComponentPtr;

#endif
