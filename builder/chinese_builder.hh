#ifndef CHINESE_BUILDER_HPP
#define CHINESE_BUILDER_HPP

#include "meal_builder.hh"

// Concrete Meal Builder 2
class ChineeseMealBuilder final : public MealBuilder {
 public:
  ChineeseMealBuilder() = default;
  ~ChineeseMealBuilder() override = default;

  void BuildStarter() override { meal.SetMealItem("Manchurian"); }
  void BuildMainCourse() override { meal.SetMealItem("FriedNoodles"); }
  void BuildDessert() override { meal.SetMealItem("MangoPudding"); }
};

#endif
