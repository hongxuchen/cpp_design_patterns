#ifndef ONE_DECORATOR_HPP
#define ONE_DECORATOR_HPP

#include "component.hpp"

class DecoratorOnlyOne : public Component {
 public:
  DecoratorOnlyOne(ComponentPtr com);
  ~DecoratorOnlyOne();
  virtual void Operation() override;
  void AddBehavor();

 private:
  ComponentPtr com_;
};

#endif
