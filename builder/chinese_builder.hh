#ifndef CHINESE_BUILDER_HPP
#define CHINESE_BUILDER_HPP

#include "meal_builder.hh"

// Concrete Meal Builder 2
class ChineeseMealBuilder final : public MealBuilder {
 public:
  ChineeseMealBuilder() = default;
  ~ChineeseMealBuilder() override = default;

  void buildStarter() override { meal_.setMealItem("Manchurian"); }
  void buildMainCourse() override { meal_.setMealItem("FriedNoodles"); }
  void buildDessert() override { meal_.setMealItem("MangoPudding"); }
};

#endif
