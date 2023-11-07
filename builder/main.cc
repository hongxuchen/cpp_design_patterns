#include <iostream>
#include <memory>

#include "chinese_builder.hh"
#include "cook.hh"
#include "meal.hh"
#include "mexican_builder.hh"

int main() {
  MultiCuisineCook cook;

  std::cout << "Build a Chineese Meal!" << '\n';
  auto builder = std::make_unique<ChineeseMealBuilder>();
  cook.setMealBuilder(builder.get());
  cook.createMeal();

  Meal chineese_meal = cook.getMeal();
  chineese_meal.serveMeal();

  std::cout << "\nBuild a Mexican Meal!" << '\n';
  auto mexican_builder = std::make_unique<MexicanMealBuilder>();
  cook.setMealBuilder(mexican_builder.get());
  /// below is wrong
  /// cook.setMealBuilder(std::make_unique<MexicanMealBuilder>().get());
  cook.createMeal();

  Meal mexican_meal = cook.getMeal();
  mexican_meal.serveMeal();

  return 0;
}
