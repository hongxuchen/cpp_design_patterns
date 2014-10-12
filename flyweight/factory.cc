#include "factory.hpp"
#include <iostream>

FlyWeightFactory::FlyWeightPtr FlyWeightFactory::getFlyWeight(
    std::string const& key) {
  for (auto it = fly_.begin(); it != fly_.end(); ++it) {
    if ((*it)->insState() == key) {
      std::cout << "Created\n";
      return *it;
    }
  }
  auto fn = static_cast<FlyWeightPtr>(std::make_shared<ConFlyweight>(key));
  fly_.push_back(fn);
  return fn;
}
