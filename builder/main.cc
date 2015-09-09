#include <iostream>

#include "chinese_builder.hh"
#include "indian_builder.hh"
#include "mexican_builder.hh"
#include "cook.hh"
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
