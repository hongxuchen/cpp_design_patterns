#ifndef DECORATOR_HPP
#define DECORATOR_HPP

#include "component.hpp"

class Decorator : public Component {
 public:
  Decorator(ComponentPtr com);
  void SetComponent(ComponentPtr com);
  virtual ~Decorator();
  virtual void Operation() {}

 protected:
  ComponentPtr com_;
};

class ConcreteDecoratorA : public Decorator {
 public:
  ConcreteDecoratorA(ComponentPtr com);
  ~ConcreteDecoratorA();
  virtual void Operation() override;
  void AddBehavorA();
};

class ConcreteDecoratorB : public Decorator {
 public:
  ConcreteDecoratorB(ComponentPtr com);
  ~ConcreteDecoratorB();
  virtual void Operation() override;
  void AddBehavorB();
};

class ConcreteDecoratorC : public Decorator {
 public:
  ConcreteDecoratorC(ComponentPtr com);
  ~ConcreteDecoratorC();
  virtual void Operation();
  void AddBehavorC();
};

class ConcreteDecoratorD : public Decorator {
 public:
  ConcreteDecoratorD(ComponentPtr com);
  ~ConcreteDecoratorD();
  virtual void Operation() override;
  void AddBehavorD();
};


#endif
