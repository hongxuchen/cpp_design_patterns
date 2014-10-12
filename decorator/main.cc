#include "decorator.hpp"
#include "concrete_component.hpp"
#include "one_decorator.hpp"
#include <iostream>

int main(void) {
  {
    ComponentPtr pCom = std::make_shared<ConcreteComponent>();
    pCom = std::make_shared<ConcreteDecoratorA>(pCom);
    pCom = std::make_shared<ConcreteDecoratorB>(pCom);
    pCom = std::make_shared<ConcreteDecoratorC>(pCom);
    pCom = std::make_shared<ConcreteDecoratorD>(pCom);
    pCom->Operation();
  }
  std::cout << "\n---\n\n";
  {
    ComponentPtr pCom1 = nullptr;
    pCom1 = std::make_shared<ConcreteComponent>();
    pCom1 = std::make_shared<DecoratorOnlyOne>(pCom1);
    pCom1->Operation();

    ConcreteComponent component;
    pCom1 = std::make_shared<ConcreteComponent>(component);
    pCom1 = std::make_shared<DecoratorOnlyOne>(pCom1);
    pCom1 = std::make_shared<ConcreteComponent>();
  }
  return 0;
}
