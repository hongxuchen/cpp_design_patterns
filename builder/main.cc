#include <iostream>

#include "chinese_builder.hpp"
#include "indian_builder.hpp"
#include "mexican_builder.hpp"
#include "cook.hpp"
#include <memory>

int main(void) {
  MultiCuisineCook cook;

  std::cout << "Build a Chineese Meal!" << std::endl;
  auto builder = std::make_unique<ChineeseMealBuilder>();
  cook.setMealBuilder(builder.get());
  cook.createMeal();

  Meal chineeseMeal = cook.getMeal();
  chineeseMeal.serveMeal();

  std::cout << "\nBuild a Mexican Meal!" << std::endl;
  auto mexicanBuilder = std::make_unique<MexicanMealBuilder>();
  cook.setMealBuilder(mexicanBuilder.get());
  /// below is wrong
  /// cook.setMealBuilder(std::make_unique<MexicanMealBuilder>().get());
  cook.createMeal();

  Meal mexicanMeal = cook.getMeal();
  mexicanMeal.serveMeal();

  return 0;
}
