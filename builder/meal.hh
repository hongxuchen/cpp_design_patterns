#ifndef PRODUCT_HPP
#define PRODUCT_HPP

#include <queue>
#include <string>
#include <utility>

class Meal {
 public:
  void SetMealItem(std::string&& meal_item) { mean_.push(std::move(meal_item)); }
  void ServeMeal();

 private:
  std::queue<std::string> mean_;
};

#endif
