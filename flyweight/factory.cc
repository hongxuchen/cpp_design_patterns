#include "factory.hh"
#include "con_fly_weight.hh"
#include <iostream>
#include <memory>
#include <string>

FlyWeightFactory::FlyWeightPtr FlyWeightFactory::getFlyWeight(
    std::string const& key) {
  for (auto & it : fly_) {
    if (it->insState() == key) {
      std::cout << "Created\n";
      return it;
    }
  }
  auto fn = static_cast<FlyWeightPtr>(std::make_shared<ConFlyweight>(key));
  fly_.push_back(fn);
  return fn;
}
