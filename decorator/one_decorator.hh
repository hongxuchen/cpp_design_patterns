#ifndef ONE_DECORATOR_HPP
#define ONE_DECORATOR_HPP

#include "component.hh"

class DecoratorOnlyOne : public Component {
 public:
  DecoratorOnlyOne(ComponentPtr com);
  ~DecoratorOnlyOne();
  virtual void Operation() override;
  static void AddBehavor();

 private:
  ComponentPtr com_;
};

#endif
