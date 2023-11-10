#ifndef FACTORY_HPP
#define FACTORY_HPP

#include "fly_weight.hh"
#include "con_fly_weight.hh"
#include <memory>
#include <vector>

class FlyWeightFactory {
 public:
  using FlyWeightPtr = std::shared_ptr<FlyWeight>;
  std::size_t Size() { return fly_.size(); }
  FlyWeightPtr GetFlyWeight(std::string const& key);

 private:
  std::vector<FlyWeightPtr> fly_;
};
#endif
