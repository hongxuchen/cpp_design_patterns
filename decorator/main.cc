#include "component.hh"
#include "concrete_component.hh"
#include "decorator.hh"
#include "one_decorator.hh"
#include <iostream>
#include <memory>

int main() {
  {
    ComponentPtr p_com = std::make_shared<ConcreteComponent>();
    p_com = std::make_shared<ConcreteDecoratorA>(p_com);
    p_com = std::make_shared<ConcreteDecoratorB>(p_com);
    p_com = std::make_shared<ConcreteDecoratorC>(p_com);
    p_com = std::make_shared<ConcreteDecoratorD>(p_com);
    p_com->Operation();
  }
  std::cout << "\n---\n\n";
  {
    ComponentPtr p_com1 = nullptr;
    p_com1 = std::make_shared<ConcreteComponent>();
    p_com1 = std::make_shared<DecoratorOnlyOne>(p_com1);
    p_com1->Operation();

    ConcreteComponent const component;
    p_com1 = std::make_shared<ConcreteComponent>(component);
    p_com1 = std::make_shared<DecoratorOnlyOne>(p_com1);
    p_com1 = std::make_shared<ConcreteComponent>();
  }
  return 0;
}
