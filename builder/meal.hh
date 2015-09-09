#ifndef PRODUCT_HPP
#define PRODUCT_HPP

#include <queue>
#include <string>
#include <utility>

class Meal {
 public:
  void setMealItem(std::string&& mealItem) { mean_.push(std::move(mealItem)); }
  void serveMeal();

 private:
  std::queue<std::string> mean_;
};

#endif
