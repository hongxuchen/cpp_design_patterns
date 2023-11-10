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
  cook.SetMealBuilder(builder.get());
  cook.CreateMeal();

  Meal chineese_meal = cook.GetMeal();
  chineese_meal.ServeMeal();

  std::cout << "\nBuild a Mexican Meal!" << '\n';
  auto mexican_builder = std::make_unique<MexicanMealBuilder>();
  cook.SetMealBuilder(mexican_builder.get());
  /// below is wrong
  /// cook.setMealBuilder(std::make_unique<MexicanMealBuilder>().get());
  cook.CreateMeal();

  Meal mexican_meal = cook.GetMeal();
  mexican_meal.ServeMeal();

  return 0;
}
