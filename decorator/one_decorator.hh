#ifndef ONE_DECORATOR_HPP
#define ONE_DECORATOR_HPP

#include "component.hh"

class DecoratorOnlyOne : public Component {
 public:
  DecoratorOnlyOne(ComponentPtr com);
  ~DecoratorOnlyOne() override;
  void Operation() override;
  void AddBehavor();

 private:
  ComponentPtr com_;
};

#endif
