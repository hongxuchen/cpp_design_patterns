#ifndef DECORATOR_HPP
#define DECORATOR_HPP

#include "component.hh"

class Decorator : public Component {
 public:
  Decorator(ComponentPtr com);
  void SetComponent(ComponentPtr com);
  ~Decorator() override;
  void Operation() override {}

 protected:
  ComponentPtr com;
};

class ConcreteDecoratorA : public Decorator {
 public:
  ConcreteDecoratorA(ComponentPtr com);
  ~ConcreteDecoratorA() override;
  void Operation() override;
  void AddBehavorA();
};

class ConcreteDecoratorB : public Decorator {
 public:
  ConcreteDecoratorB(ComponentPtr com);
  ~ConcreteDecoratorB() override;
  void Operation() override;
  void AddBehavorB();
};

class ConcreteDecoratorC : public Decorator {
 public:
  ConcreteDecoratorC(ComponentPtr com);
  ~ConcreteDecoratorC() override;
  void Operation() override;
  void AddBehavorC();
};

class ConcreteDecoratorD : public Decorator {
 public:
  ConcreteDecoratorD(ComponentPtr com);
  ~ConcreteDecoratorD() override;
  void Operation() override;
  void AddBehavorD();
};

#endif
