#ifndef CHINESE_BUILDER_HPP
#define CHINESE_BUILDER_HPP

#include "meal_builder.hh"

// Concrete Meal Builder 2
class ChineeseMealBuilder final : public MealBuilder {
 public:
  ChineeseMealBuilder() {}
  ~ChineeseMealBuilder() {}

  virtual void buildStarter() override { meal_.setMealItem("Manchurian"); }
  virtual void buildMainCourse() override { meal_.setMealItem("FriedNoodles"); }
  virtual void buildDessert() override { meal_.setMealItem("MangoPudding"); }
};

#endif
