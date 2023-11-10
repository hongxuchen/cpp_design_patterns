#ifndef COMPONENT_HPP
#define COMPONENT_HPP

#include <memory>

class Component {
 public:
  virtual ~Component() = default;
  virtual void Operation() = 0;

 protected:
  Component() = default;
};

using ComponentPtr = std::shared_ptr<Component>;

#endif
