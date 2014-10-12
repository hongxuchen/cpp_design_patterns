#ifndef FACTORY_HPP
#define FACTORY_HPP

#include "fly_weight.hpp"
#include "con_fly_weight.hpp"
#include <memory>
#include <vector>

class FlyWeightFactory {
 public:
  typedef std::shared_ptr<FlyWeight> FlyWeightPtr;
  std::size_t size() { return fly_.size(); }
  FlyWeightPtr getFlyWeight(std::string const& key);

 private:
  std::vector<FlyWeightPtr> fly_;
};
#endif
